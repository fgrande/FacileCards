// Spazio occupato da ciò che salva il backup automatico di Android
// (decisione 93: database e foto; regole in res/xml/backup_rules.xml).
// Android salva al massimo 25 MB per app: oltre, l'app non viene salvata.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'photos.dart';

/// Limite di Android per app.
const androidBackupLimitBytes = 25 * 1024 * 1024;

/// Da qui si avvisa: un po' prima del limite.
const androidBackupWarnBytes = 20 * 1024 * 1024;

/// Byte di database e foto, cioè di ciò che finirebbe nel backup.
Future<int> backupSizeBytes() async {
  var total = 0;
  final docs = await getApplicationDocumentsDirectory();
  for (final suffix in ['', '-wal', '-journal']) {
    final f = File(p.join(docs.path, 'facilecards.sqlite$suffix'));
    if (await f.exists()) total += await f.length();
  }
  final photos = (await PhotoStore.instance).directory;
  if (await photos.exists()) {
    await for (final e in photos.list()) {
      if (e is File) total += await e.length();
    }
  }
  return total;
}
