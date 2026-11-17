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
      _t('acqua-e-sapone', 'Acqua & Sapone', 0xFF00897B),
      _t('basko', 'Basko', 0xFFC62828),
      _t('calliope', 'Calliope', 0xFFF4511E),
      _t('carrefour', 'Carrefour', 0xFF1D4E9E),
      _t('decathlon', 'Decathlon', 0xFF0B74C4),
      _t('kiabi', 'Kiabi', 0xFF6A3FB5),
      _t('biblioteca', 'Biblioteca', 0xFF546E7A, category: 'biblioteca'),
      _t('palestra', 'Palestra', 0xFF00838F, category: 'palestra'),
      _t('generic', 'Tessera generica', 0xFF78909C,
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

/// Che tessera è, come si mostra nell'elenco per sezione (videata 3).
String categoryLabel(CardType? t) => switch (t?.category) {
      'fedelta' => 'Tessera fedeltà',
      'biblioteca' => 'Biblioteca',
      'palestra' => 'Palestra',
      _ => 'Tessera',
    };
