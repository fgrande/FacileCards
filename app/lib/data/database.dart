import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'migration_backup.dart';

import 'catalog.dart';

part 'database.g.dart';

const _uuid = Uuid();
String newId() => _uuid.v4();

/// Nome della sezione predefinita (la traduzione si farà nell'interfaccia).
const defaultSectionName = 'Generale';

/// Lingue proposte nella configurazione iniziale (spagnolo e tedesco sono
/// predisposti ma non ancora offerti).
const supportedLanguages = ['it', 'en', 'fr'];

/// Nome della sezione di partenza nella lingua scelta (decisione 84; i nomi
/// non italiani sono da confermare).
const defaultSectionNames = {
  'it': 'Generale',
  'en': 'General',
  'fr': 'Général',
  'es': 'General',
  'de': 'Allgemein',
};

/// Chiavi della tabella delle impostazioni.
abstract final class SettingKeys {
  static const setupDone = 'setupDone';
  static const holderName = 'holderName';
  static const language = 'language';
  static const expiryAlerts = 'expiryAlerts';
  static const expiryDays = 'expiryDays';
  static const theme = 'theme'; // 'system' | 'light' | 'dark'
  static const listView = 'listView'; // 'all' | 'bySection'
  static const listSort = 'listSort'; // 'lastUsed' | 'name'
  static const catalogSignature = 'catalogSignature'; // impronta del catalogo
  static const lastBackupAt = 'lastBackupAt'; // ultima "Esporta tutto"
  static const lastBackupUri = 'lastBackupUri'; // dove si è salvato (dec. 112)
}

/// Sezione. Una sezione eliminata che ha ancora tessere nel cestino resta
/// registrata e nascosta (hidden), finché quelle tessere non vengono
/// recuperate o cancellate.
class Sections extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get name => text()(); // unico tra le sezioni visibili (controllo nel codice)
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();

  /// Sezione ricevuta da un altro telefono: identificativo che aveva là
  /// (decisione 79) e quando è arrivata. Null per le sezioni create qui.
  TextColumn get originId => text().nullable()(); // dalla versione 2
  DateTimeColumn get receivedAt => dateTime().nullable()(); // dalla versione 2

  @override
  Set<Column> get primaryKey => {id};
}

/// Catalogo delle tipologie (incluse la "Generica" e quelle ritirate).
class CardTypes extends Table {
  TextColumn get id => text()(); // identificativo stabile, es. "generic"
  TextColumn get name => text()();
  TextColumn get logo => text().nullable()();
  IntColumn get color => integer().nullable()(); // ARGB
  TextColumn get codeFormat => text().nullable()(); // facoltativo
  TextColumn get category => text().withDefault(const Constant('altro'))();
  TextColumn get country => text().nullable()();
  BoolColumn get isGeneric => boolean().withDefault(const Constant(false))();
  BoolColumn get retired => boolean().withDefault(const Constant(false))();
  DateTimeColumn get retiredOn => dateTime().nullable()();
  TextColumn get replacedBy => text().nullable()();
  BoolColumn get replacementNeedsNewCode =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Cards extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get typeId => text().references(CardTypes, #id)();
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get codeFormat => text()(); // salvato sempre sulla singola tessera
  TextColumn get notes => text().nullable()();
  TextColumn get holder => text().nullable()();
  DateTimeColumn get expiresOn => dateTime().nullable()();
  TextColumn get sectionId => text().references(Sections, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // cestino

  /// Tessera ricevuta: identificativo che aveva sul telefono di chi l'ha
  /// mandata, per riconoscerla in una copia successiva (decisione 80).
  TextColumn get originId => text().nullable()(); // dalla versione 2

  @override
  Set<Column> get primaryKey => {id};
}

/// Fotografie della tessera: lato "front" o "back", file nello spazio privato.
class CardImages extends Table {
  TextColumn get cardId => text().references(Cards, #id)();
  TextColumn get side => text()(); // 'front' | 'back'
  TextColumn get fileName => text()();

  @override
  Set<Column> get primaryKey => {cardId, side};
}

/// Impostazioni semplici chiave/valore (lingua, tema, ordinamento, ...).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Sections, CardTypes, Cards, CardImages, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(driftDatabase(
          name: 'facilecards',
          native: const DriftNativeOptions(setup: backupBeforeMigration),
        ));

  /// Per i test (database in memoria).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => currentSchemaVersion;

  /// Versione dello schema. A ogni cambio: un passo in [migration], lo
  /// schema salvato in `test/fixtures/` e una prova (decisione 88).
  static const currentSchemaVersion = 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(sections).insert(SectionsCompanion.insert(
            name: defaultSectionName,
            isDefault: const Value(true),
          ));
          await into(cardTypes).insert(CardTypesCompanion.insert(
            id: 'generic',
            name: 'Generica',
            isGeneric: const Value(true),
          ));
        },
        // Il catalogo delle tipologie si riallinea solo quando cambia (cioè
        // con una nuova versione dell'app): a ogni avvio si confronta solo la
        // sua impronta. Il cestino si svuota dopo la prima schermata (main.dart).
        beforeOpen: (details) => syncCatalog(),
        // Un passo per versione, in ordine. Prima di migrare il database si
        // copia accanto all'originale (vedi [backupBeforeMigration]).
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Versione 2 (18 nov 2026): identificativi d'origine per la
            // condivisione.
            await m.addColumn(sections, sections.originId);
            await m.addColumn(sections, sections.receivedAt);
            await m.addColumn(cards, cards.originId);
          }
        },
      );

  /// Riallinea le tipologie al catalogo dell'app se l'impronta salvata è
  /// diversa. Restituisce true se ha scritto.
  Future<bool> syncCatalog() async {
    final types = catalogTypes();
    final signature = catalogSignature(types);
    if (await setting(SettingKeys.catalogSignature) == signature) return false;
    await transaction(() async {
      await batch((b) => b.insertAllOnConflictUpdate(cardTypes, types));
      await setSetting(SettingKeys.catalogSignature, signature);
    });
    return true;
  }

  /// Limite della versione gratuita (la versione Pro non ha limite).
  static const freeCardLimit = 50;

  Future<int> activeCardCount() async =>
      (await (select(cards)..where((c) => c.deletedAt.isNull())).get()).length;

  Future<List<Section>> visibleSections() => (select(sections)
        ..where((s) => s.hidden.equals(false))
        ..orderBy([(s) => OrderingTerm.asc(s.name)]))
      .get();

  /// Tipologie attive (non ritirate), in ordine alfabetico.
  Future<List<CardType>> activeCardTypes() => (select(cardTypes)
        ..where((t) => t.retired.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();

  // ---- Sezioni -------------------------------------------------------

  /// Numero di tessere (non nel cestino) per ogni sezione.
  Future<Map<String, int>> sectionCounts() async {
    final active =
        await (select(cards)..where((c) => c.deletedAt.isNull())).get();
    final counts = <String, int>{};
    for (final c in active) {
      counts[c.sectionId] = (counts[c.sectionId] ?? 0) + 1;
    }
    return counts;
  }

  Future<bool> sectionNameInUse(String name, {String? exceptId}) async {
    final n = name.trim().toLowerCase();
    final list = await visibleSections();
    return list.any((s) => s.id != exceptId && s.name.toLowerCase() == n);
  }

  /// Crea una sezione. Restituisce false se il nome è vuoto o già usato.
  Future<bool> createSection(String name) async {
    final n = name.trim();
    if (n.isEmpty || await sectionNameInUse(n)) return false;
    await into(sections).insert(SectionsCompanion.insert(name: n));
    return true;
  }

  Future<bool> renameSection(String id, String name) async {
    final n = name.trim();
    if (n.isEmpty || await sectionNameInUse(n, exceptId: id)) return false;
    await (update(sections)..where((s) => s.id.equals(id)))
        .write(SectionsCompanion(name: Value(n)));
    return true;
  }

  /// Elimina una sezione (mai quella di partenza). Le tessere si spostano in
  /// [moveTo] oppure, se è null, vanno nel cestino insieme alla sezione, che
  /// resta nascosta finché quelle tessere non sono recuperate o cancellate.
  Future<void> deleteSection(String id, {String? moveTo}) async {
    final section =
        await (select(sections)..where((s) => s.id.equals(id))).getSingle();
    if (section.isDefault) {
      throw StateError('La sezione di partenza non si elimina.');
    }
    await transaction(() async {
      final active = update(cards)
        ..where((c) => c.sectionId.equals(id) & c.deletedAt.isNull());
      if (moveTo != null) {
        await active.write(CardsCompanion(sectionId: Value(moveTo)));
      } else {
        await active.write(CardsCompanion(deletedAt: Value(DateTime.now())));
      }
      await _dropOrHideSection(id);
    });
  }

  /// Una sezione senza più tessere (nemmeno nel cestino) sparisce; se ne ha
  /// ancora nel cestino resta registrata ma nascosta.
  Future<void> _dropOrHideSection(String id) async {
    final left =
        await (select(cards)..where((c) => c.sectionId.equals(id))).get();
    if (left.isEmpty) {
      await (delete(sections)..where((s) => s.id.equals(id))).go();
    } else {
      await (update(sections)..where((s) => s.id.equals(id)))
          .write(const SectionsCompanion(hidden: Value(true)));
    }
  }

  // ---- Cestino -------------------------------------------------------

  static const trashDays = 30;

  Stream<List<Card>> watchTrash() => (select(cards)
        ..where((c) => c.deletedAt.isNotNull())
        ..orderBy([(c) => OrderingTerm.desc(c.deletedAt)]))
      .watch();

  Future<int> trashCount() async =>
      (await (select(cards)..where((c) => c.deletedAt.isNotNull())).get())
          .length;

  Future<void> moveCardToTrash(String id) =>
      (update(cards)..where((c) => c.id.equals(id)))
          .write(CardsCompanion(deletedAt: Value(DateTime.now())));

  /// Recupera una tessera dal cestino nella sezione indicata (se era nascosta
  /// la sezione torna visibile). Restituisce false se non c'è posto nel limite.
  Future<bool> recoverCard(String cardId, String sectionId) async {
    if (await activeCardCount() >= freeCardLimit) return false;
    await transaction(() async {
      await (update(sections)..where((s) => s.id.equals(sectionId)))
          .write(const SectionsCompanion(hidden: Value(false)));
      await (update(cards)..where((c) => c.id.equals(cardId))).write(
        CardsCompanion(
          sectionId: Value(sectionId),
          deletedAt: const Value<DateTime?>(null),
        ),
      );
    });
    return true;
  }

  /// Elimina definitivamente una tessera (e i riferimenti alle sue foto).
  Future<void> deleteCardForever(String id) async {
    final card =
        await (select(cards)..where((c) => c.id.equals(id))).getSingleOrNull();
    if (card == null) return;
    await transaction(() async {
      await (delete(cardImages)..where((i) => i.cardId.equals(id))).go();
      await (delete(cards)..where((c) => c.id.equals(id))).go();
      final section = await (select(sections)
            ..where((s) => s.id.equals(card.sectionId)))
          .getSingleOrNull();
      if (section != null && section.hidden) {
        await _dropOrHideSection(section.id);
      }
    });
  }

  /// Cancella le tessere nel cestino da più di 30 giorni.
  Future<void> purgeExpiredTrash(DateTime now) async {
    final limit = now.subtract(const Duration(days: trashDays));
    final old = await (select(cards)
          ..where((c) => c.deletedAt.isSmallerThanValue(limit)))
        .get();
    for (final c in old) {
      await deleteCardForever(c.id);
    }
  }

  // ---- Impostazioni e configurazione iniziale --------------------------

  static const defaultExpiryDays = 30;

  Future<String?> setting(String key) async =>
      (await (select(settings)..where((s) => s.key.equals(key)))
              .getSingleOrNull())
          ?.value;

  Future<void> setSetting(String key, String value) => into(settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  /// La configurazione iniziale (videata 1) è già stata fatta?
  Future<bool> isSetupDone() async =>
      await setting(SettingKeys.setupDone) == 'true';

  /// Salva le risposte della configurazione iniziale e dà alla sezione di
  /// partenza il nome nella lingua scelta (decisione 84).
  Future<void> completeSetup({
    required String holderName,
    required String language,
    required bool expiryAlerts,
    required int expiryDays,
  }) =>
      transaction(() async {
        await setSetting(SettingKeys.holderName, holderName.trim());
        await setSetting(SettingKeys.language, language);
        await setSetting(SettingKeys.expiryAlerts, expiryAlerts.toString());
        await setSetting(SettingKeys.expiryDays, expiryDays.toString());
        final name = defaultSectionNames[language] ?? defaultSectionName;
        await (update(sections)..where((s) => s.isDefault.equals(true)))
            .write(SectionsCompanion(name: Value(name)));
        await setSetting(SettingKeys.setupDone, 'true');
      });

  // ---- Foto della tessera ----------------------------------------------

  /// Foto della tessera per lato ('front', 'back') → nome del file.
  Future<Map<String, String>> cardPhotos(String cardId) async {
    final rows = await (select(cardImages)
          ..where((i) => i.cardId.equals(cardId)))
        .get();
    return {for (final r in rows) r.side: r.fileName};
  }

  Stream<Map<String, String>> watchCardPhotos(String cardId) =>
      (select(cardImages)..where((i) => i.cardId.equals(cardId)))
          .watch()
          .map((rows) => {for (final r in rows) r.side: r.fileName});

  /// Imposta la foto di un lato. Restituisce il nome del file sostituito
  /// (da cancellare), se c'era.
  Future<String?> setCardPhoto(String cardId, String side, String fileName) =>
      transaction(() async {
        final old = (await cardPhotos(cardId))[side];
        await into(cardImages).insertOnConflictUpdate(CardImagesCompanion.insert(
            cardId: cardId, side: side, fileName: fileName));
        return old;
      });

  /// Toglie la foto di un lato. Restituisce il nome del file da cancellare.
  Future<String?> removeCardPhoto(String cardId, String side) =>
      transaction(() async {
        final old = (await cardPhotos(cardId))[side];
        await (delete(cardImages)
              ..where((i) => i.cardId.equals(cardId) & i.side.equals(side)))
            .go();
        return old;
      });

  /// Modifica una tessera (matita nella videata 5): scrive i campi in
  /// [values] e applica le foto cambiate nel modulo, tutto in una transazione.
  /// [newPhotos]: lato → nome del file già scritto; [removedPhotos]: lati da
  /// togliere. Restituisce i nomi dei file non più usati, da cancellare.
  Future<List<String>> updateCard(
    String cardId,
    CardsCompanion values, {
    Map<String, String> newPhotos = const {},
    Set<String> removedPhotos = const {},
  }) =>
      transaction(() async {
        await (update(cards)..where((c) => c.id.equals(cardId))).write(values);
        final obsolete = <String>[];
        for (final side in removedPhotos) {
          final old = await removeCardPhoto(cardId, side);
          if (old != null) obsolete.add(old);
        }
        for (final e in newPhotos.entries) {
          final old = await setCardPhoto(cardId, e.key, e.value);
          if (old != null) obsolete.add(old);
        }
        return obsolete;
      });

  Future<Card?> cardById(String id) =>
      (select(cards)..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Sposta la tessera in un'altra sezione (videata 5, "Sposta").
  Future<void> moveCard(String cardId, String sectionId) =>
      (update(cards)..where((c) => c.id.equals(cardId)))
          .write(CardsCompanion(sectionId: Value(sectionId)));

  Future<Section> defaultSection() =>
      (select(sections)..where((s) => s.isDefault.equals(true))).getSingle();

  /// Tutte le tessere non nel cestino (l'ordinamento si fa nell'interfaccia).
  Stream<List<Card>> watchActiveCards() =>
      (select(cards)..where((c) => c.deletedAt.isNull())).watch();

  /// Tessere non nel cestino di una sezione, in ordine alfabetico.
  Stream<List<Card>> watchCards(String sectionId) {
    return (select(cards)
          ..where((c) => c.sectionId.equals(sectionId) & c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }
}
