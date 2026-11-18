import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/photos.dart';
import 'package:facilecards/transfer/archive_format.dart';
import 'package:facilecards/transfer/crypto.dart';
import 'package:facilecards/transfer/export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Nelle prove si usano poche ripetizioni, per far presto.
  const fast = 10000;
  final plain = Uint8List.fromList(utf8.encode('tessere segrete'));

  test('con la password giusta si rilegge', () async {
    final enc = await encryptContent(plain, 'password1', iterations: fast);
    expect(enc.data, isNot(containsAllInOrder(plain)));
    final back = await decryptContent(enc.data, enc.params, 'password1');
    expect(utf8.decode(back), 'tessere segrete');
  });

  test('con la password sbagliata no, e si può riprovare', () async {
    final enc = await encryptContent(plain, 'password1', iterations: fast);
    await expectLater(decryptContent(enc.data, enc.params, 'password2'),
        throwsA(isA<WrongPasswordException>()));
    final back = await decryptContent(enc.data, enc.params, 'password1');
    expect(utf8.decode(back), 'tessere segrete');
  });

  test('un byte cambiato nel file si scopre', () async {
    final enc = await encryptContent(plain, 'password1', iterations: fast);
    final broken = Uint8List.fromList(enc.data)..[0] ^= 1;
    await expectLater(decryptContent(broken, enc.params, 'password1'),
        throwsA(isA<WrongPasswordException>()));
  });

  test('parametri assurdi nel file si rifiutano', () async {
    final enc = await encryptContent(plain, 'password1', iterations: fast);
    for (final change in [
      {'iterations': 999999999}, // bloccherebbe il telefono
      {'iterations': 10}, // troppo poche
      {'cipher': 'ROT13'},
      {'salt': '!!!'},
    ]) {
      await expectLater(
          decryptContent(enc.data, {...enc.params, ...change}, 'password1'),
          throwsA(isA<TransferException>()),
          reason: '$change');
    }
  });

  test('regole della password (videata 33)', () {
    expect(passwordProblem('corta', 'corta'), isNotNull);
    expect(passwordProblem('password1', 'password2'), isNotNull);
    expect(passwordProblem('password1', 'password1'), isNull);
  });

  test('Esporta tutto con password: intestazione in chiaro, contenuto no',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final dir = await Directory.systemTemp.createTemp('facilecards_crypto');
    addTearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });
    await db.into(db.cards).insert(CardsCompanion.insert(
        typeId: 'generic',
        name: 'Palestra segreta',
        code: '777',
        codeFormat: 'code128',
        sectionId: (await db.defaultSection()).id));
    final bytes = await buildBackupFile(db, PhotoStore(dir),
        password: 'password1');
    // Né il nome né il codice si leggono nel file.
    expect(latin1.decode(bytes, allowInvalid: true), isNot(contains('Palestra')));
    final read = decodeArchive(bytes);
    expect(read.header.encrypted, isTrue);
    expect(read.header.encryption!['iterations'], kdfIterations);
    final content = decodeContent(await decryptContent(
        read.content, read.header.encryption!, 'password1'));
    expect(content.cards.single.name, 'Palestra segreta');
  });
}
