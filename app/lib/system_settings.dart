import 'package:flutter/services.dart';

const _channel = MethodChannel('facilecards/system');

/// Apre la pagina dell'app nelle impostazioni di Android, dove si concede il
/// permesso della fotocamera. Codice nativo in MainActivity.kt, come le altre
/// funzioni di questo file.
Future<void> openAppSettings() => _channel.invokeMethod('openAppSettings');

/// Apre un indirizzo web (o `mailto:`) con l'app predefinita del telefono.
/// Restituisce false se nessuna app sa aprirlo.
Future<bool> openUrl(String url) async =>
    await _channel.invokeMethod<bool>('openUrl', {'url': url}) ?? false;

/// Versione dell'app ("1.0.0"), letta da Android.
Future<String> appVersion() async =>
    await _channel.invokeMethod<String>('appVersion') ?? '';

/// "Salva in…" di Android (decisione 112): copia il file [path] dove sceglie
/// l'utente, partendo da [initialUri] se c'è. Restituisce l'indirizzo del
/// documento creato, o null se si annulla.
Future<String?> saveDocument({
  required String path,
  required String name,
  String? initialUri,
}) => _channel.invokeMethod<String>('saveDocument', {
  'path': path,
  'name': name,
  'initialUri': initialUri,
});

/// Pannello di condivisione di Android con il file [path].
Future<void> shareFile({
  required String path,
  required String title,
  required String text,
}) => _channel.invokeMethod('shareFile', {
  'path': path,
  'title': title,
  'text': text,
});

/// Selettore di Android per scegliere un file da importare, aperto in
/// [initialUri] se c'è: lo copia in [path]. Restituisce false se si annulla; lancia un errore se il file non si
/// legge o è troppo grande.
Future<bool> openDocument({required String path, String? initialUri}) async =>
    await _channel.invokeMethod<bool>('openDocument', {
      'path': path,
      'initialUri': initialUri,
    }) ??
    false;

/// "Apri con FacileCards": il file ricevuto da un'altra app, già copiato in
/// uno spazio privato. `path` se c'è, `error` ('too_big' o 'read_failed') se
/// non si è potuto copiare, null se non è arrivato niente.
Future<({String? path, String? error})?> takeIncomingFile() async {
  final r = await _channel.invokeMapMethod<String, String>('takeIncomingFile');
  if (r == null) return null;
  return (path: r['path'], error: r['error']);
}

/// Avvisi da Android (MainActivity.kt), con l'app già aperta: un solo
/// ascoltatore per il canale, che passa ciascun avviso a chi lo aspetta.
final _listeners = <String, void Function()>{};

void _listen(String method, void Function() callback) {
  _listeners[method] = callback;
  _channel.setMethodCallHandler(
    (call) async => _listeners[call.method]?.call(),
  );
}

/// [onArrived] si chiama quando arriva un file con l'app già aperta.
void listenIncomingFiles(void Function() onArrived) =>
    _listen('incomingFile', onArrived);

/// Scorciatoie in Home: [onCard] quando si tocca un'icona con l'app già
/// aperta, [onPinned] quando Android ha aggiunto l'icona.
void listenShortcuts({
  required void Function() onCard,
  required void Function() onPinned,
}) {
  _listen('shortcutCard', onCard);
  _listen('shortcutPinned', onPinned);
}

/// La tessera della scorciatoia toccata (identificativo e nome che aveva),
/// o null se l'app non è stata aperta da una scorciatoia.
Future<({String id, String name})?> takeShortcutCard() async {
  final r = await _channel.invokeMapMethod<String, String>('takeShortcutCard');
  final id = r?['id'];
  return id == null ? null : (id: id, name: r?['name'] ?? '');
}

/// Il telefono accetta icone fissate in Home (Android 8 e successivi, con un
/// launcher che lo permette).
Future<bool> canPinShortcut() async =>
    await _channel.invokeMethod<bool>('canPinShortcut') ?? false;

/// Chiede ad Android di aggiungere l'icona: compare la sua conferma.
Future<bool> pinShortcut(String id, String name, Uint8List icon) async =>
    await _channel.invokeMethod<bool>('pinShortcut', {
      'id': id,
      'name': name,
      'icon': icon,
    }) ??
    false;

/// Aggiorna nome e icona, se l'icona è sulla Home.
Future<void> updateShortcut(String id, String name, Uint8List icon) => _channel
    .invokeMethod('updateShortcut', {'id': id, 'name': name, 'icon': icon});

/// Spegne l'icona (Android non lascia toglierla): toccandola si legge
/// [message].
Future<void> disableShortcut(String id, String message) =>
    _channel.invokeMethod('disableShortcut', {'id': id, 'message': message});

/// Un'app per pagare installata (decisione 118): pacchetto, nome e icona.
class PayApp {
  const PayApp(this.package, this.label, this.icon);

  final String package;
  final String label;

  /// Icona dell'app in PNG.
  final Uint8List icon;

  static PayApp? fromMap(Map<Object?, Object?>? m) => m == null
      ? null
      : PayApp(
          m['package'] as String,
          m['label'] as String,
          m['icon'] as Uint8List,
        );
}

/// Pacchetto di Satispay: proposto nella configurazione iniziale se c'è.
const satispayPackage = 'com.satispay.customer';

/// Le app per pagare trovate sul telefono (codice nativo in PayApps.kt).
Future<List<PayApp>> findPayApps() async {
  final list = await _channel.invokeListMethod<Object?>('payApps') ?? const [];
  return [for (final m in list) PayApp.fromMap(m as Map<Object?, Object?>)!];
}

/// Nome e icona dell'app scelta, o null se non è (più) installata.
Future<PayApp?> payAppInfo(String package) async => PayApp.fromMap(
  await _channel.invokeMethod<Map<Object?, Object?>>('payAppInfo', {
    'package': package,
  }),
);

/// Apre l'app; false se non c'è più.
Future<bool> openApp(String package) async =>
    await _channel.invokeMethod<bool>('openApp', {'package': package}) ?? false;
