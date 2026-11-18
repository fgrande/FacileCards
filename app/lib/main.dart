import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;


import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'data/database.dart';
import 'l10n/l10n.dart';
import 'photos.dart';
import 'screens/card_list_screen.dart';
import 'screens/setup_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  // Poche letture prima della prima schermata (configurazione fatta, tema,
  // lingua): poi si va dritti all'elenco (regola dei 2 secondi).
  final setupDone = await database.isSetupDone();
  appThemeMode.value = themeModeFromText(
    await database.setting(SettingKeys.theme),
  );
  // Prima della configurazione: la lingua del telefono (o l'inglese).
  setAppLanguage(await database.setting(SettingKeys.language));
  await initializeDateFormatting();
  runApp(FacileCardsApp(database: database, setupDone: setupDone));
  // Dopo la prima schermata, senza fretta: si svuota il cestino delle tessere
  // più vecchie di 30 giorni, poi via i file delle foto che il database non
  // conosce più (tessere cancellate, cestino svuotato).
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await database.purgeExpiredTrash(DateTime.now());
    final store = await PhotoStore.instance;
    await store.removeOrphans(database);
  });
}

class FacileCardsApp extends StatefulWidget {
  const FacileCardsApp({
    super.key,
    required this.database,
    required this.setupDone,
  });

  final AppDatabase database;
  final bool setupDone;

  @override
  State<FacileCardsApp> createState() => _FacileCardsAppState();
}

class _FacileCardsAppState extends State<FacileCardsApp> {
  late bool _setupDone = widget.setupDone;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appThemeMode, appLocale]),
      builder: (context, _) => MaterialApp(
        title: 'FacileCards',
        locale: appLocale.value,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        themeMode: appThemeMode.value,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: _setupDone
            ? CardListScreen(database: widget.database)
            : SetupScreen(
                database: widget.database,
                onDone: () => setState(() => _setupDone = true),
              ),
      ),
    );
  }
}
