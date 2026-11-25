import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/photos.dart';
import 'package:facilecards/transfer/archive_format.dart';
import 'package:facilecards/transfer/import_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory dir;
  late PhotoStore store;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('facilecards_shared');
    store = PhotoStore(dir);
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  ArchiveCard card(
    String id,
    String name, {
    String code = '',
    String type = 'generic',
  }) => ArchiveCard(
    id: id,
    typeId: type,
    name: name,
    code: code.isEmpty ? 'code-$id' : code,
    codeFormat: 'code128',
    sectionId: 'fam-origine',
  );

  ArchiveContent sectionFile(
    List<ArchiveCard> cards, {
    String name = 'Famiglia',
  }) => ArchiveContent(
    sections: [ArchiveSection(id: 'fam-origine', name: name)],
    cards: cards,
  );

  Future<List<Card>> cardsIn(String sectionId) => (db.select(
    db.cards,
  )..where((c) => c.sectionId.equals(sectionId) & c.deletedAt.isNull())).get();

  Future<Section> sectionNamed(String name) async =>
      (await db.visibleSections()).firstWhere((s) => s.name == name);

  test(
    'nuova sezione: tessere con identificativo nuovo e quello d\'origine',
    () async {
      final file = sectionFile([card('a', 'Biblioteca'), card('b', 'Kiabi')]);
      expect(await previouslyReceived(db, file), isNull);
      final id = await runSharedImport(
        db,
        store,
        file,
        SharedImportMode.newSection,
        newSectionName: 'Famiglia',
      );
      final section = await sectionNamed('Famiglia');
      expect(section.id, id);
      expect(section.originId, 'fam-origine');
      expect(section.receivedAt, isNotNull);
      final cards = await cardsIn(id);
      expect(cards.map((c) => c.originId).toSet(), {'a', 'b'});
      expect(cards.every((c) => c.id != 'a' && c.id != 'b'), isTrue);
      // Ora la sezione è riconosciuta come già ricevuta (decisione 79).
      expect((await previouslyReceived(db, file))!.id, id);
    },
  );

  test(
    'nuova sezione: nome già usato rifiutato, proposto "Famiglia 2"',
    () async {
      await db.createSection('Famiglia');
      expect(await proposedSectionName(db, 'Famiglia'), 'Famiglia 2');
      expect(await proposedSectionName(db, 'Sport'), 'Sport');
      await expectLater(
        runSharedImport(
          db,
          store,
          sectionFile([card('a', 'A')]),
          SharedImportMode.newSection,
          newSectionName: 'famiglia',
        ),
        throwsA(isA<TransferException>()),
      );
    },
  );

  test(
    'unisci: si salta la tessera con stessa tipologia e stesso codice',
    () async {
      final gen = (await db.defaultSection()).id;
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              typeId: 'generic',
              name: 'Mia',
              code: '777',
              codeFormat: 'code128',
              sectionId: gen,
            ),
          );
      final file = sectionFile([
        card('a', 'Uguale', code: '777'),
        card('b', 'Nuova'),
      ]);
      final plan = await planSharedImport(
        db,
        file,
        SharedImportMode.merge,
        targetSectionId: gen,
      );
      expect(plan.added, 1);
      expect(plan.skipped, 1);
      await runSharedImport(
        db,
        store,
        file,
        SharedImportMode.merge,
        targetSectionId: gen,
      );
      expect((await cardsIn(gen)).map((c) => c.name).toSet(), {'Mia', 'Nuova'});
    },
  );

  test(
    'sostituisci: via le tolte, restano le mie, preferita e uso conservati',
    () async {
      final first = sectionFile([card('a', 'Biblioteca'), card('b', 'Kiabi')]);
      final id = await runSharedImport(
        db,
        store,
        first,
        SharedImportMode.newSection,
        newSectionName: 'Famiglia',
      );
      final biblioteca = (await cardsIn(id))
          .firstWhere((c) => c.originId == 'a');
      await (db.update(
        db.cards,
      )..where((c) => c.id.equals(biblioteca.id))).write(
        CardsCompanion(
          favorite: const Value(true),
          lastUsedAt: Value(DateTime(2026, 11, 10)),
        ),
      );
      // Una tessera aggiunta da chi riceve.
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              typeId: 'generic',
              name: 'Mia',
              code: '1',
              codeFormat: 'code128',
              sectionId: id,
            ),
          );

      // Nuova copia: Biblioteca aggiornata, Kiabi tolta, Palestra nuova.
      final second = sectionFile([
        card('a', 'Biblioteca civica'),
        card('c', 'Palestra'),
      ]);
      final plan = await planSharedImport(
        db,
        second,
        SharedImportMode.replace,
        targetSectionId: id,
      );
      expect(plan.updated, 1);
      expect(plan.toTrash, 1);
      expect(plan.added, 1);
      await runSharedImport(
        db,
        store,
        second,
        SharedImportMode.replace,
        targetSectionId: id,
      );

      final cards = {for (final c in await cardsIn(id)) c.name: c};
      expect(cards.keys.toSet(), {'Biblioteca civica', 'Palestra', 'Mia'});
      final updated = cards['Biblioteca civica']!;
      expect(updated.id, biblioteca.id); // stessa tessera, aggiornata
      expect(updated.favorite, isTrue);
      expect(updated.lastUsedAt, DateTime(2026, 11, 10));
      expect(await db.trashCount(), 1); // Kiabi
    },
  );

  test(
    'tessera singola nella sezione scelta, anche oltre 50 tessere',
    () async {
      final gen = (await db.defaultSection()).id;
      final single = ArchiveContent(
        sections: const [ArchiveSection(id: 'x', name: 'Sport')],
        cards: [
          const ArchiveCard(
            id: 'z',
            typeId: 'negozio-futuro',
            name: 'Negozio',
            code: '5',
            codeFormat: 'code128',
            sectionId: 'x',
          ),
        ],
      );
      await runSharedImport(
        db,
        store,
        single,
        SharedImportMode.merge,
        targetSectionId: gen,
      );
      final c = (await cardsIn(gen)).single;
      expect(c.typeId, 'generic');
      expect(c.originId, 'z');

      for (var i = 0; i < 60; i++) {
        await db
            .into(db.cards)
            .insert(
              CardsCompanion.insert(
                typeId: 'generic',
                name: 'T$i',
                code: 'T$i',
                codeFormat: 'code128',
                sectionId: gen,
              ),
            );
      }
      final another = ArchiveContent(
        sections: single.sections,
        cards: [
          const ArchiveCard(
            id: 'y',
            typeId: 'generic',
            name: 'Altra',
            code: '6',
            codeFormat: 'code128',
            sectionId: 'x',
          ),
        ],
      );
      final plan = await planSharedImport(
        db,
        another,
        SharedImportMode.merge,
        targetSectionId: gen,
      );
      expect(plan.added, 1);
      expect(plan.result, 62);
      await runSharedImport(
        db,
        store,
        another,
        SharedImportMode.merge,
        targetSectionId: gen,
      );
      expect((await cardsIn(gen)).length, 62);
    },
  );
}
