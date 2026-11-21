import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:material_ui/material_ui.dart';

import '../barcode_support.dart';
import '../codice_fiscale.dart';
import '../data/catalog.dart';
import '../data/database.dart' as db;
import '../gallery_scan.dart';
import '../format_utils.dart';
import '../photo_draft.dart';
import '../photos.dart';
import '../theme.dart';
import '../l10n/l10n.dart';
import '../ui.dart';
import 'photo_picker.dart';
import 'scan_screen.dart';

/// Videata 8: dati della nuova tessera. Con [card] la stessa pagina modifica
/// una tessera esistente (matita nella videata 5); la tipologia non cambia.
class NewCardDataScreen extends StatefulWidget {
  const NewCardDataScreen({
    super.key,
    required this.database,
    required this.type,
    this.card,
    this.restore,
  });

  final db.AppDatabase database;
  final db.CardType type;
  final db.Card? card;

  /// Bozza da cui ripartire: la pagina era aperta quando Android ha chiuso
  /// l'app durante lo scatto di una foto (vedi photo_draft.dart).
  final PhotoDraft? restore;

  @override
  State<NewCardDataScreen> createState() => _NewCardDataScreenState();
}

class _NewCardDataScreenState extends State<NewCardDataScreen> {
  late final _name = TextEditingController(
    text:
        widget.card?.name ??
        (hasFixedName(widget.type) ? widget.type.name : ''),
  );
  late final _code = TextEditingController(text: widget.card?.code);
  final _codeFocus = FocusNode();
  late final _holder = TextEditingController(text: widget.card?.holder);
  late final _notes = TextEditingController(text: widget.card?.notes);

  List<db.Section> _sections = const [];
  db.Section? _section;
  int _count = 0;
  late DateTime? _expiresOn = widget.card?.expiresOn;
  late bool _favorite = widget.card?.favorite ?? false;
  // Formato del codice: quello letto (fotocamera o galleria) o, modificando,
  // quello salvato; si azzera se il codice si riscrive a mano.
  late String? _scannedFormat = widget.card?.codeFormat;
  // Foto scelte, tenute in memoria fino al salvataggio.
  final Map<String, Uint8List> _photos = {};
  // Modificando: foto già salvate (lato → file) e lati da togliere.
  Map<String, String> _savedPhotos = const {};
  final Set<String> _removedPhotos = {};
  PhotoStore? _store;
  bool _saving = false;

  bool get _editing => widget.card != null;

  /// C'è una foto per quel lato, nuova o già salvata e non tolta?
  bool _hasPhoto(String side) =>
      _photos.containsKey(side) ||
      (_savedPhotos.containsKey(side) && !_removedPhotos.contains(side));

  /// Tessera generica: codice e foto del fronte obbligatori (decisione 72).
  bool get _frontRequired => widget.type.isGeneric;

  @override
  void initState() {
    super.initState();
    final draft = widget.restore;
    if (draft != null) _applyDraft(draft);
    _load();
  }

  /// Bozza della pagina, salvata prima di aprire fotocamera o galleria per
  /// il lato [side].
  PhotoDraft _draft(String side) => PhotoDraft(
    kind: DraftKind.form,
    side: side,
    data: {
      'typeId': widget.type.id,
      'cardId': widget.card?.id,
      'name': _name.text,
      'code': _code.text,
      'format': _scannedFormat,
      'sectionId': _section?.id,
      'expiresOn': _expiresOn?.toIso8601String(),
      'favorite': _favorite,
      'holder': _holder.text,
      'notes': _notes.text,
      'removed': _removedPhotos.toList(),
    },
    photos: Map.of(_photos),
  );

  void _applyDraft(PhotoDraft draft) {
    final d = draft.data;
    _name.text = d['name'] as String? ?? _name.text;
    _code.text = d['code'] as String? ?? '';
    _holder.text = d['holder'] as String? ?? '';
    _notes.text = d['notes'] as String? ?? '';
    _scannedFormat = d['format'] as String?;
    _expiresOn = DateTime.tryParse(d['expiresOn'] as String? ?? '');
    _favorite = d['favorite'] as bool? ?? false;
    _restoredSectionId = d['sectionId'] as String?;
    _removedPhotos.addAll(((d['removed'] as List?) ?? const []).cast<String>());
    _photos.addAll(draft.photos);
  }

  /// Sezione della bozza, da applicare quando le sezioni sono caricate.
  String? _restoredSectionId;

  Future<void> _load() async {
    final d = widget.database;
    final sections = await d.visibleSections();
    final count = await d.activeCardCount();
    final card = widget.card;
    final store = await PhotoStore.instance;
    final saved = card == null
        ? const <String, String>{}
        : await d.cardPhotos(card.id);
    // Intestatario proposto (solo per una tessera nuova): il nome dato nella
    // configurazione iniziale.
    final holder = card == null && widget.restore == null
        ? await d.setting(db.SettingKeys.holderName)
        : null;
    if (!mounted) return;
    if (_holder.text.isEmpty && holder != null) _holder.text = holder;
    setState(() {
      _sections = sections;
      final wanted = _restoredSectionId ?? card?.sectionId;
      _section = sections.firstWhere(
        (s) => wanted != null ? s.id == wanted : s.isDefault,
        orElse: () => sections.firstWhere(
          (s) => s.isDefault,
          orElse: () => sections.first,
        ),
      );
      _count = count;
      _store = store;
      _savedPhotos = saved;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _codeFocus.dispose();
    _holder.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _scan() async {
    final outcome = await Navigator.of(context).push<ScanOutcome>(
      MaterialPageRoute(
        builder: (_) => ScanScreen(
          typeName: hasFixedName(widget.type) ? widget.type.name : null,
          expectedFormat: widget.type.codeFormat,
          typeId: widget.type.id,
        ),
      ),
    );
    if (outcome == null || !mounted) return;
    if (outcome.manual) {
      _codeFocus.requestFocus();
      return;
    }
    final code = outcome.code!;
    setState(() {
      _code.text = code.value;
      _scannedFormat = formatToText(code.format);
    });
  }

  /// Decisione 110: la galleria si sceglie qui, accanto a "Scansiona",
  /// senza aprire la fotocamera né chiederne il permesso.
  Future<void> _fromGallery() async {
    final check = await readCodeFromGallery(
      expectedFormat: widget.type.codeFormat,
      typeName: hasFixedName(widget.type) ? widget.type.name : null,
      typeId: widget.type.id,
    );
    if (check == null || !mounted) return;
    if (!check.isAccepted) return _message('${check.title}\n${check.detail}');
    final code = check.code!;
    setState(() {
      _code.text = code.value;
      _scannedFormat = formatToText(code.format);
    });
  }

  Future<void> _pickPhoto(String side) async {
    final title = side == PhotoSide.front
        ? context.t.photoFront
        : context.t.photoBack;
    if (_hasPhoto(side)) {
      final remove = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(context.t.replace),
                onTap: () => Navigator.of(context).pop(false),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(context.t.removePhoto),
                onTap: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      if (remove == null || !mounted) return;
      if (remove) {
        return setState(() {
          _photos.remove(side);
          if (_savedPhotos.containsKey(side)) _removedPhotos.add(side);
        });
      }
    }
    final bytes = await pickCardPhoto(
      context,
      title: title,
      draft: _draft(side),
    );
    if (bytes != null && mounted) {
      setState(() {
        _photos[side] = bytes;
        _removedPhotos.remove(side);
      });
    }
  }

  Widget _photoSlot(String side) {
    final bytes = _photos[side];
    final saved = _removedPhotos.contains(side) ? null : _savedPhotos[side];
    final store = _store;
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _saving ? null : () => _pickPhoto(side),
        child: Container(
          height: 92,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: bytes != null
              ? Image.memory(bytes, fit: BoxFit.cover)
              : saved != null && store != null
              ? Image.file(store.file(saved), fit: BoxFit.cover)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sideLabel(side),
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Riquadro in alto con la tipologia scelta (videata 8).
  Widget _typeBox(AppColors c) {
    final format = widget.type.codeFormat;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.infoBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          TypeLogo(type: widget.type, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeName(widget.type),
                  style: TextStyle(
                    color: c.infoText,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  format == null
                      ? context.t.anyCodeFormat
                      : context.t.codeFormatIs(
                          formatLabel(formatFromText(format)),
                        ),
                  style: TextStyle(
                    color: c.infoText.withValues(alpha: 0.8),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Campo che si tocca per scegliere (sezione, scadenza).
  Widget _pickerBox({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool muted = false,
    VoidCallback? onClear,
  }) {
    final c = AppColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: onClear != null
              ? IconButton(
                  tooltip: context.t.remove,
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClear,
                )
              : const Icon(Icons.expand_more),
        ),
        child: Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: muted ? c.muted : c.text,
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _expiresOn ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 30),
    );
    if (d != null && mounted) setState(() => _expiresOn = d);
  }

  Future<void> _pickSection() async {
    final chosen = await showDialog<db.Section>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.t.section),
        children: [
          for (final s in _sections)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(s),
              child: Text(s.name),
            ),
        ],
      ),
    );
    if (chosen != null && mounted) setState(() => _section = chosen);
  }

  /// Modifica: prima i file delle foto nuove, poi la tessera e le foto in una
  /// transazione, infine via i file non più usati.
  Future<void> _saveEdits(
    db.Card card,
    String name,
    String code,
    String format,
    db.Section section,
    String holder,
    String notes,
  ) async {
    final d = widget.database;
    final store = await PhotoStore.instance;
    final files = <String, String>{};
    for (final e in _photos.entries) {
      final fileName = await store.write(card.id, e.key, e.value);
      if (fileName != null) files[e.key] = fileName;
    }
    final obsolete = await d.updateCard(
      card.id,
      db.CardsCompanion(
        name: Value(name),
        code: Value(code),
        codeFormat: Value(format),
        sectionId: Value(section.id),
        holder: Value(holder.isEmpty ? null : holder),
        notes: Value(notes.isEmpty ? null : notes),
        expiresOn: Value(_expiresOn),
        favorite: Value(_favorite),
      ),
      newPhotos: files,
      removedPhotos: _removedPhotos,
    );
    for (final f in obsolete) {
      await store.delete(f);
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final isCf = widget.type.id == codiceFiscaleTypeId;
    // Il Code 39 ha solo maiuscole: il codice fiscale si salva così.
    final code = isCf ? _code.text.trim().toUpperCase() : _code.text.trim();
    final section = _section;
    if (name.isEmpty) return _message(context.t.enterCardName);
    if (code.isEmpty) return _message(context.t.enterCode);
    // Codice Fiscale: anche scritto a mano deve avere il carattere di
    // controllo giusto, altrimenti non si salva.
    if (isCf && !isValidCodiceFiscale(code)) {
      return _message(context.t.cfInvalidTyped);
    }
    if (_frontRequired && !_hasPhoto(PhotoSide.front)) {
      return _message(context.t.genericNeedsFront);
    }
    if (section == null) return;
    if (!_editing && _count >= db.AppDatabase.freeCardLimit) {
      return _message(context.t.limitReached(db.AppDatabase.freeCardLimit));
    }
    // Il formato si salva sempre sulla singola tessera. Scritto a mano e senza
    // formato indicato dalla tipologia: si usa Code 128, che accetta testo libero.
    final format = _scannedFormat ?? widget.type.codeFormat ?? 'code128';
    final holder = _holder.text.trim();
    final notes = _notes.text.trim();
    setState(() => _saving = true);
    try {
      final d = widget.database;
      final card = widget.card;
      if (card != null) {
        await _saveEdits(card, name, code, format, section, holder, notes);
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
      final id = db.newId();
      // Prima i file (la riduzione può richiedere un attimo), poi tutto il
      // database in una transazione.
      final store = await PhotoStore.instance;
      final files = <String, String>{};
      for (final e in _photos.entries) {
        final fileName = await store.write(id, e.key, e.value);
        if (fileName != null) files[e.key] = fileName;
      }
      await d.transaction(() async {
        await d
            .into(d.cards)
            .insert(
              db.CardsCompanion.insert(
                id: Value(id),
                typeId: widget.type.id,
                name: name,
                code: code,
                codeFormat: format,
                sectionId: section.id,
                holder: Value(holder.isEmpty ? null : holder),
                notes: Value(notes.isEmpty ? null : notes),
                expiresOn: Value(_expiresOn),
                favorite: Value(_favorite),
              ),
            );
        for (final e in files.entries) {
          await d.setCardPhoto(id, e.key, e.value);
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final date = _expiresOn;
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? context.t.editCard : context.t.newCard),
      ),
      // "Salva" fisso in basso: resta visibile anche sui telefoni piccoli.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? context.t.saving : context.t.save),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          _typeBox(c),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: context.t.name),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _code,
            focusNode: _codeFocus,
            decoration: InputDecoration(labelText: context.t.code),
            onChanged: (_) => _scannedFormat = null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _scan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(context.t.scan),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _fromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(context.t.fromGallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _pickerBox(
                  label: context.t.section,
                  value: _section?.name ?? '',
                  onTap: _pickSection,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pickerBox(
                  label: context.t.expiry,
                  value: date == null ? context.t.none : shortDate(date),
                  muted: date == null,
                  onTap: _pickDate,
                  onClear: date == null
                      ? null
                      : () => setState(() => _expiresOn = null),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _holder,
            decoration: InputDecoration(labelText: context.t.holder),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            // Una riga sola; si allarga fino a tre mentre si scrive.
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.t.notes,
              hintText: context.t.notesHint,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _frontRequired
                ? context.t.photosFrontRequired
                : context.t.photosOptional,
            style: TextStyle(
              color: c.muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _photoSlot(PhotoSide.front),
              const SizedBox(width: 12),
              _photoSlot(PhotoSide.back),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => _favorite = !_favorite),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Icon(
                    _favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: _favorite ? c.star : c.muted,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.t.addToFavorites,
                    style: TextStyle(color: c.text, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
