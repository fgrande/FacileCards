import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/expiry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 11, 16, 22, 30);
  const on30 = ExpirySettings(enabled: true, days: 30);

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> addCard(String name, DateTime? expiresOn,
      {bool trashed = false}) async {
    final section = await db.defaultSection();
    await db.into(db.cards).insert(CardsCompanion.insert(
        typeId: 'generic',
        name: name,
        code: name,
        codeFormat: 'code128',
        sectionId: section.id,
        expiresOn: Value(expiresOn),
        deletedAt: Value(trashed ? now : null)));
  }

  Future<List<String>> flagged(ExpirySettings s) async =>
      cardsToFlag(await db.select(db.cards).get(), now, s)
          .map((c) => c.name)
          .toList();

  test('si segnalano scadute e in scadenza, prima le scadute, per data', () async {
    await addCard('Lontana', DateTime(2027, 6, 1));
    await addCard('Tra 12', DateTime(2026, 11, 28));
    await addCard('Scaduta', DateTime(2026, 10, 31));
    await addCard('Oggi', DateTime(2026, 11, 16));
    await addCard('Senza data', null);
    expect(await flagged(on30), ['Scaduta', 'Oggi', 'Tra 12']);
  });

  test('il limite dei giorni di preavviso è compreso', () async {
    await addCard('Al limite', DateTime(2026, 12, 16)); // tra 30 giorni
    await addCard('Oltre', DateTime(2026, 12, 17)); // tra 31 giorni
    expect(await flagged(on30), ['Al limite']);
    expect(await flagged(const ExpirySettings(enabled: true, days: 10)), isEmpty);
  });

  test('le tessere nel cestino non si segnalano', () async {
    await addCard('Nel cestino', DateTime(2026, 10, 1), trashed: true);
    expect(await flagged(on30), isEmpty);
  });

  test('con l\'avviso spento non si segnala niente', () async {
    await addCard('Scaduta', DateTime(2026, 10, 31));
    expect(await flagged(const ExpirySettings(enabled: false, days: 30)), isEmpty);
  });

  test('impostazioni: predefinite prima della configurazione, poi quelle scelte',
      () async {
    final before = await db.expirySettings();
    expect(before.enabled, isTrue);
    expect(before.days, 30);
    await db.completeSetup(
        holderName: '', language: 'it', expiryAlerts: false, expiryDays: 7);
    final after = await db.expirySettings();
    expect(after.enabled, isFalse);
    expect(after.days, 7);
  });
}
