// "Importa tutto" (videate 29–31, decisione 102): unisce un backup alle
// tessere esistenti oppure le sostituisce. Il limite si calcola sul risultato
// (decisione 17): se lo supera, non si importa niente.

import 'package:drift/drift.dart';

import '../data/database.dart';
import '../photos.dart';
import 'archive_format.dart';

enum ImportMode { merge, replace }

/// Cosa succederebbe importando, prima di farlo (per la schermata).
class ImportPlan {
  const ImportPlan({
    required this.mode,
    required this.current,
    required this.incoming,
    required this.added,
    required this.alreadyPresent,
    required this.result,
    required this.limit,
    this.toTrash = 0,
  });

  final ImportMode mode;

  /// Tessere attive ora sul telefono.
  final int current;

  /// Tessere nel file.
  final int incoming;

  /// Unisci: tessere nuove; sostituisci: tutte quelle del file.
  final int added;

  /// Unisci: tessere del file già presenti (riconosciute dall'identificativo).
  final int alreadyPresent;

  /// Tessere attive a importazione finita.
  final int result;

  /// Sostituisci: tessere attuali che finiscono davvero nel cestino (quelle
  /// presenti anche nel file restano in uso, con i dati del file).
  final int toTrash;
  final int limit;

  bool get fits => result <= limit;
}

Future<ImportPlan> planImport(
  AppDatabase db,
  ArchiveContent content,
  ImportMode mode,
) async {
  final active = (await (db.select(
    db.cards,
  )..where((c) => c.deletedAt.isNull())).get()).map((c) => c.id).toSet();
  final incoming = content.cards.length;
  final fileIds = content.cards.map((c) => c.id).toSet();
  if (mode == ImportMode.replace) {
    return ImportPlan(
      toTrash: active.where((id) => !fileIds.contains(id)).length,
      mode: mode,
      current: active.length,
      incoming: incoming,
      added: incoming,
      alreadyPresent: 0,
      result: incoming,
      limit: AppDatabase.freeCardLimit,
    );
  }
  final present = content.cards.where((c) => active.contains(c.id)).length;
  return ImportPlan(
    mode: mode,
    current: active.length,
    incoming: incoming,
    added: incoming - present,
    alreadyPresent: present,
    result: active.length + incoming - present,
    limit: AppDatabase.freeCardLimit,
  );
}

/// Importa. Restituisce il numero di tessere aggiunte (o rimesse in uso).
/// Lancia [TransferException] se il risultato supererebbe il limite.
Future<int> runImport(
  AppDatabase db,
  PhotoStore store,
  ArchiveContent content,
  ImportMode mode,
) async {
  final plan = await planImport(db, content, mode);
  if (!plan.fits) {
    throw TransferException(
      TransferProblem.limitExceeded,
      count: plan.result,
      limit: plan.limit,
    );
  }

  final existing = {for (final c in await db.select(db.cards).get()) c.id: c};
  final knownTypes = (await db.select(db.cardTypes).get())
      .map((t) => t.id)
      .toSet();
  final toImport = mode == ImportMode.replace
      ? content.cards
      : content.cards
            .where(
              (c) =>
                  existing[c.id]?.deletedAt != null ||
                  !existing.containsKey(c.id),
            )
            .toList();

  // Prima i file delle foto (fuori dalla transazione: la riduzione richiede
  // tempo); i nomi scritti si ricordano per cancellarli se qualcosa va male.
  final written = <String, Map<String, String>>{};
  try {
    for (final c in toImport) {
      for (final e in c.photos.entries) {
        final bytes = content.photos[e.value];
        if (bytes == null) continue;
        final name = await store.write(c.id, e.key, bytes);
        if (name != null) (written[c.id] ??= {})[e.key] = name;
      }
    }

    final obsolete = <String>[];
    await db.transaction(() async {
      final now = DateTime.now();
      if (mode == ImportMode.replace) {
        // Le tessere attuali vanno nel cestino per 30 giorni.
        await (db.update(db.cards)..where((c) => c.deletedAt.isNull())).write(
          CardsCompanion(deletedAt: Value(now)),
        );
      }
      final sectionMap = await _mapSections(db, content.sections);
      for (final c in toImport) {
        final values = CardsCompanion(
          id: Value(c.id),
          // Tipologia sconosciuta (app non aggiornata): diventa generica.
          typeId: Value(knownTypes.contains(c.typeId) ? c.typeId : 'generic'),
          name: Value(c.name),
          code: Value(c.code),
          codeFormat: Value(c.codeFormat),
          sectionId: Value(sectionMap[c.sectionId]!),
          holder: Value(c.holder),
          notes: Value(c.notes),
          expiresOn: Value(c.expiresOn),
          createdAt: Value(c.createdAt ?? now),
          lastUsedAt: Value(c.lastUsedAt),
          favorite: Value(c.favorite),
          deletedAt: const Value(null),
        );
        if (existing.containsKey(c.id)) {
          // Già sul telefono (anche nel cestino): si rimette in uso con i
          // dati del file, foto comprese.
          await (db.update(
            db.cards,
          )..where((x) => x.id.equals(c.id))).write(values);
          for (final side in [PhotoSide.front, PhotoSide.back]) {
            final old = await db.removeCardPhoto(c.id, side);
            if (old != null) obsolete.add(old);
          }
        } else {
          await db.into(db.cards).insert(values);
        }
        for (final e in (written[c.id] ?? const <String, String>{}).entries) {
          await db.setCardPhoto(c.id, e.key, e.value);
        }
      }
    });
    for (final f in obsolete) {
      await store.delete(f);
    }
    return toImport.length;
  } catch (_) {
    for (final files in written.values) {
      for (final f in files.values) {
        await store.delete(f);
      }
    }
    rethrow;
  }
}

/// Sezione del file → sezione del telefono. La sezione di partenza del file
/// va in quella del telefono; le altre si riconoscono dall'identificativo
/// (decisione 79), poi dal nome; se mancano si creano, con lo stesso
/// identificativo.
Future<Map<String, String>> _mapSections(
  AppDatabase db,
  List<ArchiveSection> sections,
) async {
  final all = await db.select(db.sections).get();
  final byId = {for (final s in all) s.id: s};
  final defaultId = all.firstWhere((s) => s.isDefault).id;
  final map = <String, String>{};
  for (final s in sections) {
    if (s.isDefault) {
      map[s.id] = defaultId;
      continue;
    }
    final same = byId[s.id];
    if (same != null) {
      if (same.hidden) {
        await (db.update(db.sections)..where((x) => x.id.equals(s.id))).write(
          const SectionsCompanion(hidden: Value(false)),
        );
      }
      map[s.id] = s.id;
      continue;
    }
    final byName = all.where(
      (x) => !x.hidden && x.name.toLowerCase() == s.name.toLowerCase(),
    );
    if (byName.isNotEmpty) {
      map[s.id] = byName.first.id;
      continue;
    }
    await db
        .into(db.sections)
        .insert(SectionsCompanion.insert(id: Value(s.id), name: s.name));
    map[s.id] = s.id;
  }
  return map;
}
