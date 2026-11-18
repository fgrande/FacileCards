// Testi di data per l'interfaccia, nella lingua dell'app.

import 'package:intl/intl.dart';

import 'l10n/l10n.dart';

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// "usata oggi", "usata ieri", "3 giorni fa", "una settimana fa"...
String usedLabel(DateTime? last, DateTime now) {
  if (last == null) return tr.usedNever;
  final days = _day(now).difference(_day(last)).inDays;
  if (days <= 0) return tr.usedToday;
  if (days == 1) return tr.usedYesterday;
  if (days < 7) return tr.daysAgo(days);
  if (days < 14) return tr.aWeekAgo;
  if (days < 30) return tr.weeksAgo(days ~/ 7);
  if (days < 60) return tr.aMonthAgo;
  return tr.monthsAgo(days ~/ 30);
}

/// "Eliminata oggi", "Eliminata ieri", "Eliminata 3 giorni fa"
String deletedLabel(DateTime deletedAt, DateTime now) {
  final days = _day(now).difference(_day(deletedAt)).inDays;
  if (days <= 0) return tr.deletedToday;
  if (days == 1) return tr.deletedYesterday;
  return tr.deletedDaysAgo(days);
}

/// Avviso di scadenza nella riga dell'elenco, solo se la tessera scade entro
/// [days] giorni (o è scaduta).
String? expiryLabel(DateTime? expiresOn, DateTime now, {required int days}) {
  if (expiresOn == null) return null;
  final left = _day(expiresOn).difference(_day(now)).inDays;
  if (left < 0) return tr.expired;
  if (left == 0) return tr.expiresToday;
  if (left == 1) return tr.expiresTomorrow;
  if (left <= days) return tr.expiresInDays(left);
  return null;
}

/// Etichetta breve nel riquadro delle scadenze: "Scaduta", "Oggi",
/// "Domani", "Tra 12 giorni".
String expiryBadge(DateTime expiresOn, DateTime now) {
  final left = _day(expiresOn).difference(_day(now)).inDays;
  if (left < 0) return tr.expired;
  if (left == 0) return tr.badgeToday;
  if (left == 1) return tr.badgeTomorrow;
  return tr.badgeInDays(left);
}

/// "Scaduta il 31 ottobre 2026" / "Scade il 28 novembre 2026"
String expiryDetail(DateTime expiresOn, DateTime now) =>
    _day(expiresOn).isBefore(_day(now))
    ? tr.expiredOn(longDate(expiresOn))
    : tr.expiresOn(longDate(expiresOn));

/// "31 dicembre 2027" (in inglese "31 December 2027").
String longDate(DateTime d) => DateFormat.yMMMMd(dateLocale).format(d);

/// "31/12/2027", per i campi stretti (scadenza nella nuova tessera).
String shortDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
