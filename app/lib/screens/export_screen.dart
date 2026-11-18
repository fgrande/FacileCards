import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart' as db;
import '../photos.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../transfer/export.dart';

/// Videate 32 e 33: "Esporta tutto" in due passi (doppia conferma,
/// decisioni 68 e 69). Restituisce true se la copia è stata salvata o
/// condivisa.
class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key, required this.database});

  final db.AppDatabase database;

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  int _step = 1;
  bool _understood = false;
  bool _busy = false;
  ExportSummary? _summary;
  PhotoStore? _store;

  db.AppDatabase get _db => widget.database;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = await PhotoStore.instance;
    final summary = await exportSummary(_db, store);
    if (mounted) {
      setState(() {
        _store = store;
        _summary = summary;
      });
    }
  }

  /// Tornando al passo 1 la conferma "Ho capito" si ridà da capo.
  void _backToStepOne() => setState(() {
        _step = 1;
        _understood = false;
      });

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  /// Costruisce il file nella cartella temporanea `export/` (svuotata prima).
  Future<String> _prepareFile(String name) async {
    final dir = Directory('${(await getTemporaryDirectory()).path}/export');
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    final bytes = await buildBackupFile(_db, _store!);
    return writeTempFile(dir, name, bytes);
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final name = backupFileName(DateTime.now());
      final path = await _prepareFile(name);
      final uri = await saveDocument(
        path: path,
        name: name,
        initialUri: await _db.setting(db.SettingKeys.lastBackupUri),
      );
      if (uri == null) return; // annullato nel selettore
      await _db.setSetting(db.SettingKeys.lastBackupUri, uri);
      await _db.setSetting(
          db.SettingKeys.lastBackupAt, DateTime.now().toIso8601String());
      if (!mounted) return;
      _message('Copia salvata.');
      Navigator.of(context).pop(true);
    } catch (_) {
      _message('Non sono riuscito a salvare la copia. Riprova.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final path = await _prepareFile(backupFileName(DateTime.now()));
      await shareFile(
        path: path,
        title: 'Salva la copia delle tessere',
        text: 'Copia di tutte le mie tessere di FacileCards. '
            'Si apre con l\'app FacileCards, da "Importa tutto".',
      );
      // Non si sa se l'altra app salverà davvero: la si conta come copia fatta.
      await _db.setSetting(
          db.SettingKeys.lastBackupAt, DateTime.now().toIso8601String());
    } catch (_) {
      _message('Non sono riuscito a preparare la copia. Riprova.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _progress(AppColors c) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (var i = 1; i <= 2; i++) ...[
                  if (i > 1) const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: i <= _step ? c.primary : c.segment,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text('Passo $_step di 2',
                style: TextStyle(color: c.muted, fontSize: 12.5)),
          ],
        ),
      );

  Widget _point(AppColors c, String title, String detail) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 14, left: 6),
              child: Container(
                width: 9,
                height: 9,
                decoration:
                    BoxDecoration(color: c.warn, shape: BoxShape.circle),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: c.text, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(color: c.muted, fontSize: 13.5)),
                ],
              ),
            ),
          ],
        ),
      );

  /// Passo 1 (videata 32): cosa contiene il file e come custodirlo.
  Widget _stepOne(AppColors c) {
    final s = _summary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.infoBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_outlined, color: c.infoText),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tutte le tue tessere',
                        style: TextStyle(
                            color: c.infoText,
                            fontSize: 17,
                            fontWeight: FontWeight.w500)),
                    Text(
                      s == null
                          ? '…'
                          : '${s.cards == 1 ? '1 tessera' : '${s.cards} tessere'} · '
                              '${s.sections == 1 ? '1 sezione' : '${s.sections} sezioni'} · '
                              '${sizeLabel(s.bytes)}',
                      style: TextStyle(color: c.infoText, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text('Stai per creare una copia di tutte le tue tessere',
            style: TextStyle(color: c.text, fontSize: 20)),
        const SizedBox(height: 22),
        _point(c, 'Il file contiene tutto', 'Codici, intestatari, note e foto.'),
        _point(c, 'Chi lo apre può usare le tessere',
            'Alla cassa valgono come le tue.'),
        _point(c, 'Conservalo in un posto sicuro',
            'Un archivio personale, non una chat.'),
      ],
    );
  }

  /// Passo 2 (videata 33): "Ho capito", poi salva o condividi.
  Widget _stepTwo(AppColors c) {
    final n = _summary?.cards ?? 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _understood = !_understood),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _understood ? c.primary : c.border,
                  width: _understood ? 1.6 : 1),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _understood,
                  onChanged: (v) => setState(() => _understood = v ?? false),
                ),
                Expanded(
                  child: Text(
                    'Ho capito: sto esportando '
                    '${n == 1 ? '1 tessera' : '$n tessere'} in un unico file.',
                    style: TextStyle(color: c.text, fontSize: 15.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final ready = _summary != null && !_busy;
    return PopScope(
      canPop: _step == 1 && !_busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == 2 && !_busy) _backToStepOne();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Esporta tutto')),
        body: Column(
          children: [
            _progress(c),
            if (_busy) const LinearProgressIndicator(),
            Expanded(child: _step == 1 ? _stepOne(c) : _stepTwo(c)),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _step == 1
                  ? [
                      FilledButton(
                        onPressed:
                            ready ? () => setState(() => _step = 2) : null,
                        child: const Text('Continua'),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annulla'),
                      ),
                    ]
                  : [
                      FilledButton(
                        onPressed: ready && _understood ? _save : null,
                        child: const Text('Salva sul telefono'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: ready && _understood ? _share : null,
                        child: const Text('Condividi…'),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _busy ? null : _backToStepOne,
                        child: const Text('Indietro'),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
