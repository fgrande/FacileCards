import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../expiry.dart';
import '../links.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../ui.dart';
import 'about_screen.dart';
import 'setup_screen.dart' show languageNames;

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
    if (!mounted) return;
    setState(() {
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
        title: const Text('Il tuo nome'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Facoltativo',
            helperText: 'Lo proponiamo come intestatario delle nuove tessere.',
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Salva'),
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
    final chosen = await _choose('Lingua', {
      for (final l in db.supportedLanguages) l: languageNames[l]!,
    }, _language);
    if (chosen == null || chosen == _language) return;
    await _db.setSetting(db.SettingKeys.language, chosen);
    setState(() => _language = chosen);
    _message('Le traduzioni arriveranno presto: per ora l\'app è in italiano.');
  }

  Future<void> _chooseTheme() async {
    final current = appThemeMode.value;
    final chosen = await _choose('Tema', {
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
    if (!await openUrl(url)) _message('Non c\'è un\'app per aprire $url');
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
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const GroupHeader('Personali'),
          TileGroup(
            indent: 16,
            children: [
              _row(
                title: 'Il tuo nome',
                subtitle: _name.isEmpty ? 'Non indicato' : _name,
                onTap: _editName,
              ),
              _row(
                title: 'Lingua',
                subtitle: languageNames[_language] ?? _language,
                onTap: _chooseLanguage,
              ),
              _row(
                title: 'Tema',
                subtitle: themeModeLabel(appThemeMode.value),
                onTap: _chooseTheme,
              ),
              _row(
                title: 'Avviso scadenze',
                subtitle: _expiry.enabled
                    ? '${_expiry.days} giorni prima · tocca per cambiare'
                    : 'Spento',
                onTap: _expiry.enabled ? _chooseDays : null,
                trailing: Switch(
                  value: _expiry.enabled,
                  onChanged: (v) => _setExpiry(enabled: v),
                ),
              ),
            ],
          ),
          const GroupHeader('Versione'),
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
                    'Versione gratuita',
                    style: TextStyle(
                      color: c.infoText,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_count di ${db.AppDatabase.freeCardLimit} tessere · con annunci',
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
                        onPressed: () => _message(
                          'L\'acquisto arriverà con la pubblicazione su Google Play.',
                        ),
                        child: const Text('Passa a Pro · 2,00 €  →'),
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
                        onPressed: () => _message(
                          'L\'acquisto arriverà con la pubblicazione su Google Play.',
                        ),
                        child: const Text('Ripristina acquisto'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const GroupHeader('Altro'),
          TileGroup(
            indent: 16,
            children: [
              if (contactEmail != null)
                _row(
                  title: 'Richiedi una tessera mancante',
                  onTap: () => _open(
                    'mailto:$contactEmail?subject=Tessera mancante in FacileCards',
                  ),
                ),
              _row(
                title: 'Informativa sulla privacy',
                onTap: () => _open(privacyUrl),
              ),
              _row(
                title: 'Informazioni su FacileCards',
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
      title: const Text('Giorni di preavviso'),
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
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_days),
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
