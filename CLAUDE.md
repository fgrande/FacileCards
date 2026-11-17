# FacileCards: istruzioni di lavoro e da fare

App Android in Flutter per tessere con codice a barre/QR. Tutto locale, senza server né account. Versione gratuita con annunci (AdMob) e limite di 50 tessere; acquisto una tantum "Pro" (2 €) che li toglie. Repository unico e privato: `app/` (Flutter), `site/` (sito), `docs/` (documenti). Vedi `README.md` per le cartelle.

## Regole di lavoro

- **Lingua.** Documenti, commenti e testi dell'interfaccia in italiano. Nell'app l'interfaccia sarà in italiano, inglese e francese (spagnolo e tedesco predisposti): per ora i testi sono scritti in italiano direttamente nel codice, la traduzione si fa dopo.
- **Le decisioni stanno in `docs/01-analisi-iniziale.md`, sezione 2** (tabella numerata, ora fino alla 111). Non riaprirle senza che lo chieda Fabio. Se ne nasce una nuova, si aggiunge lì col numero successivo. Le schermate sono in `docs/videate/` (SVG; indice in `docs/02-videate.md`): si realizza ciò che è disegnato.
- **Velocità prima di tutto.** La tessera deve essere sullo schermo entro 2 secondi da un avvio a freddo, anche senza rete. Niente schermate o controlli di rete prima di mostrare la tessera.
- **Dopo ogni modifica al codice** lanciare, da `app/`: `flutter analyze` e `flutter test`, e correggere finché passano. Se Flutter non è disponibile (per esempio in una sessione su un server), dirlo chiaramente: il codice non è stato provato.
- **Script `frun.sh`** (nella radice): analisi, prove e avvio dell'app in un colpo solo; si ferma al primo errore. Le opzioni passano a `flutter run`.
- **Versione dell'app** (decisione 111): prima di ogni caricamento su uno store alzare `N` in `version: X.Y.Z+N` di `app/pubspec.yaml` (e `X.Y.Z` se cambia la versione), poi etichetta git `vX.Y.Z+N`.
- **Cambi alle tabelle** (`lib/data/database.dart`): rilanciare `dart run build_runner build --delete-conflicting-outputs`. Dopo il primo rilascio ogni cambio di schema richiede una migrazione a passi, con prova su un database della versione precedente (decisione 88).
- **Plugin:** prima di aggiungerne uno, controllare che la compilazione non dia l'avviso "Kotlin Gradle Plugin (KGP)" (le prossime versioni di Flutter rifiuteranno quei plugin); per funzioni piccole meglio un canale nativo nostro in `MainActivity.kt`.
- **Aspetto:** colori e stili stanno in `lib/theme.dart` (tavolozza chiara e scura di `docs/02-videate.md`, letta con `AppColors.of(context)`); i pezzi comuni (logo della tipologia, intestazioni dei gruppi, righe su fondo bianco, riquadri) in `lib/ui.dart`. Niente colori scritti nelle schermate, salvo quelli fissi per regola (riquadro del codice bianco, colori delle tipologie).
- **Import dei widget:** il progetto usa `package:material_ui/material_ui.dart`. La classe `Card` di Drift e quella dei widget si scontrano: importare `data/database.dart` con prefisso (`as db`).
- **Prove automatiche** per la logica dei dati (limite, cestino, sezioni, importazioni, migrazioni); le schermate si provano a mano. La pipeline (`.github/workflows/ci.yml`) le lancia a ogni modifica di `app/`.
- **Marchi:** il disclaimer ("FacileCards non è affiliata…") va ovunque si citino catene, in tutte le lingue (decisione 99).
- **Privacy:** niente raccolta di dati; l'informativa in `site/privacy/` va aggiornata (con la data) a ogni modifica che tocca dati, annunci o acquisto.

## Tenere traccia del da fare

Questo file è il registro. A fine lavoro, ogni volta:
1. spostare in "Fatto" ciò che è finito, con la data;
2. aggiungere in "Da fare" ciò che è emerso;
3. tenere "Prossimo passo" aggiornato (una cosa sola, la più utile ora).

4. aggiungere in coda a `HISTORY.md` una breve voce su cosa è stato deciso o fatto e perché (è la memoria del progetto: leggerlo all'inizio di una sessione per sapere come si è arrivati qui).

Non ripetere qui le decisioni (stanno nell'analisi): qui solo cosa è fatto e cosa manca.

## Stato

Fase 1 del percorso (sezione 7 dell'analisi) in corso. Database Drift con schema versione 1, non ancora rilasciato: si può ancora cambiare lo schema senza migrazioni.

**Prossimo passo:** impostazioni (videate 14, 21), con la voce nel menu ⋮ dell'elenco.

### Fatto

- 2026-11-16: analisi, 45 videate chiare e scure, dominio `facilecards.eu`, repository unico.
- 2026-11-16: progetto Flutter creato (`eu.facilecards.app`, minSdk 24); prototipo con lettura reale del codice e disegno del codice a barre.
- 2026-11-16: database Drift (sezioni, tipologie, tessere, foto, impostazioni); catalogo iniziale delle tipologie (iniziali su colore), riallineato a ogni avvio.
- 2026-11-16: nuova tessera (videate 7, 8), elenco tutte/per sezione con ricerca, preferite e ordinamento (2, 3), tessera (5), sezioni (12, 36–38), cestino con recupero (13) ed eliminazione (18), limite di 50.
- 2026-11-16: pipeline GitHub per analisi e test; repository unico e privato (cronologia ripartita da zero), `README.md` e `CLAUDE.md` nella radice.
- 2026-11-16: scansione completa (videate 22–24): controllo del formato atteso con avviso, torcia, lettura da galleria, inserimento a mano, schermata per permesso negato. Provate sul telefono anche galleria e "Apri impostazioni" (17 nov).
- 2026-11-17: "Da galleria" spostato nella videata 8 accanto a "Scansiona" (decisione 110), tolto dalla fotocamera (22), tenuto nella 24; controllo del codice letto in comune e con prove. Provato sul telefono, insieme alla scansione.
- 2026-11-17: script `frun.sh`; numerazione delle versioni (decisione 111).
- 2026-11-17: configurazione iniziale (videata 1): nome (proposto come intestatario delle nuove tessere), lingua (quella del telefono se offerta, se no inglese), avviso scadenze e giorni (1–90); sezione di partenza col nome nella lingua scelta; nome facoltativo. Provata sul telefono.
- 2026-11-17: scadenze (videata 4): campanella con il numero nella barra dell'elenco (solo se c'è qualcosa da segnalare), riquadro con scadute e in scadenza, tocco sulla tessera per aprirla; giorni di preavviso e avviso acceso/spento dalla configurazione. Provato sul telefono.
- 2026-11-17: tolto il plugin `app_settings` (avviso Kotlin Gradle Plugin di Flutter): "Apri impostazioni" ora è codice nostro in `MainActivity.kt` (canale `facilecards/system`). Provato sul telefono.
- 2026-11-17: foto della tessera (videate 8, 25–28, 39): fronte e retro nella nuova tessera (fronte obbligatorio per la generica), miniatura o "Aggiungi foto" nella scheda, visualizzatore con scorrimento, zoom, Sostituisci ed Elimina foto; foto ridotte a 1600 px e 500 KB, file in `photos/` nello spazio privato, quelli orfani cancellati dopo l'avvio. Anche "Sposta" nella scheda (videata 5). Provato sul telefono.
- 2026-11-17: tema grafico come nei disegni, chiaro e scuro (segue il telefono): tavolozza, campi, pulsanti a pillola, righe su fondo bianco; rifatte elenco (2, 3), scheda (5), nuova tessera (7, 8, con "Salva" fisso in basso), scadenze (4), configurazione (1), sezioni (12), cestino (13, recupero in un foglio dal basso), visualizzatore foto. Colori del catalogo allineati ai disegni. Provato sul telefono.

### Da fare: app

- Inserimento a mano: oggi il codice scritto a mano si salva come Code 128 se la tipologia non indica un formato; valutare se far scegliere il formato.
- La lingua scelta si salva ma l'interfaccia resta in italiano finché non si fanno le traduzioni.
- Tipologia "Formato Tessera non più valido" (6, decisioni 73 e 83) e catalogo con le tessere vere.
- Eliminazione trascinando la riga (17).
- Modifica della tessera (matita nella videata 5) e condivisione dalla scheda: non ancora fatte.
- Sezioni (12): condivisione della sezione, "Esporta tutto", "Importa tutto" e il riquadro "Ultima copia" arrivano con l'esportazione.
- Impostazioni (14, 21): scelta del tema (chiaro, scuro, come il telefono), ordinamento e vista ricordati. Cambiando l'avviso scadenze, l'elenco deve rileggerlo (oggi lo legge all'apertura e al ritorno da Sezioni).
- Condivisione di sezione e di singola tessera (9–11, 107): file `.facilecards` con versione, foto incluse, password facoltativa (decisione 103).
- Esporta tutto / importa tutto (29–35).
- Scorciatoie in Home (16, 19, 20): parte nativa Kotlin, nascoste su Android 7.x.
- Versione Pro: acquisto in-app `facilecards_pro`, controllo con Google Play all'avvio, "Ripristina acquisto" (14, 15, 42–45); sostituire il limite fisso di 50.
- Annunci AdMob (solo banner adattivi) e consenso (40, 41), senza caricare annunci prima del controllo dell'acquisto.
- Backup automatico di Android (database e foto; acquisto escluso).
- Traduzioni inglese e francese (spagnolo e tedesco predisposti); icona e schermata di avvio dell'app.
- Migrazioni del database e prove su database di esempio per ogni versione rilasciata (punto B8).
- Sistemare l'avviso `itf` deprecato in `lib/barcode_support.dart` (usare `itf14`).

### Da fare: verifiche e pubblicazione

- Prova in cassa della fase 0: salvare una tessera vera e farla leggere a uno scanner.
- B1: formati dei codici delle catene del catalogo, da verificare con le tessere vere (finché non si sa, nessun formato obbligatorio).
- Scegliere dove pubblicare il sito (decisione 109); `app-ads.txt` con la riga di AdMob; far rileggere l'informativa.
- Indirizzo e-mail sul dominio per il contatto di informativa e Google Play.
- Materiali per lo store e dichiarazioni nella Play Console (C1, C2); rileggere l'informativa prima della pubblicazione.
- Account sviluppatore Google Play e AdMob, test chiusi richiesti per gli account personali (sezione 8 dell'analisi).
