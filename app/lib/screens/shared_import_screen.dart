import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../format_utils.dart';
import '../photos.dart';
import '../theme.dart';
import '../transfer/archive_format.dart';
import '../transfer/import_shared.dart';
import '../ui.dart';

/// Videata 11 (sezione ricevuta) e decisione 107 (tessera ricevuta): dove
/// mettere le tessere, con l'esito sul limite prima di importare.
class SharedImportScreen extends StatefulWidget {
  const SharedImportScreen({
    super.key,
    required this.database,
    required this.header,
    required this.content,
  });

  final db.AppDatabase database;
  final ArchiveHeader header;
  final ArchiveContent content;

  @override
  State<SharedImportScreen> createState() => _SharedImportScreenState();
}

class _SharedImportScreenState extends State<SharedImportScreen> {
  final _name = TextEditingController();
  List<db.Section> _sections = const [];
  db.Section? _previous; // copia ricevuta prima (decisione 79)
  SharedImportMode _mode = SharedImportMode.newSection;
  String? _target; // sezione per "Unisci" e per la tessera singola
  SharedImportPlan? _plan;
  bool _nameTaken = false;
  bool _busy = false;

  db.AppDatabase get _db => widget.database;
  bool get _single => widget.header.kind == ArchiveKind.card;
  ArchiveSection get _section => widget.content.sections.single;
  int get _count => widget.content.cards.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sections = await _db.visibleSections();
    sections.sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    final previous = _single
        ? null
        : await previouslyReceived(_db, widget.content);
    final proposed = await proposedSectionName(_db, _section.name);
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _previous = previous;
      _name.text = proposed;
      // Tessera singola: si sceglie la sezione, proposta la Generale (107).
      if (_single) _mode = SharedImportMode.merge;
      // Sezione già ricevuta: chi la riceve di nuovo di solito vuole
      // l'aggiornamento, quindi si propone "Sostituisci" (decisione 113).
      if (previous != null) _mode = SharedImportMode.replace;
      _target = sections.firstWhere((s) => s.isDefault).id;
    });
    _replan();
  }

  Future<void> _replan() async {
    final mode = _mode;
    final target = mode == SharedImportMode.replace ? _previous?.id : _target;
    final plan = await planSharedImport(
      _db,
      widget.content,
      mode,
      targetSectionId: target,
    );
    final taken =
        mode == SharedImportMode.newSection &&
        await _db.sectionNameInUse(_name.text);
    if (mounted) {
      setState(() {
        _plan = plan;
        _nameTaken = taken;
      });
    }
  }

  void _setMode(SharedImportMode m) {
    if (_busy) return;
    setState(() => _mode = m);
    _replan();
  }

  void _setTarget(String id) {
    if (_busy) return;
    setState(() => _target = id);
    _replan();
  }

  String _cards(int n) => n == 1 ? '1 tessera' : '$n tessere';

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      await runSharedImport(
        _db,
        await PhotoStore.instance,
        widget.content,
        _mode,
        targetSectionId: _mode == SharedImportMode.replace
            ? _previous!.id
            : _target,
        newSectionName: _name.text,
      );
      if (!mounted) return;
      final n = _plan?.added ?? 0;
      _message(
        _mode == SharedImportMode.replace
            ? 'Sezione aggiornata.'
            : (n == 1 ? 'Importata 1 tessera.' : 'Importate $n tessere.'),
      );
      Navigator.of(context).pop(true);
    } on TransferException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('Importazione non riuscita: le tue tessere non sono cambiate.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _option(
    AppColors c,
    SharedImportMode mode,
    String title,
    String? detail, {
    Widget? extra,
  }) {
    final selected = _mode == mode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _setMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? c.primary : c.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? c.primary : c.muted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(color: c.text, fontSize: 16.5),
                        ),
                        if (detail != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            detail,
                            style: TextStyle(color: c.muted, fontSize: 13.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (selected && extra != null) ...[
                const SizedBox(height: 12),
                extra,
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Scelta della sezione (per "Unisci" e per la tessera singola).
  Widget _sectionPicker(AppColors c) {
    final current = _sections.where((s) => s.id == _target);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final chosen = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Sezione'),
            children: [
              for (final s in _sections)
                SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(s.id),
                  child: Text(s.name),
                ),
            ],
          ),
        );
        if (chosen != null) _setTarget(chosen);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Sezione',
          suffixIcon: Icon(Icons.expand_more),
        ),
        child: Text(
          current.isEmpty ? '' : current.first.name,
          style: TextStyle(color: c.text, fontSize: 15.5),
        ),
      ),
    );
  }

  Widget _outcome(AppColors c, SharedImportPlan p) {
    final ok = p.fits;
    final String title;
    String? detail;
    if (!ok) {
      title = 'Con questa scelta saresti a ${p.result} tessere';
      detail =
          'Il limite della versione gratuita è ${p.limit}.\nCon Pro non hai limiti.';
    } else if (p.added == 0 && p.updated == 0) {
      title = _single
          ? 'Questa tessera c\'è già nella sezione scelta'
          : 'Tutte le tessere ci sono già nella sezione scelta';
      detail = 'Non c\'è niente da aggiungere.';
    } else {
      title = 'Dopo l\'importazione: ${p.result} di ${p.limit} tessere';
      final parts = [
        if (p.updated > 0)
          '${_cards(p.updated)} aggiornat${p.updated == 1 ? 'a' : 'e'}',
        if (p.toTrash > 0)
          '${p.toTrash} non più nel file: nel cestino per 30 giorni',
        if (p.skipped > 0)
          '${p.skipped == 1 ? '1 già presente' : '${p.skipped} già presenti'}, non si aggiung${p.skipped == 1 ? 'e' : 'ono'}',
      ];
      detail = parts.isEmpty ? null : parts.join(' · ');
    }
    final fg = ok ? c.success : c.danger;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ok ? c.successBg : c.dangerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ok ? Icons.check : Icons.error, color: fg, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: fg, fontSize: 14.5)),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(color: fg, fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = _plan;
    final previous = _previous;
    final nameOk =
        _mode != SharedImportMode.newSection ||
        (_name.text.trim().isNotEmpty && !_nameTaken);
    final canImport =
        p != null &&
        p.fits &&
        nameOk &&
        !_busy &&
        (p.added > 0 || p.updated > 0 || p.toTrash > 0);
    final card = _single ? widget.content.cards.single : null;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_single ? 'Importa tessera' : 'Importa sezione'),
        ),
        body: Column(
          children: [
            if (_busy) const LinearProgressIndicator(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.infoBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _single
                                  ? Icons.credit_card
                                  : Icons.folder_outlined,
                              color: c.infoText,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                card?.name ?? _section.name,
                                style: TextStyle(
                                  color: c.infoText,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _single
                              ? 'Tessera ricevuta il ${longDate(widget.header.createdAt)}'
                              : '${_cards(_count)} · creato il ${longDate(widget.header.createdAt)}',
                          style: TextStyle(color: c.infoText, fontSize: 13.5),
                        ),
                        if (previous?.receivedAt != null)
                          Text(
                            'Già ricevuta il ${longDate(previous!.receivedAt!)}',
                            style: TextStyle(
                              color: c.infoText.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_single) ...[
                    const GroupHeader('In quale sezione'),
                    _sectionPicker(c),
                    const SizedBox(height: 12),
                  ] else ...[
                    const GroupHeader('Dove metterle'),
                    _option(
                      c,
                      SharedImportMode.newSection,
                      'Nuova sezione',
                      'Con un nome non ancora usato',
                      extra: TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => _replan(),
                        decoration: InputDecoration(
                          labelText: 'Nome (non ancora usato)',
                          errorText: _nameTaken
                              ? 'Questo nome è già usato da un\'altra sezione.'
                              : null,
                        ),
                      ),
                    ),
                    _option(
                      c,
                      SharedImportMode.merge,
                      'Unisci a una sezione esistente',
                      'Aggiunge solo le tessere nuove',
                      extra: _sectionPicker(c),
                    ),
                    if (previous != null)
                      _option(
                        c,
                        SharedImportMode.replace,
                        'Sostituisci «${previous.name}»',
                        'Rimpiazza la copia ricevuta prima',
                      ),
                    const SizedBox(height: 2),
                  ],
                  if (p != null) _outcome(c, p),
                  const SizedBox(height: 16),
                  Text(
                    _single
                        ? 'La tessera importata diventa tua: puoi modificarla, spostarla o eliminarla.'
                        : 'Le tessere importate diventano tue: puoi modificarle, spostarle o eliminarle.',
                    style: TextStyle(color: c.muted, fontSize: 13.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (p != null && !p.fits) ...[
                  FilledButton.tonal(
                    onPressed: () => _message(
                      'L\'acquisto arriverà con la pubblicazione su Google Play.',
                    ),
                    child: const Text('Scopri Pro · 2,00 €'),
                  ),
                  const SizedBox(height: 10),
                ],
                FilledButton(
                  onPressed: canImport ? _import : null,
                  child: Text(
                    _single
                        ? 'Importa la tessera'
                        : _mode == SharedImportMode.replace
                        ? 'Sostituisci'
                        : 'Importa ${_cards(p?.added ?? _count)}',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
