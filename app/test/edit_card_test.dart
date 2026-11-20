import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/photos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late String cardId;
  late String general;
  final created = DateTime(2026, 10, 3, 9);
  final used = DateTime(2026, 11, 17, 18);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    general = (await db.defaultSection()).id;
    cardId = newId();
    await db.into(db.cards).insert(CardsCompanion.insert(
          id: Value(cardId),
          typeId: 'basko',
          name: 'Carrefour',
          code: '2400123456780',
          codeFormat: 'ean13',
          sectionId: general,
          holder: const Value('Fabio Grande'),
          notes: const Value('Punti doppi il martedì'),
          createdAt: Value(created),
          lastUsedAt: Value(used),
        ));
  });
  tearDown(() => db.close());

  test('la modifica cambia solo i campi indicati', () async {
    await db.createSection('Sport');
    final sport =
        (await db.visibleSections()).firstWhere((s) => s.name == 'Sport').id;
    await db.updateCard(
      cardId,
      CardsCompanion(
        name: const Value('Carrefour Market'),
        sectionId: Value(sport),
        notes: const Value(null),
        expiresOn: Value(DateTime(2027, 12, 31)),
      ),
    );
    final c = (await db.cardById(cardId))!;
    expect(c.name, 'Carrefour Market');
    expect(c.sectionId, sport);
    expect(c.notes, isNull);
    expect(c.expiresOn, DateTime(2027, 12, 31));
    // Invariati: codice, formato, intestatario, date di inserimento e di uso.
    expect(c.code, '2400123456780');
    expect(c.codeFormat, 'ean13');
    expect(c.holder, 'Fabio Grande');
    expect(c.createdAt, created);
    expect(c.lastUsedAt, used);
  });

  test('foto sostituite e tolte: restano da cancellare i file vecchi', () async {
    await db.setCardPhoto(cardId, PhotoSide.front, 'front-old.jpg');
    await db.setCardPhoto(cardId, PhotoSide.back, 'back-old.jpg');
    final obsolete = await db.updateCard(
      cardId,
      const CardsCompanion(),
      newPhotos: {PhotoSide.front: 'front-new.jpg'},
      removedPhotos: {PhotoSide.back},
    );
    expect(obsolete.toSet(), {'front-old.jpg', 'back-old.jpg'});
    expect(await db.cardPhotos(cardId), {PhotoSide.front: 'front-new.jpg'});
  });

  test('aggiungere una foto dove non c\'era non lascia file da cancellare',
      () async {
    final obsolete = await db.updateCard(cardId, const CardsCompanion(),
        newPhotos: {PhotoSide.back: 'back.jpg'});
    expect(obsolete, isEmpty);
    expect(await db.cardPhotos(cardId), {PhotoSide.back: 'back.jpg'});
  });
}
