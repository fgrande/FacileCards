import 'package:material_ui/material_ui.dart';

import 'data/database.dart';
import 'photos.dart';
import 'screens/card_list_screen.dart';
import 'screens/setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  // Una sola lettura prima della prima schermata: se la configurazione è
  // fatta si va dritti all'elenco (regola dei 2 secondi).
  final setupDone = await database.isSetupDone();
  runApp(FacileCardsApp(database: database, setupDone: setupDone));
  // Dopo la prima schermata, senza fretta: via i file delle foto che il
  // database non conosce più (tessere cancellate, cestino svuotato).
  WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    return MaterialApp(
      title: 'FacileCards',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6FEB)),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F6FEB),
          brightness: Brightness.dark,
        ),
      ),
      home: _setupDone
          ? CardListScreen(database: widget.database)
          : SetupScreen(
              database: widget.database,
              onDone: () => setState(() => _setupDone = true),
            ),
    );
  }
}
