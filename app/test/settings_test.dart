import 'package:drift/native.dart';
import 'package:facilecards/data/database.dart';
import 'package:facilecards/expiry.dart';
import 'package:facilecards/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;

void main() {
  test('il tema si salva come testo e si rilegge uguale', () {
    for (final m in ThemeMode.values) {
      expect(themeModeFromText(themeModeToText(m)), m);
    }
    // Mai scelto (o valore sconosciuto): come il telefono.
    expect(themeModeFromText(null), ThemeMode.system);
    expect(themeModeFromText('boh'), ThemeMode.system);
  });

  group('impostazioni nel database', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('una impostazione cambiata sostituisce la precedente', () async {
      await db.setSetting(SettingKeys.theme, 'dark');
      await db.setSetting(SettingKeys.theme, 'light');
      expect(await db.setting(SettingKeys.theme), 'light');
      expect((await db.select(db.settings).get()).length, 1);
    });

    test('cambiare l\'avviso dalle impostazioni vale per le scadenze', () async {
      await db.completeSetup(
          holderName: '', language: 'it', expiryAlerts: true, expiryDays: 30);
      await db.setSetting(SettingKeys.expiryDays, '7');
      expect((await db.expirySettings()).days, 7);
      await db.setSetting(SettingKeys.expiryAlerts, 'false');
      expect((await db.expirySettings()).enabled, isFalse);
    });
  });
}
