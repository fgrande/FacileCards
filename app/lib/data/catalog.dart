import 'package:drift/drift.dart';

import 'database.dart';

/// Catalogo iniziale delle tipologie. L'identificativo è stabile: serve a
/// riconoscere la tipologia anche dopo un'esportazione o una migrazione.
///
/// Il formato del codice è lasciato vuoto finché non si verificano le
/// tessere vere (punto B1 dell'analisi): senza formato si accetta qualunque
/// formato. Il logo è fatto dalle iniziali su colore (decisione presa).
///
/// category: 'fedelta' = negozio con nome fisso; le altre ('biblioteca',
/// 'palestra', 'altro') lasciano scegliere il nome all'utente.
List<CardTypesCompanion> catalogTypes() => [
      _t('acqua-e-sapone', 'Acqua & Sapone', 0xFF1E88E5),
      _t('basko', 'Basko', 0xFFE53935),
      _t('calliope', 'Calliope', 0xFF8E24AA),
      _t('carrefour', 'Carrefour', 0xFF1565C0),
      _t('decathlon', 'Decathlon', 0xFF0082C3),
      _t('kiabi', 'Kiabi', 0xFF43A047),
      _t('biblioteca', 'Biblioteca', 0xFF6D4C41, category: 'biblioteca'),
      _t('palestra', 'Palestra', 0xFFEF6C00, category: 'palestra'),
      _t('generic', 'Tessera generica', 0xFF546E7A,
          category: 'altro', generic: true),
    ];

CardTypesCompanion _t(
  String id,
  String name,
  int color, {
  String category = 'fedelta',
  bool generic = false,
}) =>
    CardTypesCompanion.insert(
      id: id,
      name: name,
      color: Value(color),
      category: Value(category),
      isGeneric: Value(generic),
    );

/// Le tipologie a nome fisso (negozi) precompilano il nome della tessera.
bool hasFixedName(CardType t) => t.category == 'fedelta';
