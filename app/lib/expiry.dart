import 'data/database.dart';

/// Avviso delle scadenze come impostato nella configurazione (decisione 66).
class ExpirySettings {
  const ExpirySettings({required this.enabled, required this.days});

  /// Valori predefiniti (decisione 65): attivo, 30 giorni.
  static const defaults =
      ExpirySettings(enabled: true, days: AppDatabase.defaultExpiryDays);

  final bool enabled;
  final int days;
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Giorni che mancano alla scadenza: 0 oggi, negativo se già scaduta.
int daysUntil(DateTime expiresOn, DateTime now) =>
    _day(expiresOn).difference(_day(now)).inDays;

/// La tessera va segnalata: scaduta o entro i giorni di preavviso.
bool isFlagged(DateTime? expiresOn, DateTime now, ExpirySettings s) =>
    s.enabled && expiresOn != null && daysUntil(expiresOn, now) <= s.days;

/// Tessere da segnalare sotto la campanella (videata 4), esclusa quella nel
/// cestino: prima le scadute, poi le altre, in ordine di data.
List<Card> cardsToFlag(Iterable<Card> cards, DateTime now, ExpirySettings s) =>
    cards
        .where((c) => c.deletedAt == null && isFlagged(c.expiresOn, now, s))
        .toList()
      ..sort((a, b) => a.expiresOn!.compareTo(b.expiresOn!));

extension ExpirySettingsRead on AppDatabase {
  Future<ExpirySettings> expirySettings() async {
    final enabled = await setting(SettingKeys.expiryAlerts);
    final days = int.tryParse(await setting(SettingKeys.expiryDays) ?? '');
    return ExpirySettings(
      enabled: enabled == null ? ExpirySettings.defaults.enabled : enabled == 'true',
      days: days ?? ExpirySettings.defaults.days,
    );
  }
}
