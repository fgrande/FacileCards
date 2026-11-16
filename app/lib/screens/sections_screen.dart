import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import 'trash_screen.dart';

/// Videate 12, 36, 37, 38: le sezioni e l'accesso al cestino.
class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key, required this.database});

  final db.AppDatabase database;

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  List<db.Section> _sections = const [];
  Map<String, int> _counts = const {};
  int _trash = 0;

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
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    final counts = await d.sectionCounts();
    final trash = await d.trashCount();
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _counts = counts;
      _trash = trash;
    });
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _create() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NameDialog(title: 'Nuova sezione'),
    );
    if (name == null) return;
    final ok = await widget.database.createSection(name);
    if (!ok) _message('Scrivi un nome che non sia già usato da un\'altra sezione.');
    _load();
  }

  Future<void> _rename(db.Section s) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(title: 'Rinomina sezione', initial: s.name),
    );
    if (name == null) return;
    final ok = await widget.database.renameSection(s.id, name);
    if (!ok) _message('Scrivi un nome che non sia già usato da un\'altra sezione.');
    _load();
  }

  Future<void> _delete(db.Section s) async {
    final n = _counts[s.id] ?? 0;
    if (n == 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Eliminare «${s.name}»?'),
          content: const Text('La sezione è vuota.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Elimina'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Sezioni')),
      body: ListView(
        children: [
          for (final s in _sections)
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(s.name),
              subtitle: Text(s.isDefault
                  ? '${_counts[s.id] ?? 0} tessere · non eliminabile'
                  : ((_counts[s.id] ?? 0) == 0
                      ? 'Vuota'
                      : '${_counts[s.id]} tessere')),
              trailing: PopupMenuButton<String>(
                onSelected: (v) => v == 'rename' ? _rename(s) : _delete(s),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'rename', child: Text('Rinomina')),
                  if (!s.isDefault)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Elimina sezione'),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('ARCHIVIO', style: Theme.of(context).textTheme.labelMedium),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Cestino'),
            subtitle: Text('$_trash tessere · eliminate dopo ${db.AppDatabase.trashDays} giorni'),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TrashScreen(database: widget.database),
                ),
              );
              _load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('Nuova sezione'),
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
        title: const Text('Sezione'),
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
    final tessere = n == 1 ? '1 tessera' : '$n tessere';
    return AlertDialog(
      title: Text('Eliminare «${widget.section.name}»?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('La sezione contiene $tessere. Cosa ne facciamo?'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_move ? Icons.radio_button_checked : Icons.radio_button_off),
            title: const Text('Sposta le tessere in un\'altra sezione'),
            subtitle: _move ? Text('Sezione: ${_target.name}') : null,
            onTap: () => setState(() => _move = true),
          ),
          if (_move)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _chooseTarget,
                child: const Text('Cambia sezione'),
              ),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(!_move ? Icons.radio_button_checked : Icons.radio_button_off),
            title: const Text('Elimina anche le tessere'),
            subtitle: const Text('Restano 30 giorni nel cestino.'),
            onTap: () => setState(() => _move = false),
          ),
          const SizedBox(height: 8),
          Text(
            _move
                ? 'Risultato: $tessere in ${_target.name}'
                : 'Risultato: $tessere nel cestino',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_DeleteChoice(_move ? _target.id : null)),
          child: const Text('Elimina sezione'),
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
        decoration: const InputDecoration(hintText: 'Es. Famiglia'),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
