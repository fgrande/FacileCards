import 'package:material_ui/material_ui.dart';

import '../ads.dart';
import '../backup_size.dart';
import '../data/database.dart' as db;
import '../l10n/l10n.dart';
import '../theme.dart';
import '../transfer/export.dart' show sizeValue;
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
  int _backupBytes = 0;

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
    final bytes = await backupSizeBytes();
    if (!mounted) return;
    setState(() {
      _backupBytes = bytes;
      _cards = cards;
      _trash = trash;
      _lastBackup = last;
    });
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);
    return Scaffold(
      appBar: AppBar(title: Text(context.t.dataTitle)),
      bottomNavigationBar: AdFooter(unitId: AdUnits.data, medium: true),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: [
          GroupHeader(context.t.archive),
          TileGroup(
            indent: 74,
            children: [
              ListTile(
                contentPadding: padding,
                leading: const IconTile(Icons.upload_outlined),
                title: Text(context.t.exportAll),
                subtitle: Text(context.t.exportAllSubtitle),
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
                title: Text(context.t.importFromFile),
                subtitle: Text(context.t.importFromFileSubtitle),
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
          if (_backupBytes > androidBackupWarnBytes) _backupTooBig(),
          GroupHeader(context.t.deletedCards),
          TileGroup(
            indent: 74,
            children: [
              ListTile(
                contentPadding: padding,
                leading: const IconTile(Icons.delete_outline),
                title: Text(context.t.trash),
                subtitle: Text(
                  context.t.trashSubtitle(
                    context.t.cardCount(_trash),
                    db.AppDatabase.trashDays,
                  ),
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

  /// Avviso: oltre 25 MB Android non salva l'app nel suo backup
  /// (decisione 93).
  Widget _backupTooBig() {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.dangerBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          context.t.androidBackupTooBig(sizeValue(_backupBytes)),
          style: TextStyle(color: c.danger, fontSize: 13.5, height: 1.5),
        ),
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
      when = context.t.noBackupYet;
    } else {
      final days = DateTime.now().difference(last).inDays;
      when = days == 0
          ? context.t.lastCopyToday
          : days == 1
          ? context.t.lastCopyYesterday
          : context.t.lastCopyDaysAgo(days);
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
          context.t.onlyOnThisPhone(when),
          style: TextStyle(color: c.warn, fontSize: 13.5, height: 1.5),
        ),
      ),
    );
  }
}
