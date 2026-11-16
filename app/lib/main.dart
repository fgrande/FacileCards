import 'package:material_ui/material_ui.dart';

import 'data/database.dart';
import 'screens/card_list_screen.dart';

void main() {
  runApp(FacileCardsApp(database: AppDatabase()));
}

class FacileCardsApp extends StatelessWidget {
  const FacileCardsApp({super.key, required this.database});

  final AppDatabase database;

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
      home: CardListScreen(database: database),
    );
  }
}
