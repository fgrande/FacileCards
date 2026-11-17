# Storia del progetto

Cronologia di ciò che è stato deciso e fatto, in ordine. Serve per ricordare *perché* le cose sono come sono. Le decisioni complete e numerate stanno in `docs/01-analisi-iniziale.md` (sezione 2); ciò che resta da fare sta in `CLAUDE.md`. Questo file si aggiorna a fine lavoro, in coda.

## Prima del 16 novembre 2026: l'idea e l'analisi

- Il progetto nasce con il nome EasyCards e poi diventa **FacileCards**: un'app Android (Flutter) per tenere le tessere fedeltà, biblioteca e palestra con il loro codice a barre o QR, pronte alla cassa. Autore: Fabio Grande.
- Principio guida: **tutto in locale**, senza server, cloud né account; **velocità** (la tessera sullo schermo entro 2 secondi da un avvio a freddo, anche offline).
- Modello economico: versione gratuita con annunci AdMob e limite di 50 tessere; acquisto una tantum "Pro" (2 €) che li toglie.
- Scritti `docs/00-perche.md` e l'analisi iniziale (requisiti, modello dati, architettura, percorso in fasi, guida a Google Play/AdMob, installazione di Flutter su Mac).
- Prima serie di 8 videate, poi sostituita (cartella `v1`, cancellata il 16 novembre).

## 16 novembre 2026

### Analisi e decisioni (77–107)

- Punti aperti spostati in fondo all'analisi (sezione 10). Loghi delle catene: **iniziali su colore**.
- Risolti uno alla volta tutti i punti del gruppo A e quasi tutti B e C:
  - **Importazione** in tre destinazioni (nuova sezione, unisci, sostituisci); il limite di 50 si calcola sul risultato finale; tutto o niente; cestino 30 giorni fuori dal limite.
  - **Formato del codice**: facoltativo nella tipologia; se indicato il codice deve essere letto in quel formato, altrimenti si accetta qualunque formato; il formato si salva sempre anche sulla singola tessera.
  - **Tipologia ritirata**: termine "Formato Tessera non più valido"; la voce vecchia (per esempio "Basko OLD") resta per le tessere già create ma non si può scegliere per le nuove; il suffisso lo mette l'app dal flag.
  - **Sezione di partenza** "Generale"; la ricerca guarda tutti i campi.
  - **Database con Drift** e migrazioni a passi; prove automatiche anche nella pipeline di GitHub.
  - **Scorciatoia in Home** al posto del widget (icona che apre una tessera; nascosta su Android 7.x; se la tessera è eliminata si apre un pannello per ripristinarla o togliere la scorciatoia).
  - **Condivisione**: file `.facilecards` (archivio con descrittore JSON e foto separate); backup automatico di Android attivo, più "Esporta tutto" manuale.
  - **Password facoltativa** sui file esportati: AES-256, mai obbligatoria, intestazione in chiaro con l'indicatore "cifrato", nessun recupero se la password si dimentica.
  - **Annunci**: solo banner adattivi, consenso UMP (nostra schermata più quella di Google), annunci non personalizzati se negato; categorie bloccate (scommesse, adulti, prestiti rischiosi, politica).
  - **Pro**: nome "Pro" ovunque, nessun limite; acquisto legato all'account Google e ritrovato da solo cambiando telefono (controllo con Google Play all'avvio), "Ripristina acquisto" come ripiego.
  - **Foto della tessera**: miniatura nella scheda al posto del pulsante, vista a tutto schermo con scorrimento fronte/retro, sostituzione ed eliminazione. Importa tutto con seconda conferma.
  - **Disclaimer sui marchi** ovunque, in tre lingue, anche sul sito. Nei testi di condivisione non si menzionano altri intestatari.
- Disegnate **tutte le 45 videate**, in chiaro e scuro (`docs/videate/`).

### Dominio e repository

- Scelta del dominio: **`facilecards.eu`** (acquistato). Identificativo Android **`eu.facilecards.app`**, cambiabile solo fino al primo caricamento su Google Play (decisione 108).
- Il sito non si pubblica su `github.io`. Struttura finale: **un solo repository privato** con `app/`, `site/`, `docs/`; una sola pipeline (analisi e test dell'app, solo se cambia `app/`); sito non ancora pubblicato; hosting da scegliere prima di Google Play (decisione 109). Cronologia git ripartita da zero.
- Scritti `README.md`, `CLAUDE.md` (regole di lavoro e registro del da fare) e questo file.

### Il codice

- Installato Flutter; creato il progetto `app/` (minSdk 24).
- **Fase 0**: prototipo con lettura reale del codice (`mobile_scanner`) e disegno (`barcode_widget`); provato su emulatore.
- **Database Drift** (schema versione 1): sezioni, tipologie, tessere, foto, impostazioni. Catalogo iniziale (Acqua & Sapone, Basko, Calliope, Carrefour, Decathlon, Kiabi, Biblioteca, Palestra, Generica) riallineato a ogni avvio.
- **Schermate**: nuova tessera (videate 7 e 8), elenco tutte/per sezione con ricerca, preferite e ordinamento (2 e 3), tessera (5), sezioni (12, 36–38), cestino con recupero (13), eliminazione con scelta cestino/definitiva (18), limite di 50.
- **Scansione completa** (22–24): controllo del formato atteso con avviso, torcia, lettura da galleria, inserimento a mano, schermata per permesso negato. Scritta ma ancora da provare sul telefono.
- Il nome delle sezioni non è più unico nel database (l'unicità si controlla nel codice), così il nome di una sezione eliminata torna libero.

## Cose da ricordare sul modo di lavorare

- Il codice è stato scritto da una sessione senza Flutter: i comandi (`flutter analyze`, `flutter test`, `flutter run`, `build_runner`) li lanciava Fabio e incollava gli errori. Con Claude Code sul Mac si possono lanciare direttamente.
- Più volte un file riscritto è tornato alla versione vecchia perché l'editor aperto (Android Studio o VS Code) lo risalvava: **ricaricare i file dal disco** prima di lanciare i comandi.
- Gli indirizzi dei record DNS di GitHub Pages erano scritti a memoria e vanno controllati sulla guida ufficiale quando serviranno.

## Dove eravamo rimasti

- Da lanciare: `flutter pub add image_picker app_settings`, poi `flutter analyze` e `flutter test` (il lavoro sulla scansione non è stato ancora verificato).
- Prossimo passo: **configurazione iniziale** (videata 1: nome, lingua, sezione di partenza nella lingua scelta).
- Resta aperta la prova in cassa della fase 0: far leggere una tessera vera a uno scanner.

## 17 novembre 2026: galleria accanto a "Scansiona"

- Su proposta di Fabio, la lettura da galleria esce dalla schermata della fotocamera e va nella videata 8, accanto a "Scansiona" (decisione 110, che modifica la 100). Motivo: molte tessere arrivano già come immagine (screenshot, e-mail, PDF) e così non serve aprire la fotocamera né concederne il permesso. L'inserimento a mano resta nella fotocamera, come ripiego; la videata 24 (permesso negato) tiene anche la galleria.
- Il controllo del codice letto (formato sconosciuto, formato diverso da quello della tipologia) è ora una funzione comune (`checkScanned` in `barcode_support.dart`) con le sue prove; la lettura da galleria sta in `lib/gallery_scan.dart`. Aggiornati i disegni 8 e 22, chiari e scuri.
- Fabio ha provato sul telefono scansione e galleria: funzionano.
- Aggiunto `frun.sh` (analisi, prove, avvio; si ferma al primo errore).
- Decisa la numerazione delle versioni (decisione 111): `X.Y.Z+N` nel pubspec, un solo contatore di build per Google Play e App Store, che cresce a ogni caricamento e non si riusa.
- **Configurazione iniziale** (videata 1, decisioni 65 e 84): al primo avvio nome, lingua, avviso scadenze con giorni di preavviso (predefinito 30, da 1 a 90). Le risposte stanno nella tabella delle impostazioni (nessun cambio di schema); la sezione di partenza prende il nome nella lingua scelta. All'avvio l'app legge un solo valore ("configurazione fatta") prima della prima schermata, per non rallentare. Il nome si propone come intestatario nella nuova tessera. La lingua si salva ma l'interfaccia resta in italiano fino alle traduzioni.
- Il nome nella configurazione iniziale resta **facoltativo** (scelta di Fabio): renderlo obbligatorio avrebbe spinto a scrivere nomi finti, poi riproposti come intestatario. L'etichetta ora dice "Il tuo nome (facoltativo)", anche nei disegni.
- **Scadenze** (videata 4, decisioni 63, 66, 70): campanella con il numero nella barra dell'elenco, che compare solo se ci sono tessere scadute o entro i giorni di preavviso; toccandola scende dall'alto il riquadro con prima le scadute e poi le altre per data, ognuna con etichetta ("Scaduta" in rosso, "Tra N giorni" in ambra). Il preavviso non è più fisso a 30 giorni: viene dalla configurazione, e con l'avviso spento non si segnala niente, nemmeno nelle righe. La logica sta in `lib/expiry.dart`, con prove (anche il giorno limite e il cestino).
- **Tolto il plugin `app_settings`.** Flutter avvisava che il plugin usa il Kotlin Gradle Plugin, che le prossime versioni di Flutter non accetteranno più ("Built-in Kotlin"); la 9.0.1 era già l'ultima. Serviva solo per "Apri impostazioni" nella videata 24, quindi l'abbiamo sostituito con poche righe nostre: un canale `facilecards/system` in `MainActivity.kt` e `lib/system_settings.dart`. Regola per il futuro: prima di aggiungere un plugin, controllare che non dia questo avviso; per cose piccole meglio il codice nativo nostro.
- Fabio ha provato sul telefono scadenze e "Apri impostazioni": funzionano.
- **Foto della tessera** (decisioni 6, 37, 72, 101): nella nuova tessera due riquadri Fronte e Retro (per la tessera generica il fronte è obbligatorio); nella scheda la miniatura del fronte con il numero di foto, o "Aggiungi foto", che chiede il fronte e poi porta al retro; visualizzatore a tutto schermo con scorrimento fra i lati, zoom, tocco per chiudere, Sostituisci ed Elimina foto con conferma (il fronte della generica si può solo sostituire). Ogni foto si sceglie da fotocamera o galleria, si riduce a 1600 px e sotto 500 KB (pacchetto `image`, puro Dart, in un isolate) e va in `photos/` nello spazio privato; nel database solo il nome del file, nuovo a ogni sostituzione. I file delle tessere cancellate (anche dal cestino all'avvio) si tolgono dopo la prima schermata, confrontando la cartella con il database: così non si rallenta l'avvio. Aggiunto anche "Sposta" nella scheda, presente nel disegno.
- Nuova tessera più compatta (richiesta di Fabio: "Salva" finiva sotto il bordo dello schermo): il campo Note parte da una riga e si allarga fino a tre mentre si scrive; tolto il contatore "N di 50 tessere" (il limite si controlla comunque al salvataggio). Aggiornato il disegno 8.
- Fabio ha provato sul telefono foto e nuova tessera compatta: funzionano.

## 17 novembre 2026: l'aspetto dei disegni

- Fabio ha notato che l'app non somigliava ai disegni: finora c'era il tema standard di Flutter. Deciso di fare il tema grafico prima delle impostazioni, perché ogni schermata nuova nasca già giusta e perché il tema scuro è metà del lavoro delle impostazioni.
- `lib/theme.dart`: la tavolozza chiara e scura di `docs/02-videate.md` come estensione del tema (`AppColors`), più lo stile di campi (bianchi, angoli 12), pulsanti a pillola, barre, finestre e fogli. `lib/ui.dart`: logo della tipologia a quadrato arrotondato (iniziali del nome della tessera per le tipologie a nome libero, "Biblioteca civica" → BC), intestazioni dei gruppi, righe a tutta larghezza su fondo bianco, riquadri, simbolo dell'app (`assets/logo-mark.svg`, con `flutter_svg`, puro Dart).
- Rifatte, confrontandole con i disegni su un emulatore con un database di prova: elenco (pillola "Tutte / Per sezione", ordinamento a pillola, stella sulle preferite, "+" rotondo, menu ⋮), scheda della tessera (fascia nel colore della tipologia, codice nel riquadro bianco anche al buio, dettagli in un riquadro), nuova tessera (riquadro della tipologia, Sezione e Scadenza affiancate, preferita con la stella, "Salva" fisso in basso), scadenze, configurazione, sezioni, cestino (recupero in un foglio dal basso, come nel disegno 13) e visualizzatore delle foto.
- I colori delle tipologie del catalogo ora sono quelli dei disegni; si aggiornano da soli all'avvio, perché il catalogo si riallinea.
- Nella vista per sezione il sottotitolo è la sezione per le preferite e il tipo di tessera ("Tessera fedeltà") per le altre, come nel disegno 3.
- Fabio ha provato il nuovo aspetto sul telefono: va bene.
- **Impostazioni** (videata 14) dal menu ⋮ dell'elenco: nome, lingua (salvata; l'app avvisa che per ora resta in italiano), tema (come il telefono, chiaro, scuro: si salva e l'app cambia subito; letto all'avvio insieme alla configurazione), avviso scadenze con interruttore e giorni. Riquadro della versione gratuita con il numero di tessere; "Passa a Pro" e "Ripristina acquisto" per ora dicono che l'acquisto arriverà con Google Play. Nascoste finché non servono: "Gestisci consenso annunci" (arriva con gli annunci) e "Richiedi una tessera mancante" (manca ancora l'indirizzo e-mail; si accende in `lib/links.dart`).
- **Informazioni** (videata 21): simbolo, versione letta da Android, sviluppatore, avvertenza sui marchi (decisione 99), link a informativa e sito. Il disegno indicava `facilecards.github.io`: usato `facilecards.eu` (decisione 108).
- Link e versione senza plugin: due funzioni in più nel canale nativo `facilecards/system` (`openUrl`, `appVersion`), come già per "Apri impostazioni".
- L'elenco ricorda vista ("Tutte" / "Per sezione") e ordinamento tra un avvio e l'altro.
- Fabio ha chiesto perché l'app ci metta un paio di secondi ad aprirsi: è soprattutto la versione di prova (debug); la definitiva si misura con `--release`. Annotate per dopo, in `CLAUDE.md`: alleggerire l'avvio (catalogo riallineato solo quando cambia, cestino svuotato dopo la prima schermata), icona dell'app dal nostro logo e una schermata di avvio con tante tessere sparse e leggermente sfocate, come su un ripiano (idea di Fabio). Le impostazioni sono da provare sul telefono prima del commit.
- Fabio ha provato le impostazioni sul telefono: funzionano.
