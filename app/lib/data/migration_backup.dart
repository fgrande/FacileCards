import 'dart:io';

import 'package:sqlite3/common.dart';

/// Decisione 88: prima di una migrazione il database si copia accanto
/// all'originale (`facilecards.sqlite.v1.bak`), così un errore nel passo di
/// migrazione non fa perdere le tessere. Gira all'apertura, prima di drift,
/// nell'isolate del database: deve essere una funzione a sé.
void backupBeforeMigration(CommonDatabase db) {
  final version = db.userVersion;
  // 0: database appena creato; dalla versione attuale in su: niente da fare.
  if (version == 0 || version >= migrationTargetVersion) return;
  final file = db.select('PRAGMA database_list').first['file'] as String?;
  if (file == null || file.isEmpty) return; // database in memoria
  final backup = '$file.v$version.bak';
  final old = File(backup);
  if (old.existsSync()) old.deleteSync();
  db.execute('VACUUM INTO ?', [backup]);
}

/// Deve coincidere con `AppDatabase.currentSchemaVersion` (controllato da una
/// prova): qui non si importa il database, per non legarlo all'isolate.
const migrationTargetVersion = 2;
