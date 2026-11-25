import 'package:drift/drift.dart';

import '../l10n/l10n.dart';
import 'database.dart';

/// Catalogo iniziale delle tipologie. L'identificativo è stabile: serve a
/// riconoscere la tipologia anche dopo un'esportazione o una migrazione.
///
/// Dopo la pubblicazione una tipologia non si toglie mai: si segna come non
/// più valida (decisioni 73 e 83). Togliere è ammesso solo durante lo
/// sviluppo: la toglie da "Nuova tessera", e dal database sparisce quando
/// nessuna tessera la usa più (vedi syncCatalog). Tolte finora: Carrefour
/// (20 nov 2026).
///
/// Il formato del codice si indica solo dopo averlo verificato su una
/// tessera vera (punto B1 dell'analisi): con il formato, la scansione avvisa
/// se il codice letto è di un altro tipo (decisione 82); senza, si accetta
/// qualunque formato. I formati indicati sono stati verificati il 20 nov
/// 2026 su tessere vere o sulle loro app (foto e screenshot di Fabio); le
/// tipologie senza formato sono da verificare con una scansione. Il logo è
/// fatto dalle iniziali su colore (decisione presa).
///
/// category: 'fedelta' = negozio con nome fisso; 'pubblica' = tessera di un
/// ente pubblico, con nome fisso ma tra le "Altre tessere"; le altre
/// ('biblioteca', 'palestra', 'altro') lasciano scegliere il nome all'utente.
List<CardTypesCompanion> catalogTypes() => [
  _t('abbonamento-musei', 'Abbonamento Musei', 0xFF00A19A, format: 'qrCode'),
  _t('aci', 'ACI', 0xFF0A3D91, format: 'code128'),
  _t('acqua-e-sapone', 'Acqua & Sapone', 0xFF1B4A9C, format: 'ean13'),
  // Giallo del marchio, scurito come Tigros (scritte bianche); formato da
  // confermare.
  _t('arcaplanet', 'Arcaplanet', 0xFFE0AB00),
  _t('baldinini', 'Baldinini', 0xFF1A1A1A, format: 'code128'),
  _t('basko', 'Basko', 0xFFC62828, format: 'ean13'),
  _t('bennet', 'Bennet', 0xFF2B3594, format: 'ean13'),
  // Verde del marchio; formato da confermare con la scansione.
  _t('bottega-verde', 'Bottega Verde', 0xFF4E7A4A),
  _t('briko', 'Brikò', 0xFFD7141A, format: 'ean13'),
  _t('calliope', 'Calliope', 0xFF1A1A1A, format: 'qrCode'),
  // Action Card del gruppo Cisalfa (vale anche da Longoni, Germani, ...).
  // Baby Card: tessera bianca con l'ovale blu del logo, da cui il colore;
  // formato da confermare con la scansione.
  // Cyao Card: la stessa tessera vale da Carpisa e da Yamamay; tre voci
  // perché si trovi cercando uno qualsiasi dei nomi.
  _t('carpisa', 'Carpisa', 0xFFB5BD00, format: 'ean13'),
  _t('chicco', 'Chicco', 0xFF1E3F95),
  _t('cisalfa', 'Cisalfa Sport', 0xFFF26522, format: 'ean13'),
  _t('conad', 'Conad', 0xFFE30613, format: 'ean13'),
  _t('crai', 'Crai', 0xFFE2001A, format: 'ean13'),
  _t('cyao-card', 'Cyao Card', 0xFF1A1A1A, format: 'ean13'),
  _t('decathlon', 'Decathlon', 0xFF3643BA, format: 'ean13'),
  // Tessera nell'app di Dispensa Emilia: QR mostrato in cassa.
  // Nero del logo; formato da confermare con la scansione.
  _t('desigual', 'Desigual', 0xFF1A1A1A),
  _t('dispensa-emilia', 'Dispensa Emilia', 0xFF7A2E21, format: 'qrCode'),
  // Famila (gruppo Selex): formato da verificare.
  // Verde acqua della tessera, più scuro perché le scritte bianche si
  // leggano (l'originale è chiaro, con il logo nero); formato da confermare.
  _t('douglas', 'Douglas', 0xFF3E9E92),
  // Giallo scuro come Tigros (scritte bianche); formato da confermare.
  _t('esselunga', 'Esselunga', 0xFFE6A300),
  // Blu del marchio; formato da confermare con la scansione.
  _t('eurospin', 'Eurospin', 0xFF1F4FB4),
  _t('famila', 'Famila', 0xFFF07D00),
  _t('feltrinelli', 'Feltrinelli', 0xFFE2001A),
  _t('gamestop', 'GameStop', 0xFFD71920, format: 'code128'),
  _t('guess', 'Guess', 0xFF1A1A1A, format: 'code128'),
  _t('idexe', 'Idexè', 0xFF5F86C9, format: 'ean13'),
  _t('il-gigante', 'Il Gigante', 0xFF1B3F94, format: 'ean13'),
  _t('intrend', 'Intrend', 0xFFB8920A, format: 'ean13'),
  // Tessera socio Coop (cooperative regionali, per esempio Novacoop).
  _t('ipercoop', 'Ipercoop', 0xFFE2001A, format: 'ean13'),
  _t('ipersoap', 'IperSoap', 0xFF1FA824, format: 'ean13'),
  // Verde della Card Club; formato da confermare con la scansione.
  _t('isola-dei-tesori', 'Isola dei Tesori', 0xFF4A9E33),
  _t('kiabi', 'Kiabi', 0xFF0A3CA0, format: 'ean13'),
  // Rosso delle immagini del marchio; formato da confermare con la scansione.
  _t('kiko', 'Kiko', 0xFFC8102E),
  _t('king-sport', 'King Sport & Style', 0xFF262626, format: 'ean13'),
  // Carta MondoPiada, nell'app de La Piadineria.
  _t('la-piadineria', 'La Piadineria', 0xFFB5121B, format: 'code128'),
  _t('lego', 'Lego', 0xFFE3000B, format: 'code128'),
  _t('leroy-merlin', 'Leroy Merlin', 0xFF78BE20, format: 'code128'),
  // Carta Lidl Plus, nell'app di Lidl: QR mostrato in cassa.
  _t('lidl', 'Lidl', 0xFF0050AA, format: 'qrCode'),
  _t('lovable', 'Lovable', 0xFF7B2D26, format: 'ean13'),
  _t('maison-et-cadeaux', 'Maison et Cadeaux', 0xFF2E7D32, format: 'ean13'),
  _t('marionnaud', 'Marionnaud', 0xFF9A6CD6, format: 'ean13'),
  _t('mediaworld', 'MediaWorld', 0xFFDF0000, format: 'ean13'),
  _t('mercato', 'Mercatò', 0xFF1E4FA3, format: 'ean13'),
  // OVS: codice ITF (il lettore lo chiama itf14; valgono tutte le
  // varianti ITF, vedi barcode_support.dart).
  _t('ovs', 'OVS', 0xFF1F2A5C, format: 'itf14'),
  _t('pam', 'Pam', 0xFF0A8F3C, format: 'ean13'),
  _t('panfe', 'Panfé', 0xFF8A6D1F, format: 'code128'),
  // Carta fedeltà multipartner (vale in più catene).
  _t('payback', 'Payback', 0xFF0046AA, format: 'ean13'),
  _t('penny', 'Penny', 0xFFE2231A, format: 'ean13'),
  // PittaRosso (ex Pittarello): formato da confermare con la scansione.
  _t('pittarosso', 'PittaRosso', 0xFFE30613),
  _t('prealpina', 'Prealpina', 0xFF2F5BD8, format: 'ean13'),
  _t('prenatal', 'Prénatal', 0xFFE5007E, format: 'ean13'),
  // Blu del marchio; formato da confermare con la scansione.
  _t('risparmio-casa', 'RisparmioCasa', 0xFF1F4E9E),
  _t('sapore-di-mare', 'Sapore di Mare', 0xFF1450B4, format: 'ean13'),
  _t('scarpe-e-scarpe', 'Scarpe & Scarpe', 0xFFD52B1E, format: 'ean13'),
  _t('seconda-strada', 'Seconda Strada', 0xFF0D3B9E, format: 'code128'),
  // Nero del marchio (sito e logo in bianco e nero); formato da confermare.
  _t('sephora', 'Sephora', 0xFF1A1A1A),
  // Club Sigma: blu della tessera; formato da confermare con la scansione.
  _t('sigma', 'Sigma', 0xFF1E3F95),
  _t('sisley', 'Sisley', 0xFF222222, format: 'ean13'),
  _t('terranova', 'Terranova', 0xFF1A1A1A, format: 'qrCode'),
  // Turchese della tessera (la tonalità più scura, per le scritte bianche);
  // formato da confermare con la scansione.
  _t('tigota', 'Tigotà', 0xFF1B9AA6),
  // Giallo scuro: sul logo e sulla scheda le scritte sono bianche.
  _t('tigros', 'Tigros', 0xFFE0A100, format: 'ean13'),
  _t('trony', 'Trony', 0xFF1C2A5A, format: 'ean13'),
  // UCI Cinemas: codice EAN-8.
  _t('uci', 'UCI Cinemas', 0xFF1E4DA1, format: 'ean8'),
  // Carta multipartner UniClub: il codice è l'EAN-13 in basso (il QR sulla
  // carta serve solo a scaricare la loro app).
  _t('uniclub', 'UniClub', 0xFF2B4C9B, format: 'ean13'),
  _t('unieuro', 'Unieuro', 0xFFF26522, format: 'ean13'),
  _t('yamamay', 'Yamamay', 0xFFD6213A, format: 'ean13'),
  // Codice fiscale sul retro della tessera sanitaria (TEAM): Code 39.
  _t(
    'codice-fiscale',
    'Codice Fiscale',
    0xFF1D5FA8,
    category: 'pubblica',
    format: 'code39',
  ),
  // Codice della lotteria degli scontrini (Agenzia delle Dogane): non è un
  // negozio, sta tra le "Altre tessere" ma con il nome già scritto.
  _t(
    'lotteria-scontrini',
    'Lotteria degli Scontrini',
    0xFF0B5CB5,
    category: 'pubblica',
    format: 'code128',
  ),
  _t('biblioteca', 'Biblioteca', 0xFF546E7A, category: 'biblioteca'),
  _t('palestra', 'Palestra', 0xFF00838F, category: 'palestra'),
  _t(
    'generic',
    'Tessera generica',
    0xFF78909C,
    category: 'altro',
    generic: true,
  ),
];

CardTypesCompanion _t(
  String id,
  String name,
  int color, {
  String category = 'fedelta',
  bool generic = false,
  String? format,
}) => CardTypesCompanion.insert(
  id: id,
  name: name,
  color: Value(color),
  codeFormat: Value(format),
  category: Value(category),
  isGeneric: Value(generic),
);

/// Le tipologie a nome fisso (negozi) precompilano il nome della tessera.
bool hasFixedName(CardType t) =>
    t.category == 'fedelta' || t.category == 'pubblica';

/// Negozi: il primo gruppo di "Nuova tessera" (videata 7).
bool isShop(CardType t) => t.category == 'fedelta';

/// Nome della tipologia da mostrare: i negozi sono marchi e non si
/// traducono; le tipologie generiche sì.
String typeName(CardType t) => switch (t.id) {
  'biblioteca' => tr.typeLibrary,
  'palestra' => tr.typeGym,
  'generic' => tr.typeGeneric,
  _ => t.name,
};

/// Che tessera è, come si mostra nell'elenco per sezione (videata 3).
String categoryLabel(CardType? t) => switch (t?.category) {
  'fedelta' => tr.categoryLoyalty,
  'biblioteca' => tr.typeLibrary,
  'palestra' => tr.typeGym,
  _ => tr.categoryOther,
};

/// Impronta del catalogo: cambia se cambia qualunque campo di qualunque
/// tipologia. Serve a riallineare il database solo quando serve.
String catalogSignature(List<CardTypesCompanion> types) {
  final text = types
      .map(
        (t) => t
            .toColumns(false)
            .entries
            .map((e) => '${e.key}=${(e.value as Variable).value}')
            .join(';'),
      )
      .join('|');
  // FNV-1a a 32 bit: basta per accorgersi di una modifica.
  var hash = 0x811c9dc5;
  for (final unit in text.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  return '${types.length}-${hash.toRadixString(16)}';
}
