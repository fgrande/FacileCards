// "Esporta tutto" (videate 32, 33): raccoglie sezioni, tessere e foto e
// costruisce il file `.facilecards`. Le tessere nel cestino non si esportano
// (decisione 20).

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;

import '../data/database.dart';
import '../photos.dart';
import 'archive_format.dart';

/// Riepilogo per il passo 1: quante tessere e sezioni, peso stimato.
class ExportSummary {
  const ExportSummary(
      {required this.cards, required this.sections, required this.bytes});
  final int cards;
  final int sections;
  final int bytes;
}

/// Nome proposto per il file (decisione 112).
String backupFileName(DateTime now) =>
    'FacileCards-${now.year}-${now.month.toString().padLeft(2, '0')}-'
    '${now.day.toString().padLeft(2, '0')}$archiveExtension';

/// "circa 12 MB", "circa 300 KB".
String sizeLabel(int bytes) {
  if (bytes >= 1024 * 1024) {
    final mb = bytes / (1024 * 1024);
    return 'circa ${mb < 10 ? mb.toStringAsFixed(1).replaceAll('.', ',') : mb.round()} MB';
  }
  return 'circa ${(bytes / 1024).ceil().clamp(1, 1023)} KB';
}

Future<ExportSummary> exportSummary(AppDatabase db, PhotoStore store) async {
  final cards = await (db.select(db.cards)..where((c) => c.deletedAt.isNull()))
      .get();
  final sections = await db.visibleSections();
  final ids = cards.map((c) => c.id).toSet();
  var bytes = 2048 + cards.length * 600; // dati, a occhio
  for (final img in await db.select(db.cardImages).get()) {
    if (!ids.contains(img.cardId)) continue;
    final f = store.file(img.fileName);
    if (await f.exists()) bytes += await f.length();
  }
  return ExportSummary(
      cards: cards.length, sections: sections.length, bytes: bytes);
}

/// Tutto il contenuto da esportare.
Future<ArchiveContent> collectBackup(AppDatabase db, PhotoStore store) async {
  final owner = await db.setting(SettingKeys.holderName);
  final sections = await db.visibleSections();
  final cards = await (db.select(db.cards)..where((c) => c.deletedAt.isNull()))
      .get();
  final photos = <String, Uint8List>{};
  final archiveCards = <ArchiveCard>[];
  for (final c in cards) {
    final cardPhotos = <String, String>{};
    for (final e in (await db.cardPhotos(c.id)).entries) {
      final f = store.file(e.value);
      if (!await f.exists()) continue;
      final path = 'photos/${c.id}-${e.key}.jpg';
      photos[path] = await f.readAsBytes();
      cardPhotos[e.key] = path;
    }
    archiveCards.add(ArchiveCard(
      id: c.id,
      typeId: c.typeId,
      name: c.name,
      code: c.code,
      codeFormat: c.codeFormat,
      sectionId: c.sectionId,
      holder: c.holder,
      notes: c.notes,
      expiresOn: c.expiresOn,
      createdAt: c.createdAt,
      lastUsedAt: c.lastUsedAt,
      favorite: c.favorite,
      photos: cardPhotos,
    ));
  }
  return ArchiveContent(
    owner: (owner == null || owner.trim().isEmpty) ? null : owner.trim(),
    sections: [
      for (final s in sections)
        ArchiveSection(id: s.id, name: s.name, isDefault: s.isDefault),
    ],
    cards: archiveCards,
    photos: photos,
  );
}

/// Costruisce il file del backup completo. La compressione gira in un
/// isolate, per non bloccare l'interfaccia.
Future<Uint8List> buildBackupFile(AppDatabase db, PhotoStore store,
    {DateTime? now}) async {
  final content = await collectBackup(db, store);
  final header =
      ArchiveHeader(kind: ArchiveKind.all, createdAt: now ?? DateTime.now());
  return compute(_encodeBackup, (header: header, content: content));
}

/// Funzione a sé, perché all'isolate passino solo i dati (vedi
/// `_readArchiveFile` in import_screen.dart).
Uint8List _encodeBackup(({ArchiveHeader header, ArchiveContent content}) a) =>
    encodeArchive(a.header, encodeContent(a.content));

/// Scrive il file in una cartella temporanea e restituisce il percorso.
Future<String> writeTempFile(Directory dir, String name, Uint8List bytes) async {
  final f = File('${dir.path}/$name');
  await f.writeAsBytes(bytes, flush: true);
  return f.path;
}
