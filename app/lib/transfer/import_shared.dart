// Ricezione di una sezione (videata 11, decisioni 16, 18, 79, 80) o di una
// singola tessera (decisione 107). Le tessere ricevute diventano del tutto
// tessere di chi le riceve, con un identificativo nuovo; ricordano solo
// quello d'origine (`originId`) per riconoscere una copia successiva.

import 'package:drift/drift.dart';

import '../data/database.dart';
import '../photos.dart';
import 'archive_format.dart';

/// Dove mettere le tessere ricevute (videata 11).
enum SharedImportMode {
  /// Una sezione nuova, col nome scelto (non già usato).
  newSection,

  /// In una sezione esistente: solo le tessere che non ci sono già.
  merge,

  /// Al posto della copia ricevuta prima (decisione 80).
  replace,
}

class SharedImportPlan {
  const SharedImportPlan({
    required this.added,
    required this.updated,
    required this.toTrash,
    required this.skipped,
    required this.result,
  });

  /// Tessere nuove.
  final int added;

  /// Sostituisci: tessere della copia precedente aggiornate col file.
  final int updated;

  /// Sostituisci: tessere della copia precedente che il file non ha più.
  final int toTrash;

  /// Unisci: tessere già presenti nella sezione, che non si aggiungono.
  final int skipped;

  /// Tessere attive a importazione finita.
  final int result;
}

/// La sezione del telefono che è una copia ricevuta prima di quella nel file
/// (riconosciuta dall'identificativo d'origine, decisione 79), se c'è.
Future<Section?> previouslyReceived(
  AppDatabase db,
  ArchiveContent content,
) async {
  if (content.sections.length != 1) return null;
  final origin = content.sections.single.id;
  final found = await (db.select(
    db.sections,
  )..where((s) => s.originId.equals(origin) & s.hidden.equals(false))).get();
  return found.isEmpty ? null : found.first;
}

/// Nome proposto per una sezione nuova: quello originale o, se è già usato,
/// "Famiglia 2", "Famiglia 3"…
Future<String> proposedSectionName(AppDatabase db, String name) async {
  if (!await db.sectionNameInUse(name)) return name;
  for (var i = 2; ; i++) {
    final candidate = '$name $i';
    if (!await db.sectionNameInUse(candidate)) return candidate;
  }
}

String _key(String typeId, String code) => '$typeId\u0000$code';

Future<Set<String>> _knownTypes(AppDatabase db) async =>
    (await db.select(db.cardTypes).get()).map((t) => t.id).toSet();

Future<List<Card>> _activeIn(AppDatabase db, String sectionId) => (db.select(
  db.cards,
)..where((c) => c.sectionId.equals(sectionId) & c.deletedAt.isNull())).get();

Future<SharedImportPlan> planSharedImport(
  AppDatabase db,
  ArchiveContent content,
  SharedImportMode mode, {
  String? targetSectionId,
}) async {
  final current = await db.activeCardCount();
  final types = await _knownTypes(db);
  String typeOf(ArchiveCard c) =>
      types.contains(c.typeId) ? c.typeId : 'generic';

  switch (mode) {
    case SharedImportMode.newSection:
      final n = content.cards.length;
      return SharedImportPlan(
        added: n,
        updated: 0,
        toTrash: 0,
        skipped: 0,
        result: current + n,
      );
    case SharedImportMode.merge:
      final existing = await _activeIn(db, targetSectionId!);
      final keys = existing.map((c) => _key(c.typeId, c.code)).toSet();
      final origins = existing
          .map((c) => c.originId)
          .whereType<String>()
          .toSet();
      var added = 0;
      for (final c in content.cards) {
        if (origins.contains(c.id) || !keys.add(_key(typeOf(c), c.code))) {
          continue;
        }
        added++;
      }
      final skipped = content.cards.length - added;
      return SharedImportPlan(
        added: added,
        updated: 0,
        toTrash: 0,
        skipped: skipped,
        result: current + added,
      );
    case SharedImportMode.replace:
      final existing = await _activeIn(db, targetSectionId!);
      final fileIds = content.cards.map((c) => c.id).toSet();
      final fromCopy = existing.where((c) => c.originId != null).toList();
      final updated = fromCopy
          .where((c) => fileIds.contains(c.originId))
          .length;
      final toTrash = fromCopy.length - updated;
      final added = content.cards.length - updated;
      return SharedImportPlan(
        added: added,
        updated: updated,
        toTrash: toTrash,
        skipped: 0,
        result: current + added - toTrash,
      );
  }
}

/// Importa. Restituisce l'identificativo della sezione in cui sono andate le
/// tessere. Lancia [TransferException] se il nome non va bene.
Future<String> runSharedImport(
  AppDatabase db,
  PhotoStore store,
  ArchiveContent content,
  SharedImportMode mode, {
  String? targetSectionId,
  String? newSectionName,
}) async {
  final name = newSectionName?.trim() ?? '';
  if (mode == SharedImportMode.newSection &&
      (name.isEmpty || await db.sectionNameInUse(name))) {
    throw const TransferException(TransferProblem.sectionNameTaken);
  }
  final types = await _knownTypes(db);
  String typeOf(ArchiveCard c) =>
      types.contains(c.typeId) ? c.typeId : 'generic';
  final now = DateTime.now();
  final origin = content.sections.length == 1
      ? content.sections.single.id
      : null;

  // Quali tessere del file entrano, e con quale identificativo locale.
  final sectionId = mode == SharedImportMode.newSection
      ? newId()
      : targetSectionId!;
  final existing = mode == SharedImportMode.newSection
      ? const <Card>[]
      : await _activeIn(db, sectionId);
  final byOrigin = {
    for (final c in existing)
      if (c.originId != null) c.originId!: c,
  };
  final keys = existing.map((c) => _key(c.typeId, c.code)).toSet();
  final incoming = <({ArchiveCard card, String localId, Card? previous})>[];
  for (final c in content.cards) {
    switch (mode) {
      case SharedImportMode.newSection:
        incoming.add((card: c, localId: newId(), previous: null));
      case SharedImportMode.merge:
        if (byOrigin.containsKey(c.id) || !keys.add(_key(typeOf(c), c.code))) {
          continue;
        }
        incoming.add((card: c, localId: newId(), previous: null));
      case SharedImportMode.replace:
        final previous = byOrigin[c.id];
        incoming.add((
          card: c,
          localId: previous?.id ?? newId(),
          previous: previous,
        ));
    }
  }

  // Prima i file delle foto, poi tutto il database in una transazione.
  final written = <String, Map<String, String>>{};
  try {
    for (final i in incoming) {
      for (final e in i.card.photos.entries) {
        final bytes = content.photos[e.value];
        if (bytes == null) continue;
        final file = await store.write(i.localId, e.key, bytes);
        if (file != null) (written[i.localId] ??= {})[e.key] = file;
      }
    }
    final obsolete = <String>[];
    await db.transaction(() async {
      if (mode == SharedImportMode.newSection) {
        await db
            .into(db.sections)
            .insert(
              SectionsCompanion.insert(
                id: Value(sectionId),
                name: name,
                originId: Value(origin),
                receivedAt: Value(now),
              ),
            );
      } else if (mode == SharedImportMode.replace) {
        // Decisione 80: via (nel cestino) le tessere della copia precedente
        // che il file non ha più; restano quelle aggiunte da chi riceve.
        final fileIds = content.cards.map((c) => c.id).toSet();
        for (final c in existing) {
          if (c.originId != null && !fileIds.contains(c.originId)) {
            await db.moveCardToTrash(c.id);
          }
        }
        await (db.update(db.sections)..where((s) => s.id.equals(sectionId)))
            .write(SectionsCompanion(receivedAt: Value(now)));
      }
      for (final i in incoming) {
        final c = i.card;
        final values = CardsCompanion(
          typeId: Value(typeOf(c)),
          name: Value(c.name),
          code: Value(c.code),
          codeFormat: Value(c.codeFormat),
          holder: Value(c.holder),
          notes: Value(c.notes),
          expiresOn: Value(c.expiresOn),
        );
        if (i.previous != null) {
          // Presente prima e dopo: dati del file, ma preferita e ultimo uso
          // restano quelli di chi riceve (decisione 80).
          await (db.update(
            db.cards,
          )..where((x) => x.id.equals(i.localId))).write(values);
          final newPhotos = written[i.localId] ?? const <String, String>{};
          for (final side in [PhotoSide.front, PhotoSide.back]) {
            if (newPhotos.containsKey(side)) continue;
            final old = await db.removeCardPhoto(i.localId, side);
            if (old != null) obsolete.add(old);
          }
          for (final e in newPhotos.entries) {
            final old = await db.setCardPhoto(i.localId, e.key, e.value);
            if (old != null) obsolete.add(old);
          }
        } else {
          await db
              .into(db.cards)
              .insert(
                values.copyWith(
                  id: Value(i.localId),
                  sectionId: Value(sectionId),
                  originId: Value(c.id),
                  createdAt: Value(now),
                ),
              );
          for (final e
              in (written[i.localId] ?? const <String, String>{}).entries) {
            await db.setCardPhoto(i.localId, e.key, e.value);
          }
        }
      }
    });
    for (final f in obsolete) {
      await store.delete(f);
    }
    return sectionId;
  } catch (_) {
    for (final files in written.values) {
      for (final f in files.values) {
        await store.delete(f);
      }
    }
    rethrow;
  }
}
