import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart' as db;
import '../photos.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../transfer/crypto.dart';
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
  bool _protect = false;
  bool _showPassword = false;
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _busy = false;
  ExportSummary? _summary;
  PhotoStore? _store;

  db.AppDatabase get _db => widget.database;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  String? get _passwordProblem =>
      _protect ? passwordProblem(_password.text, _repeat.text) : null;

  /// Si può salvare: "Ho capito" segnato e, se c'è, password valida.
  bool get _canExport => _understood && _passwordProblem == null;

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
    final bytes = await buildBackupFile(
      _db,
      _store!,
      password: _protect ? _password.text : null,
    );
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
        db.SettingKeys.lastBackupAt,
        DateTime.now().toIso8601String(),
      );
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
        text:
            'Copia di tutte le mie tessere di FacileCards. '
            'Si apre con l\'app FacileCards, da "Importa tutto".',
      );
      // Non si sa se l'altra app salverà davvero: la si conta come copia fatta.
      await _db.setSetting(
        db.SettingKeys.lastBackupAt,
        DateTime.now().toIso8601String(),
      );
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
        Text(
          'Passo $_step di 2',
          style: TextStyle(color: c.muted, fontSize: 12.5),
        ),
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
            decoration: BoxDecoration(color: c.warn, shape: BoxShape.circle),
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
                    Text(
                      'Tutte le tue tessere',
                      style: TextStyle(
                        color: c.infoText,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
        Text(
          'Stai per creare una copia di tutte le tue tessere',
          style: TextStyle(color: c.text, fontSize: 20),
        ),
        const SizedBox(height: 22),
        _point(
          c,
          'Il file contiene tutto',
          'Codici, intestatari, note e foto.',
        ),
        _point(
          c,
          'Chi lo apre può usare le tessere',
          'Alla cassa valgono come le tue.',
        ),
        _point(
          c,
          'Conservalo in un posto sicuro',
          'Un archivio personale, non una chat.',
        ),
        _point(
          c,
          'Puoi proteggerlo con una password',
          'Al prossimo passaggio, se vuoi.',
        ),
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
                width: _understood ? 1.6 : 1,
              ),
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
        const SizedBox(height: 14),
        _passwordPanel(c),
        if (_protect) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.warnBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Se la dimentichi non potrai riaprire il file.\n'
              'Nessuno può recuperarla, nemmeno noi.',
              style: TextStyle(color: c.warn, fontSize: 13.5, height: 1.4),
            ),
          ),
        ],
      ],
    );
  }

  Widget _passwordField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        obscureText: !_showPassword,
        enableSuggestions: false,
        autocorrect: false,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            tooltip: _showPassword ? 'Nascondi' : 'Mostra',
            icon: Icon(
              _showPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ),
      );

  /// Password facoltativa (decisione 103): due volte, almeno 8 caratteri.
  Widget _passwordPanel(AppColors c) {
    final problem = _passwordProblem;
    final typed = _password.text.isNotEmpty || _repeat.text.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Proteggi con password',
              style: TextStyle(color: c.text, fontSize: 16.5),
            ),
            subtitle: const Text('Facoltativa.'),
            value: _protect,
            onChanged: _busy ? null : (v) => setState(() => _protect = v),
          ),
          if (_protect) ...[
            const SizedBox(height: 6),
            _passwordField(_password, 'Password'),
            const SizedBox(height: 10),
            _passwordField(_repeat, 'Ripeti la password'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: problem == null ? c.successBg : c.segment,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    problem == null ? Icons.check : Icons.info_outline,
                    size: 20,
                    color: problem == null
                        ? c.success
                        : (typed ? c.danger : c.muted),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      problem == null
                          ? 'Password uguali · almeno $minPasswordLength caratteri'
                          : (typed
                                ? problem
                                : 'Almeno $minPasswordLength caratteri, scritta due volte.'),
                      style: TextStyle(
                        color: problem == null
                            ? c.success
                            : (typed ? c.danger : c.muted),
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
                        onPressed: ready
                            ? () => setState(() => _step = 2)
                            : null,
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
                        onPressed: ready && _canExport ? _save : null,
                        child: const Text('Salva sul telefono'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: ready && _canExport ? _share : null,
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
