import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:material_ui/material_ui.dart';

import '../barcode_support.dart';
import '../data/catalog.dart';
import '../data/database.dart' as db;
import '../gallery_scan.dart';
import '../photos.dart';
import 'photo_picker.dart';
import 'scan_screen.dart';

/// Videata 8: dati della nuova tessera.
class NewCardDataScreen extends StatefulWidget {
  const NewCardDataScreen({
    super.key,
    required this.database,
    required this.type,
  });

  final db.AppDatabase database;
  final db.CardType type;

  @override
  State<NewCardDataScreen> createState() => _NewCardDataScreenState();
}

class _NewCardDataScreenState extends State<NewCardDataScreen> {
  late final _name = TextEditingController(
    text: hasFixedName(widget.type) ? widget.type.name : '',
  );
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  final _holder = TextEditingController();
  final _notes = TextEditingController();

  List<db.Section> _sections = const [];
  db.Section? _section;
  int _count = 0;
  DateTime? _expiresOn;
  bool _favorite = false;
  String? _scannedFormat; // formato letto (fotocamera o galleria), se c'è
  // Foto scelte, tenute in memoria fino al salvataggio.
  final Map<String, Uint8List> _photos = {};
  bool _saving = false;

  /// Tessera generica: codice e foto del fronte obbligatori (decisione 72).
  bool get _frontRequired => widget.type.isGeneric;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sections = await widget.database.visibleSections();
    final count = await widget.database.activeCardCount();
    // Intestatario proposto: il nome dato nella configurazione iniziale.
    final holder = await widget.database.setting(db.SettingKeys.holderName);
    if (!mounted) return;
    if (_holder.text.isEmpty && holder != null) _holder.text = holder;
    setState(() {
      _sections = sections;
      _section = sections.firstWhere((s) => s.isDefault,
          orElse: () => sections.first);
      _count = count;
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
    final title = side == PhotoSide.front ? 'Foto del fronte' : 'Foto del retro';
    if (_photos.containsKey(side)) {
      final remove = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Sostituisci'),
                onTap: () => Navigator.of(context).pop(false),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Togli la foto'),
                onTap: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      if (remove == null || !mounted) return;
      if (remove) return setState(() => _photos.remove(side));
    }
    final bytes = await pickCardPhoto(context, title: title);
    if (bytes != null && mounted) setState(() => _photos[side] = bytes);
  }

  Widget _photoSlot(String side) {
    final bytes = _photos[side];
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
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        color: scheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(sideLabel(side),
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
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
        title: const Text('Sezione'),
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

  Future<void> _save() async {
    final name = _name.text.trim();
    final code = _code.text.trim();
    final section = _section;
    if (name.isEmpty) return _message('Scrivi il nome della tessera.');
    if (code.isEmpty) return _message('Inserisci o scansiona il codice.');
    if (_frontRequired && !_photos.containsKey(PhotoSide.front)) {
      return _message('Per la tessera generica serve la foto del fronte.');
    }
    if (section == null) return;
    if (_count >= db.AppDatabase.freeCardLimit) {
      return _message('Hai raggiunto il limite di ${db.AppDatabase.freeCardLimit} tessere.');
    }
    // Il formato si salva sempre sulla singola tessera. Scritto a mano e senza
    // formato indicato dalla tipologia: si usa Code 128, che accetta testo libero.
    final format = _scannedFormat ?? widget.type.codeFormat ?? 'code128';
    final holder = _holder.text.trim();
    final notes = _notes.text.trim();
    setState(() => _saving = true);
    try {
      final d = widget.database;
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
        await d.into(d.cards).insert(
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.type.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _code,
            focusNode: _codeFocus,
            decoration: const InputDecoration(
              labelText: 'Codice',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _scannedFormat = null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _scan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scansiona'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _fromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Da galleria'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Sezione'),
            trailing: Text(_section?.name ?? ''),
            onTap: _pickSection,
          ),
          ListTile(
            title: const Text('Scadenza'),
            trailing: Text(date == null
                ? 'Nessuna'
                : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _holder,
            decoration: const InputDecoration(
              labelText: 'Intestatario',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            // Una riga sola; si allarga fino a tre mentre si scrive.
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note',
              hintText: 'Facoltative',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _frontRequired
                ? 'FOTO (IL FRONTE È OBBLIGATORIO)'
                : 'FOTO (FACOLTATIVE)',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _photoSlot(PhotoSide.front),
              const SizedBox(width: 12),
              _photoSlot(PhotoSide.back),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Aggiungi alle preferite'),
            value: _favorite,
            onChanged: (v) => setState(() => _favorite = v),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Salvataggio…' : 'Salva'),
          ),
        ],
      ),
    );
  }
}
