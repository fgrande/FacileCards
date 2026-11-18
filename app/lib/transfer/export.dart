// "Esporta tutto" (videate 32, 33) e condivisione di una sezione o di una
// tessera (videate 9, 10): raccoglie sezioni, tessere e foto e costruisce il
// file `.facilecards`. Le tessere nel cestino non si esportano (decisione 20).

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show compute;

import '../data/database.dart';
import '../photos.dart';
import 'archive_format.dart';
import 'crypto.dart';

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

/// Cosa si esporta: tutto (backup), una sezione o una tessera
/// (condivisione, decisione 23).
class ExportTarget {
  const ExportTarget.all()
      : kind = ArchiveKind.all,
        sectionId = null,
        cardId = null;
  const ExportTarget.section(String this.sectionId)
      : kind = ArchiveKind.section,
        cardId = null;
  const ExportTarget.card(String this.cardId)
      : kind = ArchiveKind.card,
        sectionId = null;

  final ArchiveKind kind;
  final String? sectionId;
  final String? cardId;
}

/// Tessere da esportare (mai quelle nel cestino).
Future<List<Card>> _targetCards(AppDatabase db, ExportTarget t) =>
    (db.select(db.cards)
          ..where((c) {
            var where = c.deletedAt.isNull();
            if (t.sectionId != null) where &= c.sectionId.equals(t.sectionId!);
            if (t.cardId != null) where &= c.id.equals(t.cardId!);
            return where;
          }))
        .get();

Future<ExportSummary> exportSummary(AppDatabase db, PhotoStore store,
    [ExportTarget target = const ExportTarget.all()]) async {
  final cards = await _targetCards(db, target);
  final sections = target.kind == ArchiveKind.all
      ? (await db.visibleSections()).length
      : 1;
  final ids = cards.map((c) => c.id).toSet();
  var bytes = 2048 + cards.length * 600; // dati, a occhio
  for (final img in await db.select(db.cardImages).get()) {
    if (!ids.contains(img.cardId)) continue;
    final f = store.file(img.fileName);
    if (await f.exists()) bytes += await f.length();
  }
  return ExportSummary(cards: cards.length, sections: sections, bytes: bytes);
}

/// Tutto il contenuto del backup completo.
Future<ArchiveContent> collectBackup(AppDatabase db, PhotoStore store) =>
    collectContent(db, store, const ExportTarget.all());

/// Il contenuto da esportare. Nel backup viaggiano anche il nome del
/// proprietario e i dati personali (preferita, date di inserimento e di
/// ultimo uso); nella condivisione no (analisi, 5.2).
Future<ArchiveContent> collectContent(
    AppDatabase db, PhotoStore store, ExportTarget target) async {
  final backup = target.kind == ArchiveKind.all;
  final cards = await _targetCards(db, target);
  final List<Section> sections;
  if (backup) {
    sections = await db.visibleSections();
  } else {
    // Una sola sezione: quella condivisa, o quella della tessera.
    final id = target.sectionId ?? (cards.isEmpty ? null : cards.first.sectionId);
    sections = id == null
        ? const []
        : await (db.select(db.sections)..where((s) => s.id.equals(id))).get();
  }
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
      createdAt: backup ? c.createdAt : null,
      lastUsedAt: backup ? c.lastUsedAt : null,
      favorite: backup && c.favorite,
      photos: cardPhotos,
    ));
  }
  final owner = backup ? await db.setting(SettingKeys.holderName) : null;
  return ArchiveContent(
    owner: (owner == null || owner.trim().isEmpty) ? null : owner.trim(),
    sections: [
      for (final s in sections)
        ArchiveSection(
            id: s.id, name: s.name, isDefault: backup && s.isDefault),
    ],
    cards: archiveCards,
    photos: photos,
  );
}

/// Costruisce il file del backup completo (vedi [buildExportFile]).
Future<Uint8List> buildBackupFile(AppDatabase db, PhotoStore store,
        {DateTime? now, String? password}) =>
    buildExportFile(db, store, const ExportTarget.all(),
        now: now, password: password);

/// Costruisce il file, protetto da [password] se c'è (decisione 103).
/// Compressione e cifratura girano in un isolate, per non bloccare
/// l'interfaccia.
Future<Uint8List> buildExportFile(
    AppDatabase db, PhotoStore store, ExportTarget target,
    {DateTime? now, String? password}) async {
  final content = await collectContent(db, store, target);
  return compute(_encodeExport, (
    kind: target.kind,
    createdAt: now ?? DateTime.now(),
    content: content,
    password: password,
  ));
}

/// Funzione a sé, perché all'isolate passino solo i dati (vedi
/// `_readArchiveFile` in import_screen.dart).
Future<Uint8List> _encodeExport(
    ({
      ArchiveKind kind,
      DateTime createdAt,
      ArchiveContent content,
      String? password,
    }) a) async {
  final plain = encodeContent(a.content);
  final password = a.password;
  if (password == null) {
    return encodeArchive(
        ArchiveHeader(kind: a.kind, createdAt: a.createdAt), plain);
  }
  final enc = await encryptContent(plain, password);
  return encodeArchive(
      ArchiveHeader(kind: a.kind, createdAt: a.createdAt, encryption: enc.params),
      enc.data);
}

/// Nome del file di una sezione o di una tessera condivisa ("Famiglia.facilecards"),
/// senza i caratteri che i telefoni non accettano nei nomi dei file.
String sharedFileName(String name) {
  final clean = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '-').trim();
  return '${clean.isEmpty ? 'FacileCards' : clean}$archiveExtension';
}

/// Sopra questa misura l'app avvisa prima di condividere (decisione 92).
const largeShareBytes = 20 * 1024 * 1024;

/// Scrive il file in una cartella temporanea e restituisce il percorso.
Future<String> writeTempFile(Directory dir, String name, Uint8List bytes) async {
  final f = File('${dir.path}/$name');
  await f.writeAsBytes(bytes, flush: true);
  return f.path;
}
