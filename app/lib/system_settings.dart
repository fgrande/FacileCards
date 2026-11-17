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
