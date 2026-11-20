import 'dart:io';

import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/data/migration_backup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

/// Prove sullo schema e sulle migrazioni (decisione 88, punto B8). Per ora
/// c'è solo la versione 1: quando arriverà la 2, qui si aggiunge la prova
/// che un database `schema_v1.sql` con dati si apre senza perdere niente.
void main() {
  late Directory dir;
  setUp(
    () async =>
        dir = await Directory.systemTemp.createTemp('facilecards_migration'),
  );
  tearDown(() => dir.delete(recursive: true));

  /// Le istruzioni CREATE TABLE di un database, in ordine di nome.
  List<String> tablesOf(raw.Database db) => db
      .select(
        "SELECT sql FROM sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      )
      .map((r) => r['sql'] as String)
      .toList();

  test(
    'la versione del programma di copia coincide con quella del database',
    () {
      expect(migrationTargetVersion, AppDatabase.currentSchemaVersion);
    },
  );

  test('un database nuovo ha lo schema salvato in fixtures', () async {
    final file = File('${dir.path}/nuovo.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(file));
    await db.defaultSection();
    await db.close();

    final created = raw.sqlite3.open(file.path);
    addTearDown(created.close);
    final saved = raw.sqlite3.openInMemory();
    addTearDown(saved.close);
    saved.execute(
      File('test/fixtures/schema_v${AppDatabase.currentSchemaVersion}.sql')
          .readAsStringSync(),
    );

    expect(created.userVersion, AppDatabase.currentSchemaVersion);
    expect(saved.userVersion, AppDatabase.currentSchemaVersion);
    expect(tablesOf(created), tablesOf(saved));
  });

  test('un database nuovo non fa copie', () async {
    final file = File('${dir.path}/nuovo.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(file, setup: backupBeforeMigration),
    );
    await db.defaultSection();
    await db.close();
    expect(dir.listSync().where((f) => f.path.endsWith('.bak')), isEmpty);
  });
}
