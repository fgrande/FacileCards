// Ordine alfabetico come lo intende una persona: senza distinguere
// maiuscole e minuscole né lettere accentate.
//
// L'ordinamento di SQLite confronta i caratteri uno per uno, quindi "ACI"
// finiva prima di "Abbonamento Musei" (la C maiuscola viene prima della b
// minuscola) e una lettera accentata dopo la z.

const _accents = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', //
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', //
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', //
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', //
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', //
  'ç': 'c', 'ñ': 'n', 'ÿ': 'y', 'œ': 'oe', 'æ': 'ae', 'ß': 'ss',
};

/// Chiave di ordinamento di un nome: minuscole, senza accenti.
String sortKey(String name) {
  final lower = name.toLowerCase();
  final out = StringBuffer();
  for (final ch in lower.split('')) {
    out.write(_accents[ch] ?? ch);
  }
  return out.toString();
}

/// Confronta due nomi in ordine alfabetico (a parità, l'ordine esatto, così
/// il risultato non cambia da una volta all'altra).
int compareNames(String a, String b) {
  final c = sortKey(a).compareTo(sortKey(b));
  return c != 0 ? c : a.compareTo(b);
}
