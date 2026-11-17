import 'package:flutter/services.dart';

const _channel = MethodChannel('facilecards/system');

/// Apre la pagina dell'app nelle impostazioni di Android, dove si concede il
/// permesso della fotocamera. Codice nativo in MainActivity.kt.
Future<void> openAppSettings() => _channel.invokeMethod('openAppSettings');
