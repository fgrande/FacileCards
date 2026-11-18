import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/photos.dart';
import 'package:facilecards/transfer/archive_format.dart';
import 'package:facilecards/transfer/export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formato .facilecards', () {
    final content = ArchiveContent(
      owner: 'Fabio Grande',
      sections: const [
        ArchiveSection(id: 'sez-1', name: 'Generale', isDefault: true),
        ArchiveSection(id: 'sez-2', name: 'Sport'),
      ],
      cards: [
        ArchiveCard(
          id: 'card-1',
          typeId: 'carrefour',
          name: 'Carrefour',
          code: '2400123456780',
          codeFormat: 'ean13',
          sectionId: 'sez-1',
          holder: 'Fabio Grande',
          notes: 'Punti doppi il martedì',
          expiresOn: DateTime(2027, 12, 31),
          createdAt: DateTime(2026, 10, 3, 9, 30),
          lastUsedAt: DateTime(2026, 11, 17, 18),
          favorite: true,
          photos: const {'front': 'photos/card-1-front.jpg'},
        ),
        const ArchiveCard(
          id: 'card-2',
          typeId: 'decathlon',
          name: 'Decathlon',
          code: 'ABC 123',
          codeFormat: 'code128',
          sectionId: 'sez-2',
        ),
      ],
      photos: {
        'photos/card-1-front.jpg': Uint8List.fromList([1, 2, 3, 4, 5]),
      },
    );
    final header = ArchiveHeader(
        kind: ArchiveKind.all, createdAt: DateTime(2026, 11, 18, 10));

    test('scrivere e rileggere dà lo stesso contenuto', () {
      final bytes = encodeArchive(header, encodeContent(content));
      final read = decodeArchive(bytes);
      expect(read.header.kind, ArchiveKind.all);
      expect(read.header.encrypted, isFalse);
      expect(read.header.createdAt, DateTime(2026, 11, 18, 10));
      final back = decodeContent(read.content);
      expect(back.owner, 'Fabio Grande');
      expect(back.sections.map((s) => s.name), ['Generale', 'Sport']);
      expect(back.sections.first.isDefault, isTrue);
      final c = back.cards.first;
      expect(c.code, '2400123456780');
      expect(c.codeFormat, 'ean13');
      expect(c.notes, 'Punti doppi il martedì');
      expect(c.expiresOn, DateTime(2027, 12, 31));
      expect(c.createdAt, DateTime(2026, 10, 3, 9, 30));
      expect(c.lastUsedAt, DateTime(2026, 11, 17, 18));
      expect(c.favorite, isTrue);
      expect(back.photos['photos/card-1-front.jpg'], [1, 2, 3, 4, 5]);
      expect(back.cards[1].holder, isNull);
      expect(back.cards[1].favorite, isFalse);
      // Il codice non si accorcia: gli spazi fanno parte del codice.
      expect(back.cards[1].code, 'ABC 123');
    });

    test('un file qualunque non si accetta', () {
      expect(() => decodeArchive(Uint8List.fromList(utf8.encode('ciao'))),
          throwsA(isA<TransferException>()));
      final otherZip = ZipEncoder().encodeBytes(
          Archive()..add(ArchiveFile.string('readme.txt', 'ciao')));
      expect(() => decodeArchive(otherZip), throwsA(isA<TransferException>()));
    });

    test('un file di una versione più recente chiede di aggiornare l\'app', () {
      final future = ZipEncoder().encodeBytes(Archive()
        ..add(ArchiveFile.string(
            'header.json',
            jsonEncode({
              'format': 'facilecards',
              'version': archiveFormatVersion + 1,
              'kind': 'all',
              'createdAt': '2030-01-01T00:00:00Z',
            }))));
      expect(
          () => decodeArchive(future),
          throwsA(isA<TransferException>().having(
              (e) => e.message, 'message', contains('più recente'))));
    });

    Uint8List withData(Map<String, Object?> data) => ZipEncoder().encodeBytes(
        Archive()..add(ArchiveFile.string('data.json', jsonEncode(data))));

    test('dati non validi nel file si rifiutano', () {
      final good = {
        'sections': [
          {'id': 's1', 'name': 'Generale'}
        ],
        'cards': [
          {
            'id': 'c1',
            'typeId': 'generic',
            'name': 'Tessera',
            'code': '123',
            'format': 'code128',
            'sectionId': 's1',
          }
        ],
      };
      expect(decodeContent(withData(good)).cards.single.name, 'Tessera');

      Map<String, Object?> card(Map<String, Object?> change) => {
            'sections': good['sections'],
            'cards': [
              {...(good['cards'] as List).first as Map<String, Object?>, ...change}
            ],
          };
      for (final bad in [
        card({'code': ''}), // codice vuoto
        card({'sectionId': 'altra'}), // sezione che non c'è
        card({'id': '../x'}), // identificativo strano
        card({'name': 'x' * 101}), // nome troppo lungo
        card({'expiresOn': 'domani'}), // data non valida
        card({'photos': {'front': '../../etc/passwd'}}), // percorso fuori posto
        card({'name': 42}), // tipo sbagliato
      ]) {
        expect(() => decodeContent(withData(bad)),
            throwsA(isA<TransferException>()),
            reason: jsonEncode(bad));
      }
    });
  });

  group('Esporta tutto', () {
    late AppDatabase db;
    late Directory dir;
    late PhotoStore store;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dir = await Directory.systemTemp.createTemp('facilecards_export');
      store = PhotoStore(dir);
    });
    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    Future<String> add(String name, {bool trashed = false}) async {
      final id = newId();
      await db.into(db.cards).insert(CardsCompanion.insert(
          id: Value(id),
          typeId: 'generic',
          name: name,
          code: name,
          codeFormat: 'code128',
          sectionId: (await db.defaultSection()).id,
          deletedAt: Value(trashed ? DateTime.now() : null)));
      return id;
    }

    test('esporta tessere e foto, non il cestino', () async {
      await db.completeSetup(
          holderName: 'Fabio Grande',
          language: 'it',
          expiryAlerts: true,
          expiryDays: 30);
      final id = await add('Palestra');
      await add('Vecchia', trashed: true);
      File('${dir.path}/foto.jpg').writeAsBytesSync([9, 8, 7]);
      await db.setCardPhoto(id, PhotoSide.front, 'foto.jpg');

      final summary = await exportSummary(db, store);
      expect(summary.cards, 1);
      expect(summary.sections, 1);

      final bytes = await buildBackupFile(db, store);
      final read = decodeArchive(bytes);
      final content = decodeContent(read.content);
      expect(content.owner, 'Fabio Grande');
      expect(content.cards.map((c) => c.name), ['Palestra']);
      final path = content.cards.single.photos['front']!;
      expect(content.photos[path], [9, 8, 7]);
    });

    test('nome del file e peso stimato', () {
      expect(backupFileName(DateTime(2026, 11, 8)),
          'FacileCards-2026-11-08.facilecards');
      expect(sizeLabel(12 * 1024 * 1024), 'circa 12 MB');
      expect(sizeLabel(1536 * 1024), 'circa 1,5 MB');
      expect(sizeLabel(300 * 1024), 'circa 300 KB');
    });
  });
}
