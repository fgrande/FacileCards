# FacileCards

App Android per tenere sul telefono le tessere (fedeltà, biblioteca, palestra…) con il loro codice a barre o QR, pronte da mostrare alla cassa. Funziona tutta in locale: nessun server, nessun account, nessun cloud. La versione gratuita mostra annunci e ha un limite di 50 tessere; l'acquisto una tantum "Pro" li toglie.

Questo repository è privato e contiene tutto il progetto.

## Cosa c'è nelle cartelle

| Cartella | Contenuto | Cosa produce |
|---|---|---|
| `app/` | L'app, scritta in Flutter e Dart (codice in `lib/`, prove automatiche in `test/`, parte Android in `android/`) | L'app Android: file `.apk` per provarla, `.aab` per Google Play. Il codice generato dal database (`lib/data/database.g.dart`) è nel repository |
| `site/` | Il sito di presentazione e l'informativa sulla privacy, in italiano, inglese e francese: pagine HTML statiche, più `app-ads.txt` per AdMob | Niente da compilare: i file si pubblicano così come sono. Per ora il sito non è pubblicato |
| `docs/` | La documentazione di progetto: perché (`00-perche.md`), analisi e decisioni (`01-analisi-iniziale.md`), indice delle videate (`02-videate.md`) | Niente. Contiene anche `videate/` (45 schermate disegnate in SVG, in `scuro/` quelle del tema scuro) e `logo/` |
| `.github/workflows/` | La pipeline di GitHub | A ogni modifica di `app/` lancia l'analisi e le prove automatiche; non produce file |
| `CLAUDE.md` | Le istruzioni per chi lavora al progetto con Claude e l'elenco di ciò che resta da fare | Niente |

## Per lavorare sull'app

Serve Flutter installato (guida nella sezione 9 di `docs/01-analisi-iniziale.md`). Dalla cartella `app/`:

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # ricrea il codice del database
flutter analyze
flutter test
flutter run                                                # su emulatore o telefono collegato
```

`build_runner` va rilanciato ogni volta che si cambiano le tabelle in `lib/data/database.dart`.

## Da dove partire a leggere

1. `docs/00-perche.md`: perché esiste l'app.
2. `docs/01-analisi-iniziale.md`: requisiti, decisioni (sezione 2) e percorso (sezione 7).
3. `docs/02-videate.md`: le schermate.
4. `CLAUDE.md`: a che punto siamo e cosa manca.
