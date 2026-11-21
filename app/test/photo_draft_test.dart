import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:facilecards/photo_draft.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bozza salvata prima di aprire la fotocamera (photo_draft.dart): se Android
/// chiude l'app, al riavvio la pagina si riapre con questi dati.
void main() {
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('facilecards_draft');
    PhotoDraft.testDirectory = dir;
  });
  tearDown(() async {
    PhotoDraft.testDirectory = null;
    await dir.delete(recursive: true);
  });

  test('si salva e si rilegge, con le foto già scelte', () async {
    final front = Uint8List.fromList([1, 2, 3]);
    await PhotoDraft(
      kind: DraftKind.form,
      side: 'back',
      data: {'typeId': 'conad', 'name': 'Conad', 'expiresOn': null},
      photos: {'front': front},
    ).save();

    final draft = (await PhotoDraft.load())!;
    expect(draft.kind, DraftKind.form);
    expect(draft.side, 'back');
    expect(draft.data['name'], 'Conad');
    expect(draft.photos['front'], front);

    await PhotoDraft.clear();
    expect(await PhotoDraft.load(), isNull);
  });

  test('senza bozza o con una bozza vecchia non si riapre niente', () async {
    expect(await PhotoDraft.load(), isNull);
    await cardPhotoDraft('c1', 'front').save();
    // La bozza risale a due ore fa: l'app si era chiusa per altri motivi.
    final main = File('${dir.path}/draft/draft.json');
    final json = jsonDecode(await main.readAsString()) as Map<String, dynamic>;
    json['savedAt'] = DateTime.now()
        .subtract(const Duration(hours: 2))
        .toIso8601String();
    await main.writeAsString(jsonEncode(json));
    expect(await PhotoDraft.load(), isNull);
    expect(await main.exists(), isFalse);
  });
}
