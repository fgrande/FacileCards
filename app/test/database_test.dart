import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:facilecards/data/catalog.dart';
import 'package:facilecards/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('alla creazione ci sono la sezione Generale e la tipologia Generica',
      () async {
    final s = await db.defaultSection();
    expect(s.name, defaultSectionName);
    expect(s.isDefault, isTrue);
    final types = await db.select(db.cardTypes).get();
    expect(types.where((t) => t.isGeneric).single.id, 'generic');
  });

  test('il catalogo ha identificativi unici e si riallinea senza duplicati',
      () async {
    final ids = catalogTypes().map((t) => t.id.value).toList();
    expect(ids.toSet().length, ids.length);
    final types = await db.activeCardTypes();
    expect(types.length, ids.length);
    expect(types.any((t) => t.id == 'carrefour' && hasFixedName(t)), isTrue);
    expect(types.any((t) => t.id == 'biblioteca' && !hasFixedName(t)), isTrue);
  });

  Future<String> addCard(String name, String sectionId) async {
    final id = newId();
    await db.into(db.cards).insert(CardsCompanion.insert(
        id: Value(id), typeId: 'generic', name: name, code: name,
        codeFormat: 'code128', sectionId: sectionId));
    return id;
  }

  test('i nomi delle sezioni sono unici, senza badare alle maiuscole', () async {
    expect(await db.createSection('Famiglia'), isTrue);
    expect(await db.createSection('famiglia'), isFalse);
    expect(await db.createSection('  '), isFalse);
    expect(await db.createSection('Generale'), isFalse);
    final s = (await db.visibleSections()).firstWhere((s) => s.name == 'Famiglia');
    expect(await db.renameSection(s.id, 'Sport'), isTrue);
    expect(await db.renameSection(s.id, 'Generale'), isFalse);
  });

  test('la sezione di partenza non si elimina', () async {
    final s = await db.defaultSection();
    expect(() => db.deleteSection(s.id), throwsStateError);
  });

  test('eliminare una sezione spostando le tessere', () async {
    await db.createSection('Famiglia');
    final fam = (await db.visibleSections()).firstWhere((s) => s.name == 'Famiglia');
    final gen = await db.defaultSection();
    await addCard('Kiabi', fam.id);
    await db.deleteSection(fam.id, moveTo: gen.id);
    expect((await db.visibleSections()).map((s) => s.name), ['Generale']);
    expect((await db.watchCards(gen.id).first).map((c) => c.name), ['Kiabi']);
    expect(await db.select(db.sections).get(), hasLength(1));
  });

  test('eliminare una sezione con le tessere: nascosta, nome libero, recupero',
      () async {
    await db.createSection('Famiglia');
    final fam = (await db.visibleSections()).firstWhere((s) => s.name == 'Famiglia');
    final id = await addCard('Kiabi', fam.id);
    await db.deleteSection(fam.id);
    expect(await db.activeCardCount(), 0);
    expect(await db.trashCount(), 1);
    expect((await db.visibleSections()).map((s) => s.name), ['Generale']);
    expect(await db.createSection('Famiglia'), isTrue); // il nome è tornato libero
    // si recupera nella sezione eliminata, che torna visibile
    expect(await db.recoverCard(id, fam.id), isTrue);
    expect(await db.activeCardCount(), 1);
    expect((await db.select(db.sections).get()).where((s) => s.id == fam.id).single.hidden, isFalse);
  });

  test('il recupero è bloccato al limite', () async {
    final gen = await db.defaultSection();
    final trashed = await addCard('Vecchia', gen.id);
    await db.moveCardToTrash(trashed);
    for (var i = 0; i < AppDatabase.freeCardLimit; i++) {
      await addCard('T$i', gen.id);
    }
    expect(await db.recoverCard(trashed, gen.id), isFalse);
    expect(await db.trashCount(), 1);
  });

  test('il cestino si svuota dopo 30 giorni e toglie le sezioni nascoste', () async {
    await db.createSection('Famiglia');
    final fam = (await db.visibleSections()).firstWhere((s) => s.name == 'Famiglia');
    await addCard('Kiabi', fam.id);
    await db.deleteSection(fam.id);
    await db.purgeExpiredTrash(DateTime.now().add(const Duration(days: 29)));
    expect(await db.trashCount(), 1);
    await db.purgeExpiredTrash(DateTime.now().add(const Duration(days: 31)));
    expect(await db.trashCount(), 0);
    expect(await db.select(db.sections).get(), hasLength(1)); // resta solo Generale
  });

  test('il conteggio delle tessere ignora il cestino', () async {
    final s = await db.defaultSection();
    await db.into(db.cards).insert(CardsCompanion.insert(
          typeId: 'generic', name: 'A', code: '1', codeFormat: 'code128', sectionId: s.id));
    await db.into(db.cards).insert(CardsCompanion.insert(
          typeId: 'generic', name: 'B', code: '2', codeFormat: 'code128', sectionId: s.id,
          deletedAt: Value(DateTime.now())));
    expect(await db.activeCardCount(), 1);
  });

  test('una tessera nel cestino non compare nell\'elenco', () async {
    final s = await db.defaultSection();
    await db.into(db.cards).insert(CardsCompanion.insert(
          typeId: 'generic',
          name: 'Biblioteca',
          code: '1234567890128',
          codeFormat: 'ean13',
          sectionId: s.id,
        ));
    await db.into(db.cards).insert(CardsCompanion.insert(
          typeId: 'generic',
          name: 'Vecchia',
          code: '42',
          codeFormat: 'code128',
          sectionId: s.id,
          deletedAt: Value(DateTime.now()),
        ));
    final list = await db.watchCards(s.id).first;
    expect(list.map((c) => c.name), ['Biblioteca']);
    expect(list.single.id, isNotEmpty);
  });

  test('configurazione iniziale: all\'inizio non è fatta', () async {
    expect(await db.isSetupDone(), isFalse);
  });

  test('configurazione iniziale: salva le risposte e la ricorda', () async {
    await db.completeSetup(
        holderName: '  Fabio Grande ',
        language: 'it',
        expiryAlerts: false,
        expiryDays: 15);
    expect(await db.isSetupDone(), isTrue);
    expect(await db.setting(SettingKeys.holderName), 'Fabio Grande');
    expect(await db.setting(SettingKeys.language), 'it');
    expect(await db.setting(SettingKeys.expiryAlerts), 'false');
    expect(await db.setting(SettingKeys.expiryDays), '15');
    expect((await db.defaultSection()).name, 'Generale');
  });

  test('la sezione di partenza prende il nome nella lingua scelta', () async {
    await db.completeSetup(
        holderName: '', language: 'fr', expiryAlerts: true, expiryDays: 30);
    final s = await db.defaultSection();
    expect(s.name, 'Général');
    expect(s.isDefault, isTrue);
    expect((await db.visibleSections()).length, 1);
  });
}
