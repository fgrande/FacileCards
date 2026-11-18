import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:facilecards/data/catalog.dart';
import 'package:facilecards/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('all\'apertura il catalogo è nel database, con la sua impronta', () async {
    final types = await db.activeCardTypes();
    expect(types.length, catalogTypes().length);
    expect(await db.setting(SettingKeys.catalogSignature),
        catalogSignature(catalogTypes()));
  });

  test('se il catalogo non è cambiato non si riscrive', () async {
    await db.activeCardTypes(); // apre il database
    expect(await db.syncCatalog(), isFalse);
  });

  test('se il catalogo è cambiato si riallinea', () async {
    await db.activeCardTypes();
    // Simula una versione precedente: impronta diversa e un colore vecchio.
    await db.setSetting(SettingKeys.catalogSignature, 'vecchia');
    await (db.update(db.cardTypes)..where((t) => t.id.equals('basko')))
        .write(const CardTypesCompanion(color: Value(0xFF000000)));
    expect(await db.syncCatalog(), isTrue);
    final basko = (await db.activeCardTypes()).firstWhere((t) => t.id == 'basko');
    expect(basko.color, isNot(0xFF000000));
    expect(await db.syncCatalog(), isFalse);
  });

  test('l\'impronta cambia se cambia un campo di una tipologia', () {
    final types = catalogTypes();
    final changed = [
      types.first.copyWith(name: const Value('Altro nome')),
      ...types.skip(1),
    ];
    expect(catalogSignature(changed), isNot(catalogSignature(types)));
    expect(catalogSignature(catalogTypes()), catalogSignature(types));
  });
}
