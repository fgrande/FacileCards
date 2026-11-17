import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/photos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Immagine di prova simile a una foto: sfumature con un po' di grana.
Uint8List _photo(int width, int height, {int grain = 12}) {
  final image = img.Image(width: width, height: height);
  var seed = 7;
  for (final p in image) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    final n = grain == 0 ? 0 : seed % grain;
    p
      ..r = (p.x * 255 ~/ width + n).clamp(0, 255)
      ..g = (p.y * 255 ~/ height + n).clamp(0, 255)
      ..b = (128 + n).clamp(0, 255);
  }
  return img.encodePng(image);
}

/// Rumore puro: non si comprime, è il caso peggiore.
Uint8List _noise(int width, int height) {
  final image = img.Image(width: width, height: height);
  var seed = 7;
  for (final p in image) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    p
      ..r = seed & 0xff
      ..g = (seed >> 8) & 0xff
      ..b = (seed >> 16) & 0xff;
  }
  return img.encodePng(image);
}

void main() {
  group('riduzione delle foto (decisione 6)', () {
    test('una foto grande scende a 1600 px sul lato lungo e sotto 500 KB', () {
      final out = shrinkPhoto(_photo(3000, 2000))!;
      final decoded = img.decodeJpg(out)!;
      expect(decoded.width, maxPhotoSide);
      expect(decoded.height, closeTo(1067, 1));
      expect(out.length, lessThanOrEqualTo(maxPhotoBytes));
    });

    test('una foto verticale si riduce sull\'altezza', () {
      final decoded = img.decodeJpg(shrinkPhoto(_photo(1000, 2400))!)!;
      expect(decoded.height, maxPhotoSide);
    });

    test('una foto piccola resta della sua misura', () {
      final decoded = img.decodeJpg(shrinkPhoto(_photo(800, 500))!)!;
      expect(decoded.width, 800);
    });

    test('anche una foto che non si comprime resta sotto 500 KB', () {
      final out = shrinkPhoto(_noise(3000, 2000))!;
      expect(out.length, lessThanOrEqualTo(maxPhotoBytes));
    });

    test('un file che non è un\'immagine non si accetta', () {
      expect(shrinkPhoto(Uint8List.fromList([1, 2, 3, 4])), isNull);
    });
  });

  group('foto nel database e sul disco', () {
    late AppDatabase db;
    late Directory dir;
    late PhotoStore store;
    late String cardId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dir = await Directory.systemTemp.createTemp('facilecards_photos');
      store = PhotoStore(dir);
      final section = await db.defaultSection();
      cardId = newId();
      await db.into(db.cards).insert(CardsCompanion.insert(
          id: Value(cardId),
          typeId: 'generic',
          name: 'Palestra',
          code: '123',
          codeFormat: 'code128',
          sectionId: section.id));
    });

    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    test('aggiungere, sostituire ed eliminare la foto di un lato', () async {
      final first = (await store.write(cardId, PhotoSide.front, _photo(200, 120)))!;
      expect(await db.setCardPhoto(cardId, PhotoSide.front, first), isNull);
      expect(await db.cardPhotos(cardId), {PhotoSide.front: first});

      final second = (await store.write(cardId, PhotoSide.front, _photo(200, 120)))!;
      expect(second, isNot(first));
      expect(await db.setCardPhoto(cardId, PhotoSide.front, second), first);
      expect(await db.cardPhotos(cardId), {PhotoSide.front: second});

      expect(await db.removeCardPhoto(cardId, PhotoSide.front), second);
      expect(await db.cardPhotos(cardId), isEmpty);
    });

    test('la foto si può salvare insieme alla tessera, in una transazione',
        () async {
      final name = (await store.write(cardId, PhotoSide.back, _photo(200, 120)))!;
      await db.transaction(() async {
        await db.setCardPhoto(cardId, PhotoSide.back, name);
      });
      expect(await db.cardPhotos(cardId), {PhotoSide.back: name});
    });

    test('i file senza riga nel database si cancellano', () async {
      final kept = (await store.write(cardId, PhotoSide.front, _photo(200, 120)))!;
      await db.setCardPhoto(cardId, PhotoSide.front, kept);
      final orphan = (await store.write(cardId, PhotoSide.back, _photo(200, 120)))!;
      await db.deleteCardForever(newId()); // nessun effetto
      await store.removeOrphans(db);
      expect(await store.file(kept).exists(), isTrue);
      expect(await store.file(orphan).exists(), isFalse);
    });

    test('eliminando la tessera per sempre le sue foto diventano orfane',
        () async {
      final name = (await store.write(cardId, PhotoSide.front, _photo(200, 120)))!;
      await db.setCardPhoto(cardId, PhotoSide.front, name);
      await db.deleteCardForever(cardId);
      await store.removeOrphans(db);
      expect(await store.file(name).exists(), isFalse);
    });
  });

  test('spostare una tessera in un\'altra sezione', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.createSection('Sport');
    final sport =
        (await db.visibleSections()).firstWhere((s) => s.name == 'Sport');
    final general = await db.defaultSection();
    final id = newId();
    await db.into(db.cards).insert(CardsCompanion.insert(
        id: Value(id),
        typeId: 'generic',
        name: 'Decathlon',
        code: '1',
        codeFormat: 'code128',
        sectionId: general.id));
    await db.moveCard(id, sport.id);
    final card =
        await (db.select(db.cards)..where((c) => c.id.equals(id))).getSingle();
    expect(card.sectionId, sport.id);
  });
}
