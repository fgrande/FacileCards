import 'package:material_ui/material_ui.dart';

import '../ads.dart';
import '../data/database.dart' as db;
import '../expiry.dart';
import '../l10n/l10n.dart';
import '../links.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../ui.dart';
import 'about_screen.dart';
import 'language_picker.dart';
import 'pay_app_screen.dart';

/// Videata 14: impostazioni. Gli stessi valori della configurazione iniziale,
/// più tema, versione e collegamenti.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.database});

  final db.AppDatabase database;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _name = '';
  String _language = 'it';
  ExpirySettings _expiry = ExpirySettings.defaults;
  int _count = 0;
  PayApp? _payApp;

  db.AppDatabase get _db => widget.database;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await _db.setting(db.SettingKeys.holderName);
    final language = await _db.setting(db.SettingKeys.language);
    final expiry = await _db.expirySettings();
    final count = await _db.activeCardCount();
    final payPackage = await _db.setting(db.SettingKeys.payApp) ?? '';
    final payApp = payPackage.isEmpty ? null : await payAppInfo(payPackage);
    if (!mounted) return;
    setState(() {
      _payApp = payApp;
      _name = name ?? '';
      _language = language ?? 'it';
      _expiry = expiry;
      _count = count;
    });
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _editName() async {
    final controller = TextEditingController(text: _name);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.yourName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: context.t.optional,
            helperText: context.t.setupNameHelp,
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(context.t.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await _db.setSetting(db.SettingKeys.holderName, value.trim());
    setState(() => _name = value.trim());
  }

  /// Sceglie fra alcune voci; restituisce quella toccata.
  Future<T?> _choose<T>(String title, Map<T, String> options, T current) =>
      showDialog<T>(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text(title),
          children: [
            for (final e in options.entries)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(e.key),
                child: Row(
                  children: [
                    Icon(
                      e.key == current
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: e.key == current
                          ? AppColors.of(context).primary
                          : AppColors.of(context).muted,
                    ),
                    const SizedBox(width: 12),
                    Text(e.value, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
          ],
        ),
      );

  Future<void> _chooseLanguage() async {
    final chosen = await showLanguagePicker(context, _language);
    if (chosen == null || chosen == _language) return;
    await _db.setSetting(db.SettingKeys.language, chosen);
    setState(() => _language = chosen);
    setAppLanguage(chosen); // l'app cambia subito
  }

  /// Videata 46 (decisione 118).
  Future<void> _choosePayApp() async {
    final chosen = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => PayAppScreen(current: _payApp?.package ?? ''),
      ),
    );
    if (chosen == null) return;
    await _db.setSetting(db.SettingKeys.payApp, chosen);
    final app = chosen.isEmpty ? null : await payAppInfo(chosen);
    if (mounted) setState(() => _payApp = app);
  }

  Future<void> _chooseTheme() async {
    final current = appThemeMode.value;
    final chosen = await _choose(context.t.theme, {
      for (final m in [ThemeMode.system, ThemeMode.light, ThemeMode.dark])
        m: themeModeLabel(m),
    }, current);
    if (chosen == null || chosen == current) return;
    await _db.setSetting(db.SettingKeys.theme, themeModeToText(chosen));
    appThemeMode.value = chosen; // l'app cambia subito
    setState(() {});
  }

  Future<void> _setExpiry({bool? enabled, int? days}) async {
    final next = ExpirySettings(
      enabled: enabled ?? _expiry.enabled,
      days: days ?? _expiry.days,
    );
    await _db.setSetting(db.SettingKeys.expiryAlerts, next.enabled.toString());
    await _db.setSetting(db.SettingKeys.expiryDays, next.days.toString());
    setState(() => _expiry = next);
  }

  Future<void> _chooseDays() async {
    final days = await showDialog<int>(
      context: context,
      builder: (_) => _DaysDialog(initial: _expiry.days),
    );
    if (days != null) await _setExpiry(days: days);
  }

  Future<void> _open(String url) async {
    if (!await openUrl(url)) _message(tr.noAppToOpen(url));
  }

  Widget _row({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle),
    trailing: trailing ?? (onTap == null ? null : const Chevron()),
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.t.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          GroupHeader(context.t.settingsPersonal),
          TileGroup(
            indent: 16,
            children: [
              _row(
                title: context.t.yourName,
                subtitle: _name.isEmpty ? context.t.nameNotSet : _name,
                onTap: _editName,
              ),
              _row(
                title: context.t.language,
                subtitle: languageLabel(_language),
                onTap: _chooseLanguage,
              ),
              _row(
                title: context.t.theme,
                subtitle: themeModeLabel(appThemeMode.value),
                onTap: _chooseTheme,
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                title: Text(context.t.payApp),
                subtitle: Row(
                  children: [
                    if (_payApp != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          _payApp!.icon,
                          width: 16,
                          height: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        _payApp == null
                            ? context.t.payAppNone
                            : context.t.payAppSettingsSub(_payApp!.label),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                trailing: const Chevron(),
                onTap: _choosePayApp,
              ),
              _row(
                title: context.t.expiryAlerts,
                subtitle: _expiry.enabled
                    ? context.t.expiryAlertsOn(_expiry.days)
                    : context.t.off,
                onTap: _expiry.enabled ? _chooseDays : null,
                trailing: Switch(
                  value: _expiry.enabled,
                  onChanged: (v) => _setExpiry(enabled: v),
                ),
              ),
            ],
          ),
          GroupHeader(context.t.settingsVersion),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: c.infoBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t.freeVersion,
                    style: TextStyle(
                      color: c.infoText,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.t.freeVersionCount(
                      _count,
                      db.AppDatabase.freeCardLimit,
                    ),
                    style: TextStyle(color: c.infoText, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => _message(context.t.purchaseComing),
                        child: Text(context.t.upgradePro),
                      ),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: c.infoText,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: () => _message(context.t.purchaseComing),
                        child: Text(context.t.restorePurchase),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GroupHeader(context.t.settingsOther),
          TileGroup(
            indent: 16,
            children: [
              if (contactEmail != null)
                _row(
                  title: context.t.requestMissingCard,
                  onTap: () => _open(
                    'mailto:$contactEmail?subject=${Uri.encodeComponent(context.t.missingCardSubject)}',
                  ),
                ),
              _row(
                title: context.t.manageAdConsent,
                onTap: () async {
                  if (!await Ads.instance.showPrivacyOptions()) {
                    _message(tr.adConsentNotRequired);
                  }
                },
              ),
              _row(
                title: context.t.privacyPolicy,
                onTap: () => _open(privacyUrl),
              ),
              _row(
                title: context.t.aboutApp,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Giorni di preavviso, da 1 a 90.
class _DaysDialog extends StatefulWidget {
  const _DaysDialog({required this.initial});

  final int initial;

  @override
  State<_DaysDialog> createState() => _DaysDialogState();
}

class _DaysDialogState extends State<_DaysDialog> {
  late int _days = widget.initial;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t.expiryDaysTitle),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.outlined(
            onPressed: _days > 1 ? () => setState(() => _days--) : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$_days',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          IconButton.outlined(
            onPressed: _days < 90 ? () => setState(() => _days++) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_days),
          child: Text(context.t.save),
        ),
      ],
    );
  }
}
