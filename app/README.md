# app

L'app FacileCards, in Flutter. Il progetto è descritto nel `README.md` e nel `CLAUDE.md` della cartella principale.

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

- `lib/main.dart`: avvio dell'app e temi
- `lib/data/`: database (Drift) e catalogo delle tipologie; `database.g.dart` è generato da `build_runner`
- `lib/screens/`: le schermate
- `lib/barcode_support.dart`, `lib/format_utils.dart`: formati dei codici e testi delle date
- `test/`: prove automatiche
- `android/`: parte Android (identificativo `eu.facilecards.app`, minSdk 24)
