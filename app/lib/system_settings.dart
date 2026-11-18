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
Future<String?> saveDocument(
        {required String path, required String name, String? initialUri}) =>
    _channel.invokeMethod<String>('saveDocument',
        {'path': path, 'name': name, 'initialUri': initialUri});

/// Pannello di condivisione di Android con il file [path].
Future<void> shareFile(
        {required String path, required String title, required String text}) =>
    _channel.invokeMethod('shareFile', {'path': path, 'title': title, 'text': text});

/// Selettore di Android per scegliere un file da importare, aperto in
/// [initialUri] se c'è: lo copia in [path]. Restituisce false se si annulla; lancia un errore se il file non si
/// legge o è troppo grande.
Future<bool> openDocument({required String path, String? initialUri}) async =>
    await _channel.invokeMethod<bool>(
        'openDocument', {'path': path, 'initialUri': initialUri}) ??
    false;
