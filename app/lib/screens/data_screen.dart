import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../theme.dart';
import '../ui.dart';
import 'export_screen.dart';
import 'import_screen.dart';
import 'trash_screen.dart';

/// Videata 12b (decisione 114): copia, importazione e cestino, separati dalla
/// gestione delle sezioni.
class DataScreen extends StatefulWidget {
  const DataScreen({super.key, required this.database});

  final db.AppDatabase database;

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  int _cards = 0;
  int _trash = 0;
  DateTime? _lastBackup;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = widget.database;
    final cards = await d.activeCardCount();
    final trash = await d.trashCount();
    final last = DateTime.tryParse(
      await d.setting(db.SettingKeys.lastBackupAt) ?? '',
    );
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _trash = trash;
      _lastBackup = last;
    });
  }

  @override
  Widget build(BuildContext context) {
    String count(int n) => n == 1 ? '1 tessera' : '$n tessere';
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);
    return Scaffold(
      appBar: AppBar(title: const Text('Dati')),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: [
          const GroupHeader('Archivio'),
          TileGroup(
            indent: 74,
            children: [
              ListTile(
                contentPadding: padding,
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
                contentPadding: padding,
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
            ],
          ),
          if (_cards > 0) _backupReminder(),
          const GroupHeader('Tessere eliminate'),
          TileGroup(
            indent: 74,
            children: [
              ListTile(
                contentPadding: padding,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
