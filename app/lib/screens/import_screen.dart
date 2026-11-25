import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart' as db;
import '../format_utils.dart';
import '../l10n/l10n.dart';
import '../photos.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../transfer/archive_format.dart';
import '../transfer/crypto.dart';
import '../transfer/import.dart';
import '../ui.dart';
import 'shared_import_screen.dart';

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

void _fail(BuildContext context, String text) {
  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.t.cannotImport),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.close),
        ),
      ],
    ),
  );
}

/// "Importa da file" (Sezioni → Archivio): scelta del file con il selettore
/// di Android, poi [openArchiveFile]. Restituisce true se si è importato
/// qualcosa.
Future<bool> startImportFromFile(
  BuildContext context,
  db.AppDatabase database,
) async {
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
    if (context.mounted) {
      _fail(
        context,
        context.t.fileReadFailedMaybeBig,
      );
    }
    return false;
  }
  if (!context.mounted) return false;
  return openArchiveFile(context, database, path);
}

/// "Apri con FacileCards" (tappa 3): se un'altra app ha passato un file, lo
/// apre come "Importa da file". Restituisce true se si è importato qualcosa.
Future<bool> openIncomingFile(
  BuildContext context,
  db.AppDatabase database,
) async {
  final ({String? path, String? error})? incoming;
  try {
    incoming = await takeIncomingFile();
  } catch (_) {
    return false;
  }
  if (incoming == null || !context.mounted) return false;
  final path = incoming.path;
  if (path == null) {
    _fail(
      context,
      incoming.error == 'too_big'
          ? context.t.transferTooBig
          : context.t.fileReadFailed,
    );
    return false;
  }
  return openArchiveFile(context, database, path);
}

/// Apre un file `.facilecards` già copiato in [path] (che poi si cancella):
/// lo legge, chiede la password se serve (videate 34, 35) e apre la
/// schermata giusta per il tipo di file: copia completa (29–31), sezione
/// (11) o tessera (decisione 107).
Future<bool> openArchiveFile(
  BuildContext context,
  db.AppDatabase database,
  String path,
) async {
  // Lettura e controlli in un isolate: il file può essere grande.
  final _ReadFile read;
  try {
    read = await compute(_readArchiveFile, path);
  } on TransferException catch (e) {
    if (context.mounted) _fail(context, e.message);
    return false;
  } catch (_) {
    if (context.mounted) {
      _fail(context, context.t.transferNotFacileCardsOrDamaged);
    }
    return false;
  } finally {
    await File(path).delete().catchError((_) => File(path));
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
  final kind = read.header.kind;
  // Un file di sezione ha una sola sezione; uno di tessera una sola tessera.
  if ((kind == ArchiveKind.section && ready.sections.length != 1) ||
      (kind == ArchiveKind.card && ready.cards.length != 1)) {
    _fail(context, context.t.fileContentUnexpected);
    return false;
  }
  final done = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => kind == ArchiveKind.all
          ? ImportScreen(
              database: database,
              header: read.header,
              content: ready,
            )
          : SharedImportScreen(
              database: database,
              header: read.header,
              content: ready,
            ),
    ),
  );
  return done == true;
}

/// Videate 29, 30, 31: riepilogo dell'archivio, unisci o sostituisci, esito
/// (decisione 102).
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

  String _cards(int n) => context.t.cardCount(n);

  /// Cosa finisce nel cestino sostituendo (videata 31).
  String _trashText(ImportPlan p) {
    final kept = p.current - p.toTrash;
    if (p.toTrash == 0) {
      return context.t.replaceAllInFile;
    }
    const days = db.AppDatabase.trashDays;
    if (kept == 0) return context.t.trashedAll(p.toTrash, days);
    return '${context.t.trashedSome(p.toTrash, days)} '
        '${context.t.othersStay(kept)}';
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
                      context.t.replaceAllQuestion,
                      style: TextStyle(color: c.text, fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                context.t.aboutToReplace(_cards(p.current), p.incoming),
                style: TextStyle(color: c.text, fontSize: 15.5),
              ),
              const SizedBox(height: 8),
              Text(
                _trashText(p),
                style: TextStyle(color: c.muted, fontSize: 14),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: c.danger),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.t.replaceXWithY(p.current, p.incoming)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.t.cancel),
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
    if (p == null) return;
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
            context.t.importedCount(n),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on TransferException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(tr.importFailedNothingChanged);
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

  /// Esito dell'importazione (videata 30).
  Widget _outcome(AppColors c, ImportPlan p) {
    final String title;
    final String detail;
    if (p.mode == ImportMode.merge && p.added == 0) {
      title = context.t.allAlreadyPresent;
      detail = context.t.nothingToAdd;
    } else if (p.mode == ImportMode.merge) {
      title = p.alreadyPresent == 0
          ? context.t.addsNew(p.added)
          : '${context.t.addsNew(p.added)} '
                '(${context.t.alreadyPresent(p.alreadyPresent)})';
      detail = context.t.afterImport(p.result);
    } else {
      title = context.t.replacesXWithY(_cards(p.current), p.incoming);
      detail = context.t.afterImport(p.result);
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
        !_busy &&
        !(p.mode == ImportMode.merge && p.added == 0);
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(context.t.importAll)),
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
                                    ? context.t.archiveOfApp
                                    : context.t.archiveOf(owner),
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
                          '${context.t.sectionCount(sections)} · '
                          '${_cards(content.cards.length)}',
                          style: TextStyle(color: c.infoText, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.t.createdOn(longDate(widget.header.createdAt)),
                          style: TextStyle(
                            color: c.infoText.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GroupHeader(context.t.howToImport),
                  _modeOption(
                    c,
                    ImportMode.merge,
                    context.t.mergeWithExisting,
                    context.t.mergeWithExistingDetail,
                  ),
                  _modeOption(
                    c,
                    ImportMode.replace,
                    context.t.replaceAll,
                    context.t.replaceAllDetail(db.AppDatabase.trashDays),
                  ),
                  const SizedBox(height: 10),
                  if (p != null) _outcome(c, p),
                  const SizedBox(height: 16),
                  Text(
                    context.t.androidBackupNote,
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
                    p == null
                        ? context.t.importButton
                        : p.mode == ImportMode.merge
                        ? (p.added == 0
                              ? context.t.importButton
                              : context.t.importCards(_cards(p.added)))
                        : context.t.replaceAll,
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
      _fail(tr.transferProtectedDamaged);
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
      appBar: AppBar(title: Text(context.t.importFromFile)),
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
                            context.t.passwordProtectedFile,
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
                        context.t.createdOn(longDate(widget.header.createdAt)),
                        style: TextStyle(color: c.infoText, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.t.enterFilePassword,
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
                    labelText: context.t.password,
                    errorText: _wrong ? context.t.wrongPassword : null,
                    suffixIcon: IconButton(
                      tooltip: _show ? context.t.hide : context.t.show,
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
                    context.t.fileNotModified,
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
            child: Text(_busy ? context.t.opening : context.t.openFile),
          ),
        ),
      ),
    );
  }
}
