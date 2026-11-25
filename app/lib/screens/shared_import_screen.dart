import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../data/sort_key.dart';
import '../format_utils.dart';
import '../l10n/l10n.dart';
import '../photos.dart';
import '../theme.dart';
import '../transfer/archive_format.dart';
import '../transfer/import_shared.dart';
import '../ui.dart';

/// Videata 11 (sezione ricevuta) e decisione 107 (tessera ricevuta): dove
/// mettere le tessere, con l'esito prima di importare.
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
      return compareNames(a.name, b.name);
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

  String _cards(int n) => context.t.cardCount(n);

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
            ? context.t.sectionUpdated
            : context.t.importedCount(n),
      );
      Navigator.of(context).pop(true);
    } on TransferException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(context.t.importFailedNothingChanged);
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
            title: Text(context.t.section),
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
        decoration: InputDecoration(
          labelText: context.t.section,
          suffixIcon: const Icon(Icons.expand_more),
        ),
        child: Text(
          current.isEmpty ? '' : current.first.name,
          style: TextStyle(color: c.text, fontSize: 15.5),
        ),
      ),
    );
  }

  Widget _outcome(AppColors c, SharedImportPlan p) {
    final String title;
    String? detail;
    if (p.added == 0 && p.updated == 0) {
      title = _single
          ? context.t.cardAlreadyInSection
          : context.t.allAlreadyInSection;
      detail = context.t.nothingToAdd;
    } else {
      title = context.t.afterImport(p.result);
      final parts = [
        if (p.updated > 0) context.t.updatedCount(p.updated),
        if (p.toTrash > 0)
          context.t.noLongerInFile(p.toTrash, db.AppDatabase.trashDays),
        if (p.skipped > 0) context.t.skippedCount(p.skipped),
      ];
      detail = parts.isEmpty ? null : parts.join(' · ');
    }
    final fg = c.success;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.successBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: fg, size: 22),
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
        nameOk &&
        !_busy &&
        (p.added > 0 || p.updated > 0 || p.toTrash > 0);
    final card = _single ? widget.content.cards.single : null;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _single ? context.t.importCardTitle : context.t.importSectionTitle,
          ),
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
                              ? context.t.cardReceivedOn(
                                  longDate(widget.header.createdAt),
                                )
                              : context.t.cardsCreatedOn(
                                  _cards(_count),
                                  longDate(widget.header.createdAt),
                                ),
                          style: TextStyle(color: c.infoText, fontSize: 13.5),
                        ),
                        if (previous?.receivedAt != null)
                          Text(
                            context.t.alreadyReceivedOn(
                              longDate(previous!.receivedAt!),
                            ),
                            style: TextStyle(
                              color: c.infoText.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_single) ...[
                    GroupHeader(context.t.whichSection),
                    _sectionPicker(c),
                    const SizedBox(height: 12),
                  ] else ...[
                    GroupHeader(context.t.whereToPut),
                    _option(
                      c,
                      SharedImportMode.newSection,
                      context.t.newSection,
                      context.t.newSectionDetail,
                      extra: TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => _replan(),
                        decoration: InputDecoration(
                          labelText: context.t.nameNotUsedYet,
                          errorText: _nameTaken
                              ? context.t.nameAlreadyUsed
                              : null,
                        ),
                      ),
                    ),
                    _option(
                      c,
                      SharedImportMode.merge,
                      context.t.mergeIntoSection,
                      context.t.mergeIntoSectionDetail,
                      extra: _sectionPicker(c),
                    ),
                    if (previous != null)
                      _option(
                        c,
                        SharedImportMode.replace,
                        context.t.replaceSection(previous.name),
                        context.t.replaceSectionDetail,
                      ),
                    const SizedBox(height: 2),
                  ],
                  if (p != null) _outcome(c, p),
                  const SizedBox(height: 16),
                  Text(
                    _single
                        ? context.t.importedCardYours
                        : context.t.importedCardsYours,
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
                FilledButton(
                  onPressed: canImport ? _import : null,
                  child: Text(
                    _single
                        ? context.t.importTheCard
                        : _mode == SharedImportMode.replace
                        ? context.t.replace
                        : context.t.importCards(_cards(p?.added ?? _count)),
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
