import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart' as db;
import '../photos.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../links.dart';
import '../transfer/archive_format.dart';
import '../transfer/crypto.dart';
import '../transfer/export.dart';
import '../ui.dart';

/// "Esporta tutto" (videate 32, 33) e condivisione di una sezione o di una
/// tessera (videate 9, 10), in due passi (doppia conferma, decisioni 68 e
/// 69). Restituisce true se la copia è stata salvata o condivisa.
class ExportScreen extends StatefulWidget {
  const ExportScreen({
    super.key,
    required this.database,
    this.target = const ExportTarget.all(),
    this.name = '',
  });

  final db.AppDatabase database;
  final ExportTarget target;

  /// Nome della sezione o della tessera condivisa.
  final String name;

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

  bool get _backup => widget.target.kind == ArchiveKind.all;
  bool get _single => widget.target.kind == ArchiveKind.card;

  String get _title => switch (widget.target.kind) {
    ArchiveKind.all => 'Esporta tutto',
    ArchiveKind.section => 'Condividi sezione',
    ArchiveKind.card => 'Condividi tessera',
  };

  String _cards(int n) => n == 1 ? '1 tessera' : '$n tessere';

  /// Messaggio che accompagna il file condiviso (decisione 64).
  String get _shareMessage => _single
      ? 'Ti invio la tessera «${widget.name}».\n'
            'Per aprirla serve FacileCards:\n$storeUrl'
      : 'Ti invio le tessere della sezione «${widget.name}».\n'
            'Per aprirle serve FacileCards:\n$storeUrl';

  String get _fileName =>
      _backup ? backupFileName(DateTime.now()) : sharedFileName(widget.name);

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
    final summary = await exportSummary(_db, store, widget.target);
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
    final bytes = await buildExportFile(
      _db,
      _store!,
      widget.target,
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
      final path = await _prepareFile(_fileName);
      if (!_backup) {
        await shareFile(path: path, title: _title, text: _shareMessage);
        return;
      }
      await shareFile(
        path: path,
        title: 'Salva la copia delle tessere',
        text:
            'Copia di tutte le mie tessere di FacileCards. '
            'Si apre con l\'app FacileCards, da "Importa da file".',
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
              Icon(
                _single ? Icons.credit_card : Icons.folder_outlined,
                color: c.infoText,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _backup ? 'Tutte le tue tessere' : widget.name,
                      style: TextStyle(
                        color: c.infoText,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      s == null
                          ? '…'
                          : _backup
                          ? '${_cards(s.cards)} · '
                                '${s.sections == 1 ? '1 sezione' : '${s.sections} sezioni'} · '
                                '${sizeLabel(s.bytes)}'
                          : _single
                          ? 'Tessera · ${sizeLabel(s.bytes)}'
                          : '${_cards(s.cards)} · ${sizeLabel(s.bytes)}',
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
          _backup
              ? 'Stai per creare una copia di tutte le tue tessere'
              : _single
              ? 'Stai per consegnare questa tessera ad altre persone'
              : 'Stai per consegnare queste tessere ad altre persone',
          style: TextStyle(color: c.text, fontSize: 20),
        ),
        const SizedBox(height: 22),
        if (!_backup)
          ..._sharePoints(c)
        else ...[
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
        if (!_backup && (s?.bytes ?? 0) > largeShareBytes) _largeWarning(c, s!),
      ],
    );
  }

  /// Videata 9: cosa comporta consegnare le tessere ad altri (decisione 68).
  List<Widget> _sharePoints(AppColors c) => [
    _point(
      c,
      _single
          ? 'Chi riceve il file può usare la tessera'
          : 'Chi riceve il file può usare le tessere',
      'Alla cassa valgono come le tue.',
    ),
    _point(
      c,
      _single ? 'Vede tutto ciò che contiene' : 'Vede tutto ciò che contengono',
      'Codici, intestatario, note e foto.',
    ),
    _point(c, 'Può inoltrarlo a chiunque', 'FacileCards non può impedirlo.'),
    _point(
      c,
      'Non puoi ritirarlo',
      'Una volta inviato, il file non è più tuo.',
    ),
  ];

  /// File grande: si avvisa prima di condividere (decisione 92).
  Widget _largeWarning(AppColors c, ExportSummary s) => Container(
    margin: const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: c.warnBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      'Il file è grande (${sizeLabel(s.bytes)}), soprattutto per le foto: '
      'alcune app potrebbero non riuscire a inviarlo.',
      style: TextStyle(color: c.warn, fontSize: 13.5, height: 1.4),
    ),
  );

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
                    _backup
                        ? 'Ho capito: sto esportando ${_cards(n)} in un unico file.'
                        : _single
                        ? 'Ho capito: sto condividendo la tessera «${widget.name}» '
                              'con le persone a cui invierò il file.'
                        : 'Ho capito: sto condividendo ${_cards(n)} della sezione '
                              '«${widget.name}» con le persone a cui invierò il file.',
                    style: TextStyle(color: c.text, fontSize: 15.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!_backup) ...[
          const GroupHeader('Messaggio che accompagna il file'),
          _messagePreview(c),
        ],
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
        if (!_backup) ...[
          const SizedBox(height: 16),
          Text(
            'Si aprirà il pannello di condivisione del telefono: '
            'scegli tu l\'app e il destinatario.',
            style: TextStyle(color: c.muted, fontSize: 13.5),
          ),
        ],
      ],
    );
  }

  /// Anteprima del messaggio e del file (videata 10).
  Widget _messagePreview(AppColors c) {
    final s = _summary;
    return Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _shareMessage,
            style: TextStyle(color: c.text, fontSize: 14.5, height: 1.45),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.segment,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  color: c.muted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _fileName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.text, fontSize: 14),
                  ),
                ),
                if (s != null)
                  Text(
                    sizeLabel(s.bytes).replaceFirst('circa ', ''),
                    style: TextStyle(color: c.muted, fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
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
            subtitle: Text(
              _backup
                  ? 'Facoltativa.'
                  : 'Facoltativa: chi apre il file dovrà inserirla.',
            ),
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
        appBar: AppBar(title: Text(_title)),
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
                        // Una sezione vuota non si condivide.
                        onPressed: ready && _summary!.cards > 0
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
                      if (_backup) ...[
                        FilledButton(
                          onPressed: ready && _canExport ? _save : null,
                          child: const Text('Salva sul telefono'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: ready && _canExport ? _share : null,
                          child: const Text('Condividi…'),
                        ),
                      ] else
                        FilledButton(
                          onPressed: ready && _canExport ? _share : null,
                          child: const Text('Condividi'),
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
