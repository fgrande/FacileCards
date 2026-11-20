import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:facilecards/barcode_support.dart';
import 'package:facilecards/data/catalog.dart';
import 'package:facilecards/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'all\'apertura il catalogo è nel database, con la sua impronta',
    () async {
      final types = await db.activeCardTypes();
      expect(types.length, catalogTypes().length);
      expect(
        await db.setting(SettingKeys.catalogSignature),
        catalogSignature(catalogTypes()),
      );
    },
  );

  test('se il catalogo non è cambiato non si riscrive', () async {
    await db.activeCardTypes(); // apre il database
    expect(await db.syncCatalog(), isFalse);
  });

  test('se il catalogo è cambiato si riallinea', () async {
    await db.activeCardTypes();
    // Simula una versione precedente: impronta diversa e un colore vecchio.
    await db.setSetting(SettingKeys.catalogSignature, 'vecchia');
    await (db.update(db.cardTypes)..where((t) => t.id.equals('basko'))).write(
      const CardTypesCompanion(color: Value(0xFF000000)),
    );
    expect(await db.syncCatalog(), isTrue);
    final basko = (await db.activeCardTypes()).firstWhere(
      (t) => t.id == 'basko',
    );
    expect(basko.color, isNot(0xFF000000));
    expect(await db.syncCatalog(), isFalse);
  });

  test(
    'una tipologia tolta dal catalogo resta solo se una tessera la usa',
    () async {
      await db.activeCardTypes();
      // Due tipologie di una versione precedente, non più nel catalogo.
      for (final id in ['vecchia-usata', 'vecchia-libera']) {
        await db
            .into(db.cardTypes)
            .insert(CardTypesCompanion.insert(id: id, name: id));
      }
      final section = (await db.visibleSections()).first;
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              typeId: 'vecchia-usata',
              name: 'Tessera vecchia',
              code: '123',
              codeFormat: 'code128',
              sectionId: section.id,
            ),
          );
      await db.setSetting(SettingKeys.catalogSignature, 'vecchia');
      expect(await db.syncCatalog(), isTrue);
      final all = (await db.select(db.cardTypes).get()).map((t) => t.id);
      expect(all, contains('vecchia-usata'));
      expect(all, isNot(contains('vecchia-libera')));
      // Per le tessere nuove si offrono solo quelle del catalogo.
      final offered = (await db.activeCardTypes()).map((t) => t.id);
      expect(offered, isNot(contains('vecchia-usata')));
      expect(offered.length, catalogTypes().length);
    },
  );

  test('l\'impronta cambia se cambia un campo di una tipologia', () {
    final types = catalogTypes();
    final changed = [
      types.first.copyWith(name: const Value('Altro nome')),
      ...types.skip(1),
    ];
    expect(catalogSignature(changed), isNot(catalogSignature(types)));
    expect(catalogSignature(catalogTypes()), catalogSignature(types));
  });

  test('catalogo: identificativi unici, formati noti e disegnabili', () {
    final types = catalogTypes();
    final ids = types.map((t) => t.id.value).toList();
    expect(ids.toSet().length, ids.length);
    for (final t in types) {
      final f = t.codeFormat.value;
      if (f == null) continue;
      final format = formatFromText(f);
      expect(formatToText(format), f, reason: t.id.value);
      expect(drawableBarcode(format), isNotNull, reason: t.id.value);
    }
  });
}
