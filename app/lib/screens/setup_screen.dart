import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../l10n/l10n.dart';
import '../theme.dart';
import '../ui.dart';

/// Videata 1: configurazione iniziale, solo al primo avvio (decisione 65).
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.database, required this.onDone});

  final db.AppDatabase database;
  final VoidCallback onDone;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  static const _minDays = 1;
  static const _maxDays = 90;

  final _name = TextEditingController();
  late final String _phoneLanguage = phoneLanguage();
  late String _language = _phoneLanguage;
  bool _alerts = true;
  int _days = db.AppDatabase.defaultExpiryDays;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickLanguage() async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.t.language),
        children: [
          for (final l in supportedLanguages)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(l),
              child: Text(languageNames[l]!),
            ),
        ],
      ),
    );
    if (chosen != null && mounted) {
      setState(() => _language = chosen);
      // L'interfaccia cambia lingua subito, già in questa schermata.
      setAppLanguage(chosen);
    }
  }

  Future<void> _start() async {
    setState(() => _saving = true);
    await widget.database.completeSetup(
      holderName: _name.text,
      language: _language,
      expiryAlerts: _alerts,
      expiryDays: _days,
    );
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Scaffold(
      backgroundColor: AppColors.of(context).surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 24),
                  const Center(child: AppMark(height: 96)),
                  const SizedBox(height: 16),
                  Text(context.t.setupWelcome,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(context.t.setupIntro,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: context.t.setupNameLabel,
                      helperText: context.t.setupNameHelp,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickLanguage,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.t.language,
                        helperText: _language == _phoneLanguage
                            ? context.t.setupLanguageHelp
                            : null,
                        suffixIcon: const Icon(Icons.expand_more),
                      ),
                      child: Text(languageNames[_language]!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Panel(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(context.t.expiryAlertsTitle),
                          subtitle: Text(context.t.expiryAlertsSubtitle),
                          value: _alerts,
                          onChanged: (v) => setState(() => _alerts = v),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          enabled: _alerts,
                          title: Text(context.t.expiryDaysTitle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _alerts && _days > _minDays
                                    ? () => setState(() => _days--)
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              SizedBox(
                                width: 32,
                                child: Text('$_days',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleMedium),
                              ),
                              IconButton(
                                onPressed: _alerts && _days < _maxDays
                                    ? () => setState(() => _days++)
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(context.t.setupLater,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saving ? null : _start,
                  child: Text(context.t.setupStart),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
