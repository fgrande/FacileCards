import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart' as db;
import '../format_utils.dart';
import '../photos.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../transfer/archive_format.dart';
import '../transfer/crypto.dart';
import '../transfer/import.dart';
import '../ui.dart';

/// Legge e controlla il file scelto; gira in un isolate (il file può essere
/// grande). Funzione a sé: una funzione interna si porterebbe dietro lo stato
/// della schermata, che non può passare a un altro isolate.
typedef _ReadFile = ({
  ArchiveHeader header,
  ArchiveContent? content,
  Uint8List? encrypted,
});

Future<_ReadFile> _readArchiveFile(String path) async {
  final file = decodeArchive(await File(path).readAsBytes());
  if (file.header.encrypted) {
    return (header: file.header, content: null, encrypted: file.content);
  }
  return (
    header: file.header,
    content: decodeContent(file.content),
    encrypted: null,
  );
}

/// Decifra e legge il contenuto; anche questo in un isolate (la chiave
/// richiede circa un secondo di calcolo).
Future<ArchiveContent> _decryptArchive(
  ({Uint8List data, Map<String, Object?> params, String password}) a,
) async => decodeContent(await decryptContent(a.data, a.params, a.password));

/// "Importa tutto" da Sezioni → Archivio: scelta del file, lettura, poi la
/// schermata del riepilogo. Restituisce true se si è importato qualcosa.
Future<bool> startImportAll(
  BuildContext context,
  db.AppDatabase database,
) async {
  void fail(String text) {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Non si può importare'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  final dir = Directory('${(await getTemporaryDirectory()).path}/import');
  if (await dir.exists()) await dir.delete(recursive: true);
  await dir.create(recursive: true);
  final path = '${dir.path}/scelto$archiveExtension';
  try {
    // Si parte da dove si è salvato l'ultimo backup (decisione 112).
    final last = await database.setting(db.SettingKeys.lastBackupUri);
    if (!await openDocument(path: path, initialUri: last)) {
      return false; // annullato
    }
  } catch (_) {
    fail('Non sono riuscito a leggere il file. Potrebbe essere troppo grande.');
    return false;
  }

  // Lettura e controlli in un isolate: il file può essere grande.
  final _ReadFile read;
  try {
    read = await compute(_readArchiveFile, path);
  } on TransferException catch (e) {
    fail(e.message);
    return false;
  } catch (_) {
    fail('Non è un file di FacileCards, o è rovinato.');
    return false;
  } finally {
    await File(path).delete().catchError((_) => File(path));
  }
  if (read.header.kind != ArchiveKind.all) {
    fail(
      'Questo file contiene una sola sezione o una sola tessera, non una '
      'copia completa: si apre in un altro modo, che arriverà presto.',
    );
    return false;
  }
  var content = read.content;
  if (!context.mounted) return false;
  final encrypted = read.encrypted;
  if (content == null && encrypted != null) {
    // Videate 34 e 35: si chiede la password finché non è giusta.
    content = await Navigator.of(context).push<ArchiveContent>(
      MaterialPageRoute(
        builder: (_) =>
            PasswordScreen(header: read.header, encrypted: encrypted),
      ),
    );
    if (content == null || !context.mounted) return false;
  }
  final ready = content;
  if (ready == null) return false;
  final done = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) =>
          ImportScreen(database: database, header: read.header, content: ready),
    ),
  );
  return done == true;
}

/// Videate 29, 30, 31: riepilogo dell'archivio, unisci o sostituisci, esito
/// sul limite (decisione 102).
class ImportScreen extends StatefulWidget {
  const ImportScreen({
    super.key,
    required this.database,
    required this.header,
    required this.content,
  });

  final db.AppDatabase database;
  final ArchiveHeader header;
  final ArchiveContent content;

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  ImportMode _mode = ImportMode.merge;
  ImportPlan? _plan;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _replan();
  }

  Future<void> _replan() async {
    final plan = await planImport(widget.database, widget.content, _mode);
    if (mounted) setState(() => _plan = plan);
  }

  void _setMode(ImportMode m) {
    if (_busy || m == _mode) return;
    setState(() {
      _mode = m;
      _plan = null;
    });
    _replan();
  }

  String _cards(int n) => n == 1 ? '1 tessera' : '$n tessere';

  /// Cosa finisce nel cestino sostituendo (videata 31).
  String _trashText(ImportPlan p) {
    final kept = p.current - p.toTrash;
    if (p.toTrash == 0) {
      return 'Le tue tessere attuali sono tutte nel file: restano, con i dati del file.';
    }
    final trashed = switch ((p.toTrash, kept)) {
      (1, 0) => 'La tua tessera attuale finirà nel cestino',
      (_, 0) => 'Le tue ${p.toTrash} tessere attuali finiranno nel cestino',
      (1, _) => '1 tessera attuale finirà nel cestino',
      _ => '${p.toTrash} tessere attuali finiranno nel cestino',
    };
    final stays = p.toTrash == 1 ? 'e vi resterà' : 'e vi resteranno';
    final others = kept == 0
        ? ''
        : kept == 1
        ? " L'altra è anche nel file e resta."
        : ' Le altre $kept sono anche nel file e restano.';
    return '$trashed $stays per 30 giorni.$others';
  }

  /// Videata 31: seconda conferma per "Sostituisci tutto".
  Future<bool> _confirmReplace(ImportPlan p) async {
    final c = AppColors.of(context);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.error, color: c.danger, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sostituire tutte le tessere?',
                      style: TextStyle(color: c.text, fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Stai per sostituire ${_cards(p.current)} con ${p.incoming}.',
                style: TextStyle(color: c.text, fontSize: 15.5),
              ),
              const SizedBox(height: 8),
              Text(
                _trashText(p),
                style: TextStyle(color: c.muted, fontSize: 14),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.warnBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Le tessere del cestino non contano per il limite.',
                  style: TextStyle(color: c.warn, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: c.danger),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Sostituisci ${p.current} con ${p.incoming}'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annulla'),
              ),
            ],
          ),
        ),
      ),
    );
    return ok == true;
  }

  Future<void> _import() async {
    final p = _plan;
    if (p == null || !p.fits) return;
    if (_mode == ImportMode.replace &&
        p.current > 0 &&
        !await _confirmReplace(p)) {
      return;
    }
    setState(() => _busy = true);
    try {
      final n = await runImport(
        widget.database,
        await PhotoStore.instance,
        widget.content,
        _mode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            n == 1 ? 'Importata 1 tessera.' : 'Importate $n tessere.',
          ),
        ),
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

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Widget _modeOption(
    AppColors c,
    ImportMode mode,
    String title,
    String detail,
  ) {
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
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
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
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: TextStyle(color: c.muted, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Esito sul limite: verde se ci sta, rosso se no (videata 30).
  Widget _outcome(AppColors c, ImportPlan p) {
    final ok = p.fits;
    final String title;
    final String detail;
    if (!ok) {
      title = 'Con questa scelta saresti a ${p.result} tessere';
      detail =
          'Il limite della versione gratuita è ${p.limit}.\nCon Pro non hai limiti.';
    } else if (p.mode == ImportMode.merge && p.added == 0) {
      title = 'Tutte le tessere del file sono già presenti';
      detail = 'Non c\'è niente da aggiungere.';
    } else if (p.mode == ImportMode.merge) {
      title = p.alreadyPresent == 0
          ? 'Aggiunge ${p.added == 1 ? '1 tessera nuova' : '${p.added} tessere nuove'}'
          : 'Aggiunge ${p.added == 1 ? '1 tessera nuova' : '${p.added} tessere nuove'} '
                '(${p.alreadyPresent} già present${p.alreadyPresent == 1 ? 'e' : 'i'})';
      detail = 'Dopo l\'importazione: ${p.result} di ${p.limit} tessere';
    } else {
      title = 'Sostituisce ${_cards(p.current)} con ${p.incoming}';
      detail = 'Dopo l\'importazione: ${p.result} di ${p.limit} tessere';
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
                const SizedBox(height: 2),
                Text(detail, style: TextStyle(color: fg, fontSize: 13)),
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
    final content = widget.content;
    final p = _plan;
    final owner = content.owner;
    final sections = content.sections.length;
    final canImport =
        p != null &&
        p.fits &&
        !_busy &&
        !(p.mode == ImportMode.merge && p.added == 0);
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Importa tutto')),
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
                            Icon(Icons.folder_outlined, color: c.infoText),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                owner == null
                                    ? 'Archivio di FacileCards'
                                    : 'Archivio di $owner',
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
                          '${sections == 1 ? '1 sezione' : '$sections sezioni'} · '
                          '${_cards(content.cards.length)}',
                          style: TextStyle(color: c.infoText, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Creato il ${longDate(widget.header.createdAt)}',
                          style: TextStyle(
                            color: c.infoText.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const GroupHeader('Come importarle'),
                  _modeOption(
                    c,
                    ImportMode.merge,
                    'Unisci alle tessere esistenti',
                    'Aggiunge solo quelle che mancano. Consigliato.',
                  ),
                  _modeOption(
                    c,
                    ImportMode.replace,
                    'Sostituisci tutto',
                    'Le tessere attuali vanno nel cestino per 30 giorni.',
                  ),
                  const SizedBox(height: 10),
                  if (p != null) _outcome(c, p),
                  const SizedBox(height: 16),
                  Text(
                    'Se hai già ripristinato i dati con il backup di Android, '
                    'le tessere già presenti non vengono duplicate.',
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
                    p == null || !p.fits
                        ? 'Importa'
                        : p.mode == ImportMode.merge
                        ? (p.added == 0
                              ? 'Importa'
                              : 'Importa ${_cards(p.added)}')
                        : 'Sostituisci tutto',
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

/// Videate 34 e 35: file protetto da password. Restituisce il contenuto
/// decifrato; la password errata si può ritentare senza limiti
/// (decisione 103).
class PasswordScreen extends StatefulWidget {
  const PasswordScreen({
    super.key,
    required this.header,
    required this.encrypted,
  });

  final ArchiveHeader header;
  final Uint8List encrypted;

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _password = TextEditingController();
  bool _show = false;
  bool _busy = false;
  bool _wrong = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    setState(() {
      _busy = true;
      _wrong = false;
    });
    try {
      final content = await compute(_decryptArchive, (
        data: widget.encrypted,
        params: widget.header.encryption!,
        password: _password.text,
      ));
      if (mounted) Navigator.of(context).pop(content);
    } on WrongPasswordException {
      if (mounted) setState(() => _wrong = true);
    } on TransferException catch (e) {
      _fail(e.message);
    } catch (_) {
      _fail('Il file protetto è rovinato.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _fail(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Importa tutto')),
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
                          Icon(Icons.lock_outline, color: c.infoText),
                          const SizedBox(width: 10),
                          Text(
                            'File protetto da password',
                            style: TextStyle(
                              color: c.infoText,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Creato il ${longDate(widget.header.createdAt)}',
                        style: TextStyle(color: c.infoText, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Inserisci la password scelta da chi ha creato il file.',
                  style: TextStyle(color: c.muted, fontSize: 14.5),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _password,
                  autofocus: true,
                  obscureText: !_show,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (_) => setState(() => _wrong = false),
                  onSubmitted: (_) {
                    if (_password.text.isNotEmpty && !_busy) _open();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _wrong
                        ? 'Password errata. Controlla e riprova.'
                        : null,
                    suffixIcon: IconButton(
                      tooltip: _show ? 'Nascondi' : 'Mostra',
                      icon: Icon(
                        _show
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(() => _show = !_show),
                    ),
                  ),
                ),
                if (_wrong) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Il file non è stato modificato. Puoi riprovare.',
                    style: TextStyle(color: c.muted, fontSize: 13.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            // A campo vuoto il pulsante resta spento (decisione 103).
            onPressed: _password.text.isEmpty || _busy ? null : _open,
            child: Text(_busy ? 'Apertura…' : 'Apri il file'),
          ),
        ),
      ),
    );
  }
}
