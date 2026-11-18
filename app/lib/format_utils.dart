// Testi di data per l'interfaccia (italiano; le altre lingue arriveranno
// con la traduzione dell'app).

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// "usata oggi", "usata ieri", "3 giorni fa", "una settimana fa"...
String usedLabel(DateTime? last, DateTime now) {
  if (last == null) return 'mai usata';
  final days = _day(now).difference(_day(last)).inDays;
  if (days <= 0) return 'usata oggi';
  if (days == 1) return 'usata ieri';
  if (days < 7) return '$days giorni fa';
  if (days < 14) return 'una settimana fa';
  if (days < 30) return '${days ~/ 7} settimane fa';
  if (days < 60) return 'un mese fa';
  return '${days ~/ 30} mesi fa';
}

/// "Eliminata oggi", "Eliminata ieri", "Eliminata 3 giorni fa"
String deletedLabel(DateTime deletedAt, DateTime now) {
  final days = _day(now).difference(_day(deletedAt)).inDays;
  if (days <= 0) return 'Eliminata oggi';
  if (days == 1) return 'Eliminata ieri';
  return 'Eliminata $days giorni fa';
}

/// Avviso di scadenza nella riga dell'elenco, solo se la tessera scade entro
/// [days] giorni (o è scaduta).
String? expiryLabel(DateTime? expiresOn, DateTime now, {required int days}) {
  if (expiresOn == null) return null;
  final left = _day(expiresOn).difference(_day(now)).inDays;
  if (left < 0) return 'Scaduta';
  if (left == 0) return 'Scade oggi';
  if (left == 1) return 'Scade domani';
  if (left <= days) return 'Scade tra $left giorni';
  return null;
}

/// Etichetta breve nel riquadro delle scadenze: "Scaduta", "Oggi",
/// "Domani", "Tra 12 giorni".
String expiryBadge(DateTime expiresOn, DateTime now) {
  final left = _day(expiresOn).difference(_day(now)).inDays;
  if (left < 0) return 'Scaduta';
  if (left == 0) return 'Oggi';
  if (left == 1) return 'Domani';
  return 'Tra $left giorni';
}

/// "Scaduta il 31 ottobre 2026" / "Scade il 28 novembre 2026"
String expiryDetail(DateTime expiresOn, DateTime now) =>
    _day(expiresOn).isBefore(_day(now))
        ? 'Scaduta il ${longDate(expiresOn)}'
        : 'Scade il ${longDate(expiresOn)}';

const _months = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', 'luglio',
  'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
];

/// "31 dicembre 2027"
String longDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "31/12/2027", per i campi stretti (scadenza nella nuova tessera).
String shortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
