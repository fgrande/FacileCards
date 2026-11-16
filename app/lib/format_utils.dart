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

/// Avviso di scadenza, solo se la tessera scade entro 30 giorni (o è scaduta).
String? expiryLabel(DateTime? expiresOn, DateTime now) {
  if (expiresOn == null) return null;
  final days = _day(expiresOn).difference(_day(now)).inDays;
  if (days < 0) return 'Scaduta';
  if (days == 0) return 'Scade oggi';
  if (days == 1) return 'Scade domani';
  if (days <= 30) return 'Scade tra $days giorni';
  return null;
}

const _months = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', 'luglio',
  'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
];

/// "31 dicembre 2027"
String longDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
