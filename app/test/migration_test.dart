import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/data/migration_backup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

/// Prove di migrazione (decisione 88, punto B8): un database delle versioni
/// precedenti, con dati, si apre con l'app attuale senza perdere niente.
void main() {
  late Directory dir;
  setUp(() async =>
      dir = await Directory.systemTemp.createTemp('facilecards_migration'));
  tearDown(() => dir.delete(recursive: true));

  /// Database versione 1 come quello sul telefono di Fabio prima del 18 nov.
  File makeV1() {
    final file = File('${dir.path}/facilecards.sqlite');
    final db = raw.sqlite3.open(file.path);
    db.execute(File('test/fixtures/schema_v1.sql').readAsStringSync());
    db.execute('''
      INSERT INTO sections (id, name, is_default, hidden)
        VALUES ('gen', 'Generale', 1, 0), ('fam', 'Famiglia', 0, 0);
      INSERT INTO card_types (id, name, category, is_generic)
        VALUES ('generic', 'Tessera generica', 'altro', 1);
      INSERT INTO cards (id, type_id, name, code, code_format, section_id,
          created_at, favorite)
        VALUES ('c1', 'generic', 'Biblioteca', '123', 'code128', 'fam',
          1763000000, 1);
      INSERT INTO card_images (card_id, side, file_name)
        VALUES ('c1', 'front', 'c1_front.jpg');
      INSERT INTO settings (key, value) VALUES ('setupDone', 'true');
    ''');
    db.close();
    return file;
  }

  test('la versione del programma di copia coincide con quella del database',
      () {
    expect(migrationTargetVersion, AppDatabase.currentSchemaVersion);
  });

  test('dalla versione 1: dati intatti, colonne nuove, copia di sicurezza',
      () async {
    final file = makeV1();
    final db = AppDatabase.forTesting(
        NativeDatabase(file, setup: backupBeforeMigration));
    addTearDown(db.close);

    expect(await db.isSetupDone(), isTrue);
    final card = (await db.cardById('c1'))!;
    expect(card.name, 'Biblioteca');
    expect(card.favorite, isTrue);
    expect(card.originId, isNull);
    expect(await db.cardPhotos('c1'), {'front': 'c1_front.jpg'});
    final sections = await db.visibleSections();
    expect(sections.map((s) => s.name), containsAll(['Generale', 'Famiglia']));
    expect(sections.every((s) => s.originId == null && s.receivedAt == null),
        isTrue);
    // Le colonne nuove si scrivono.
    await (db.update(db.sections)..where((s) => s.id.equals('fam'))).write(
        SectionsCompanion(
            originId: const Value('altrove'),
            receivedAt: Value(DateTime(2026, 11, 2))));
    expect((await db.visibleSections()).firstWhere((s) => s.id == 'fam').originId,
        'altrove');

    // Copia di sicurezza della versione 1, apribile e con i dati.
    final backup = File('${file.path}.v1.bak');
    expect(backup.existsSync(), isTrue);
    final old = raw.sqlite3.open(backup.path);
    addTearDown(old.close);
    expect(old.userVersion, 1);
    expect(old.select('SELECT name FROM cards').single['name'], 'Biblioteca');
  });

  test('un database nuovo non fa copie', () async {
    final file = File('${dir.path}/nuovo.sqlite');
    final db = AppDatabase.forTesting(
        NativeDatabase(file, setup: backupBeforeMigration));
    await db.defaultSection();
    await db.close();
    expect(
        dir.listSync().where((f) => f.path.endsWith('.bak')), isEmpty);
  });
}
