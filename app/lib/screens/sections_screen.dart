import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../data/sort_key.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../ui.dart';
import '../transfer/export.dart' show ExportTarget;
import 'export_screen.dart';

/// Videate 12, 36, 37, 38: le sezioni (copia, importazione e cestino stanno
/// in "Dati", decisione 114).
class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key, required this.database});

  final db.AppDatabase database;

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  List<db.Section> _sections = const [];
  Map<String, int> _counts = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = widget.database;
    final sections = await d.visibleSections();
    sections.sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      return compareNames(a.name, b.name);
    });
    final counts = await d.sectionCounts();
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _counts = counts;
    });
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _create() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(title: context.t.newSection),
    );
    if (name == null) return;
    final ok = await widget.database.createSection(name);
    if (!ok) {
      _message(tr.sectionNameTaken);
    }
    _load();
  }

  /// Videate 9 e 10: condivisione della sezione.
  Future<void> _share(db.Section s) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ExportScreen(
        database: widget.database,
        target: ExportTarget.section(s.id),
        name: s.name,
      ),
    ),
  );

  Future<void> _rename(db.Section s) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          _NameDialog(title: context.t.renameSection, initial: s.name),
    );
    if (name == null) return;
    final ok = await widget.database.renameSection(s.id, name);
    if (!ok) {
      _message(tr.sectionNameTaken);
    }
    _load();
  }

  Future<void> _delete(db.Section s) async {
    final n = _counts[s.id] ?? 0;
    if (n == 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.t.deleteQuestion(s.name)),
          content: Text(context.t.sectionEmpty),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.t.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.t.delete),
            ),
          ],
        ),
      );
      if (ok == true) await widget.database.deleteSection(s.id);
    } else {
      final choice = await showDialog<_DeleteChoice>(
        context: context,
        builder: (_) => _DeleteSectionDialog(
          section: s,
          count: n,
          others: _sections.where((x) => x.id != s.id).toList(),
        ),
      );
      if (choice != null) {
        await widget.database.deleteSection(s.id, moveTo: choice.moveTo);
      }
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    String count(int n) => context.t.cardCount(n);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.menuSections),
        actions: [
          IconButton(
            tooltip: context.t.newSection,
            icon: const Icon(Icons.add, size: 30),
            onPressed: _create,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: [
          TileGroup(
            indent: 74,
            children: [
              for (final s in _sections)
                ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                  leading: const IconTile(Icons.folder_outlined, accent: true),
                  title: Text(s.name),
                  subtitle: Text(
                    s.isDefault
                        ? context.t.notDeletable(count(_counts[s.id] ?? 0))
                        : ((_counts[s.id] ?? 0) == 0
                              ? context.t.emptySection
                              : count(_counts[s.id]!)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((_counts[s.id] ?? 0) > 0)
                        IconButton(
                          tooltip: context.t.share,
                          icon: Icon(
                            Icons.share,
                            color: AppColors.of(context).primary,
                          ),
                          onPressed: () => _share(s),
                        ),
                      PopupMenuButton<String>(
                        onSelected: (v) => switch (v) {
                          'share' => _share(s),
                          'rename' => _rename(s),
                          _ => _delete(s),
                        },
                        itemBuilder: (_) => [
                          if ((_counts[s.id] ?? 0) > 0)
                            PopupMenuItem(
                              value: 'share',
                              child: Text(context.t.share),
                            ),
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(context.t.rename),
                          ),
                          if (!s.isDefault)
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(context.t.deleteSection),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeleteChoice {
  const _DeleteChoice(this.moveTo);

  /// Sezione di destinazione; null = le tessere vanno nel cestino.
  final String? moveTo;
}

/// Videata 37: cosa fare delle tessere di una sezione che si elimina.
class _DeleteSectionDialog extends StatefulWidget {
  const _DeleteSectionDialog({
    required this.section,
    required this.count,
    required this.others,
  });

  final db.Section section;
  final int count;
  final List<db.Section> others;

  @override
  State<_DeleteSectionDialog> createState() => _DeleteSectionDialogState();
}

class _DeleteSectionDialogState extends State<_DeleteSectionDialog> {
  bool _move = true;
  late db.Section _target = widget.others.firstWhere(
    (s) => s.isDefault,
    orElse: () => widget.others.first,
  );

  Future<void> _chooseTarget() async {
    final chosen = await showDialog<db.Section>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.t.section),
        children: [
          for (final s in widget.others)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(s),
              child: Text(s.name),
            ),
        ],
      ),
    );
    if (chosen != null && mounted) setState(() => _target = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.count;
    final tessere = context.t.cardCount(n);
    return AlertDialog(
      title: Text(context.t.deleteQuestion(widget.section.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.sectionContains(tessere)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              _move ? Icons.radio_button_checked : Icons.radio_button_off,
            ),
            title: Text(context.t.moveCardsToOtherSection),
            subtitle: _move ? Text(context.t.sectionIs(_target.name)) : null,
            onTap: () => setState(() => _move = true),
          ),
          if (_move)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _chooseTarget,
                child: Text(context.t.changeSection),
              ),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              !_move ? Icons.radio_button_checked : Icons.radio_button_off,
            ),
            title: Text(context.t.deleteCardsToo),
            subtitle: Text(context.t.staysInTrash(db.AppDatabase.trashDays)),
            onTap: () => setState(() => _move = false),
          ),
          const SizedBox(height: 8),
          Text(
            _move
                ? context.t.resultIn(tessere, _target.name)
                : context.t.resultInTrash(tessere),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.cancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context)
                  .pop(_DeleteChoice(_move ? _target.id : null)),
          child: Text(context.t.deleteSection),
        ),
      ],
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, this.initial = ''});

  final String title;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: context.t.sectionNameHint),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(context.t.save),
        ),
      ],
    );
  }
}
