import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/photos.dart';
import 'package:facilecards/transfer/archive_format.dart';
import 'package:facilecards/transfer/export.dart';
import 'package:facilecards/transfer/import.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List _jpeg() => img.encodeJpg(img.Image(width: 40, height: 25));

void main() {
  late AppDatabase db;
  late Directory dir;
  late PhotoStore store;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('facilecards_import');
    store = PhotoStore(dir);
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<String> addCard(String name, {String? id, bool trashed = false}) async {
    final cardId = id ?? newId();
    await db.into(db.cards).insert(CardsCompanion.insert(
        id: Value(cardId),
        typeId: 'generic',
        name: name,
        code: name,
        codeFormat: 'code128',
        sectionId: (await db.defaultSection()).id,
        deletedAt: Value(trashed ? DateTime.now() : null)));
    return cardId;
  }

  ArchiveCard card(String id, String name,
          {String section = 'gen', String type = 'generic', Map<String, String> photos = const {}}) =>
      ArchiveCard(
          id: id,
          typeId: type,
          name: name,
          code: '123-$name',
          codeFormat: 'code128',
          sectionId: section,
          photos: photos);

  ArchiveContent backup(List<ArchiveCard> cards,
          {List<ArchiveSection>? sections, Map<String, Uint8List> photos = const {}}) =>
      ArchiveContent(
        owner: 'Fabio Grande',
        sections: sections ??
            const [
              ArchiveSection(id: 'gen', name: 'Generale', isDefault: true),
              ArchiveSection(id: 'sport', name: 'Sport'),
            ],
        cards: cards,
        photos: photos,
      );

  Future<List<String>> activeNames() async =>
      (await (db.select(db.cards)..where((c) => c.deletedAt.isNull())).get())
          .map((c) => c.name)
          .toList()
        ..sort();

  test('unisci: aggiunge solo le tessere che mancano', () async {
    await addCard('Carrefour', id: 'c1');
    final content = backup([card('c1', 'Carrefour'), card('c2', 'Decathlon')]);
    final plan = await planImport(db, content, ImportMode.merge);
    expect(plan.added, 1);
    expect(plan.alreadyPresent, 1);
    expect(plan.result, 2);
    expect(await runImport(db, store, content, ImportMode.merge), 1);
    expect(await activeNames(), ['Carrefour', 'Decathlon']);
    // Una seconda volta non duplica niente.
    expect(await runImport(db, store, content, ImportMode.merge), 0);
    expect(await activeNames(), ['Carrefour', 'Decathlon']);
  });

  test('unisci: una tessera del file che era nel cestino torna in uso', () async {
    await addCard('Kiabi', id: 'k1', trashed: true);
    await runImport(db, store, backup([card('k1', 'Kiabi')]), ImportMode.merge);
    expect(await activeNames(), ['Kiabi']);
    expect(await db.trashCount(), 0);
  });

  test('sostituisci: le tessere attuali vanno nel cestino', () async {
    await addCard('Vecchia 1');
    await addCard('Vecchia 2');
    final content = backup([card('n1', 'Nuova')]);
    final plan = await planImport(db, content, ImportMode.replace);
    expect(plan.current, 2);
    expect(plan.result, 1);
    await runImport(db, store, content, ImportMode.replace);
    expect(await activeNames(), ['Nuova']);
    expect(await db.trashCount(), 2);
  });

  test('sostituisci: le tessere presenti anche nel file non vanno nel cestino',
      () async {
    await addCard('Carrefour', id: 'c1');
    await addCard('Vecchia');
    final content = backup([card('c1', 'Carrefour'), card('n1', 'Nuova')]);
    final plan = await planImport(db, content, ImportMode.replace);
    expect(plan.current, 2);
    expect(plan.toTrash, 1);
    await runImport(db, store, content, ImportMode.replace);
    expect(await activeNames(), ['Carrefour', 'Nuova']);
    expect(await db.trashCount(), 1);
  });

  test('oltre il limite non si importa niente', () async {
    for (var i = 0; i < 45; i++) {
      await addCard('T$i');
    }
    final content =
        backup([for (var i = 0; i < 10; i++) card('x$i', 'Nuova $i')]);
    final merge = await planImport(db, content, ImportMode.merge);
    expect(merge.fits, isFalse);
    expect(merge.result, 55);
    await expectLater(runImport(db, store, content, ImportMode.merge),
        throwsA(isA<TransferException>()));
    expect((await activeNames()).length, 45);
    // Sostituendo invece si sta nel limite.
    expect((await planImport(db, content, ImportMode.replace)).fits, isTrue);
  });

  test('sezioni: la partenza va nella partenza, le altre si ritrovano o si creano',
      () async {
    await db.createSection('sport'); // stesso nome, maiuscole diverse
    final content = backup([
      card('a', 'A', section: 'gen'),
      card('b', 'B', section: 'sport'),
      card('c', 'C', section: 'fam'),
    ], sections: const [
      ArchiveSection(id: 'gen', name: 'General', isDefault: true),
      ArchiveSection(id: 'sport', name: 'Sport'),
      ArchiveSection(id: 'fam', name: 'Famiglia'),
    ]);
    await runImport(db, store, content, ImportMode.merge);
    final sections = {
      for (final s in await db.visibleSections()) s.id: s.name
    };
    final cards = {
      for (final c in await db.select(db.cards).get()) c.name: c.sectionId
    };
    expect(sections[cards['A']], 'Generale');
    expect(sections[cards['B']], 'sport');
    expect(sections[cards['C']], 'Famiglia');
    expect(sections.length, 3);
  });

  test('tipologia sconosciuta: la tessera diventa generica', () async {
    await runImport(db, store,
        backup([card('z', 'Negozio futuro', type: 'negozio-del-2030')]),
        ImportMode.merge);
    final c = await db.cardById('z');
    expect(c!.typeId, 'generic');
    expect(c.code, '123-Negozio futuro');
  });

  test('esporta e reimporta: tutto torna com\'era, foto comprese', () async {
    final id = await addCard('Palestra');
    final file = await store.write(id, PhotoSide.front, _jpeg());
    await db.setCardPhoto(id, PhotoSide.front, file!);
    await (db.update(db.cards)..where((c) => c.id.equals(id))).write(
        CardsCompanion(
            favorite: const Value(true),
            notes: const Value('Turno serale'),
            expiresOn: Value(DateTime(2027, 6, 30))));

    final bytes = await buildBackupFile(db, store);
    // Su un telefono nuovo (database vuoto).
    final other = AppDatabase.forTesting(NativeDatabase.memory());
    final otherDir = await Directory.systemTemp.createTemp('facilecards_other');
    addTearDown(() async {
      await other.close();
      await otherDir.delete(recursive: true);
    });
    final otherStore = PhotoStore(otherDir);
    final read = decodeArchive(bytes);
    await runImport(other, otherStore, decodeContent(read.content),
        ImportMode.merge);

    final c = (await other.cardById(id))!;
    expect(c.name, 'Palestra');
    expect(c.favorite, isTrue);
    expect(c.notes, 'Turno serale');
    expect(c.expiresOn, DateTime(2027, 6, 30));
    final photos = await other.cardPhotos(id);
    expect(photos.keys, [PhotoSide.front]);
    expect(await otherStore.file(photos[PhotoSide.front]!).exists(), isTrue);
  });
}
