import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../theme.dart';
import '../ui.dart';
import '../transfer/export.dart' show ExportTarget;
import 'export_screen.dart';
import 'import_screen.dart';
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
  DateTime? _lastBackup;

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
    final last = DateTime.tryParse(
      await d.setting(db.SettingKeys.lastBackupAt) ?? '',
    );
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _counts = counts;
      _trash = trash;
      _lastBackup = last;
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
    if (!ok) {
      _message('Scrivi un nome che non sia già usato da un\'altra sezione.');
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
      builder: (_) => _NameDialog(title: 'Rinomina sezione', initial: s.name),
    );
    if (name == null) return;
    final ok = await widget.database.renameSection(s.id, name);
    if (!ok) {
      _message('Scrivi un nome che non sia già usato da un\'altra sezione.');
    }
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
    String count(int n) => n == 1 ? '1 tessera' : '$n tessere';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sezioni'),
        actions: [
          IconButton(
            tooltip: 'Nuova sezione',
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
                        ? '${count(_counts[s.id] ?? 0)} · non eliminabile'
                        : ((_counts[s.id] ?? 0) == 0
                              ? 'Vuota'
                              : count(_counts[s.id]!)),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => switch (v) {
                      'share' => _share(s),
                      'rename' => _rename(s),
                      _ => _delete(s),
                    },
                    itemBuilder: (_) => [
                      if ((_counts[s.id] ?? 0) > 0)
                        const PopupMenuItem(
                          value: 'share',
                          child: Text('Condividi'),
                        ),
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Rinomina'),
                      ),
                      if (!s.isDefault)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Elimina sezione'),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const GroupHeader('Archivio'),
          TileGroup(
            indent: 74,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: const IconTile(Icons.upload_outlined),
                title: const Text('Esporta tutto'),
                subtitle: const Text('Salva una copia di tutte le tessere'),
                trailing: const Chevron(),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExportScreen(database: widget.database),
                    ),
                  );
                  _load();
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: const IconTile(Icons.download_outlined),
                title: const Text('Importa da file'),
                subtitle: const Text(
                  'Una copia completa, una sezione o una tessera',
                ),
                trailing: const Chevron(),
                onTap: () async {
                  if (await startImportFromFile(context, widget.database)) {
                    _load();
                  }
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: const IconTile(Icons.delete_outline),
                title: const Text('Cestino'),
                subtitle: Text(
                  '${count(_trash)} · eliminate dopo ${db.AppDatabase.trashDays} giorni',
                ),
                trailing: const Chevron(),
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
          if (_counts.values.fold(0, (a, b) => a + b) > 0) _backupReminder(),
        ],
      ),
    );
  }

  /// Promemoria discreto della copia (analisi, 5.5): senza cloud le tessere
  /// esistono solo su questo telefono.
  Widget _backupReminder() {
    final c = AppColors.of(context);
    final last = _lastBackup;
    String when;
    if (last == null) {
      when = 'Non hai ancora fatto una copia.';
    } else {
      final days = DateTime.now().difference(last).inDays;
      when = days == 0
          ? 'Ultima copia: oggi.'
          : days == 1
          ? 'Ultima copia: ieri.'
          : 'Ultima copia: $days giorni fa.';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.warnBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Le tue tessere esistono solo su questo telefono.\n$when',
          style: TextStyle(color: c.warn, fontSize: 13.5, height: 1.5),
        ),
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
            leading: Icon(
              _move ? Icons.radio_button_checked : Icons.radio_button_off,
            ),
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
            leading: Icon(
              !_move ? Icons.radio_button_checked : Icons.radio_button_off,
            ),
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
              Navigator.of(context)
                  .pop(_DeleteChoice(_move ? _target.id : null)),
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
