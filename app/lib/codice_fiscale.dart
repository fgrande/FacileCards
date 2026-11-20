// Controllo del codice fiscale italiano: 16 caratteri, l'ultimo è una
// lettera di controllo calcolata dai primi 15. Serve a scartare le letture
// storte del codice a barre (Code 39) della tessera sanitaria.

/// Valori dei caratteri in posizione dispari (1ª, 3ª, ... contando da 1),
/// in ordine da A a Z e scritti come lettere (A=0, B=1, ...). Le cifre
/// valgono come la lettera corrispondente (0 come A, 1 come B, ...).
const _odd = 'BAFHJNPRTVCESULDGIMOQKWZYX';

int _index(int c) => c >= 0x41 ? c - 0x41 : c - 0x30; // A=0 ... Z=25, 0=0 ...

/// Vero se [value] è un codice fiscale con il carattere di controllo giusto
/// (vale anche per i codici con omocodia, dove alcune cifre sono lettere).
bool isValidCodiceFiscale(String value) {
  final cf = value.trim().toUpperCase();
  if (!RegExp(r'^[A-Z0-9]{15}[A-Z]$').hasMatch(cf)) return false;
  var sum = 0;
  for (var i = 0; i < 15; i++) {
    final v = _index(cf.codeUnitAt(i));
    // Posizioni dispari (contando da 1): tabella; pari: il valore stesso.
    sum += i.isEven ? _odd.codeUnitAt(v) - 0x41 : v;
  }
  return cf.codeUnitAt(15) == 0x41 + sum % 26;
}
