import 'package:material_ui/material_ui.dart';

import 'data/database.dart';
import 'photos.dart';
import 'screens/card_list_screen.dart';
import 'screens/setup_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  // Due letture prima della prima schermata (configurazione fatta, tema):
  // poi si va dritti all'elenco (regola dei 2 secondi).
  final setupDone = await database.isSetupDone();
  appThemeMode.value = themeModeFromText(
    await database.setting(SettingKeys.theme),
  );
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'FacileCards',
        themeMode: mode,
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
