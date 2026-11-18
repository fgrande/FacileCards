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

## 18 novembre 2026: modifica della tessera

- Matita nella barra della scheda (videata 5): apre la stessa pagina della nuova tessera, già compilata, con il titolo "Modifica tessera". La tipologia non si cambia (porterebbe con sé formato e foto obbligatorie diverse: se è sbagliata si fa una tessera nuova). Il formato del codice resta quello salvato finché il codice non si riscrive a mano o si rilegge.
- Le foto cambiate nel modulo (sostituite o tolte) si applicano solo con "Salva", in una transazione insieme ai dati (`updateCard` nel database, con prove); i file vecchi si cancellano dopo. Con "indietro" non cambia niente. Il fronte della tessera generica resta obbligatorio anche modificando.
- La scheda tiene allineata la propria copia della tessera anche dopo stella e "Sposta", altrimenti una modifica successiva li avrebbe annullati.
- Nel modulo la scadenza si mostra in formato corto (31/12/2027): quella estesa veniva tagliata.
- Rimossa da `CLAUDE.md` una voce del "Da fare" sulle impostazioni rimasta per errore.
- Fabio ha provato la modifica della tessera sul telefono: funziona.
- **Icona dell'app**: disegnata come grafica vettoriale di Android a partire da `docs/logo/facilecards-icon.svg` (icona adattiva: tessera con il pollice su fondo blu, dentro la zona sicura, così il telefono può ritagliarla a cerchio o a goccia), più i PNG per Android 7 ricavati dallo stesso SVG con Chrome senza finestra. Nessuno strumento aggiunto al progetto. All'apertura Android mostra ora la nostra icona invece del logo di Flutter.
- **Schermata di avvio con le tessere sparse**: lasciata perdere su indicazione di Fabio.
- **Avvio più rapido**: il catalogo delle tipologie si riscrive solo se cambia la sua impronta (salvata nelle impostazioni), e il cestino si svuota dopo la prima schermata insieme alla pulizia delle foto. Misurato in versione definitiva sull'emulatore, 8 avvii a freddo prima e dopo: avvio completo circa 0,6 s (mediana 616 ms prima, 643 dopo), il nostro codice dall'avvio alla prima schermata circa 80 ms (82 prima, 76 dopo). La differenza sta dentro le oscillazioni: quei lavori pesavano poco, ma restano utili su telefoni lenti e con il cestino pieno. La lentezza vista da Fabio era della versione di prova.
- Il testo dell'elenco vuoto diceva ancora "Premi Aggiungi": ora "Tocca +".
- Notato: l'APK universale in versione definitiva pesa circa 80 MB; da verificare la dimensione reale scaricata da Google Play.
- Fabio ha provato icona e avvio sul telefono: funzionano.

## 18 novembre 2026: Esporta tutto (tappa 1 di 3)

- Piano in tre tappe, approvato da Fabio: 1) formato del file ed esportazione senza password; 2) importazione con unione e sostituzione; 3) password. Fabio ha aggiunto che "Salva sul telefono" deve ricordare dove si è salvato l'ultima volta: decisione 112 (selettore "Salva in…" di Android, riaperto nell'ultima cartella; nome `FacileCards-AAAA-MM-GG.facilecards`).
- **Formato `.facilecards`, versione 1** (`lib/transfer/archive_format.dart`): zip con `header.json` sempre in chiaro (formato, versione, tipo "all/section/card", data, se cifrato) e il contenuto (`content.zip`, o `content.bin` quando sarà cifrato) con `data.json` e le foto in `photos/`. Il backup completo porta anche preferita, data di inserimento e di ultimo uso; il cestino è escluso. La lettura tratta il file come non fidato: identificativi, testi, date, percorsi delle foto e numeri controllati, con limiti di dimensione; un file di una versione più recente chiede di aggiornare l'app. Libreria `archive` (Dart puro).
- **Esporta tutto** (`lib/screens/export_screen.dart`): da Sezioni → Archivio; passo 1 con il riepilogo (tessere, sezioni, peso stimato) e i quattro avvisi, passo 2 con "Ho capito" (si azzera tornando indietro), poi "Salva sul telefono" o "Condividi…". Salvataggio e condivisione con codice nativo nostro in `MainActivity.kt` (selettore `ACTION_CREATE_DOCUMENT` con l'ultima posizione, `FileProvider` per la condivisione): nessun plugin. Provato sull'emulatore: file salvato con il nome giusto, contenuto corretto, al secondo salvataggio il selettore riparte dalla cartella scelta, la condivisione propone Drive e Gmail.
- Nelle Sezioni il promemoria discreto previsto dall'analisi (5.5): "Le tue tessere esistono solo su questo telefono. Ultima copia: N giorni fa." Anche una condivisione conta come copia fatta, perché l'app non può sapere se l'altra app salverà davvero.
- Fabio ha provato "Esporta tutto" sul telefono: funziona.

## 18 novembre 2026: Importa tutto (tappa 2 di 3)

- **Importa tutto** da Sezioni → Archivio. Il file si sceglie con il selettore di Android (codice nativo nostro, con un tetto di 300 MB; parte dalla cartella dell'ultimo backup), si legge e si controlla in un isolate. File protetti da password o di una sola sezione/tessera per ora si rifiutano con un messaggio chiaro.
- Schermata come le videate 29–31: riepilogo ("Archivio di Fabio Grande · 2 sezioni · 4 tessere · Creato il…"), "Unisci" o "Sostituisci tutto", esito sul limite in verde o in rosso con "Scopri Pro" e pulsante spento (decisione 17: conta il risultato).
- Logica (`lib/transfer/import.dart`, con prove): "Unisci" aggiunge solo le tessere che mancano, riconosciute dall'identificativo, e rimette in uso quelle che erano nel cestino; "Sostituisci tutto" manda le attuali nel cestino e importa quelle del file. Le sezioni: quella di partenza del file va in quella del telefono, le altre si ritrovano per identificativo (decisione 79) o per nome, altrimenti si creano. Tipologia sconosciuta → tessera generica. Foto riscritte con `PhotoStore` (quindi controllate e ridotte); tutto il database in una transazione, e se qualcosa va storto le foto già scritte si cancellano.
- Nella conferma di "Sostituisci tutto" il numero di tessere che finiscono nel cestino è quello vero: quelle presenti anche nel file restano in uso (visto provando sull'emulatore, dove il testo del disegno sarebbe stato sbagliato).
- Trovato provando: la lettura in un isolate falliva perché la funzione interna si portava dietro lo stato della schermata; ora le funzioni passate agli isolate sono a sé, anche nell'esportazione.
- Fabio ha provato "Importa tutto" sul telefono: funziona.

## 18 novembre 2026: password sui file (tappa 3 di 3)

- **Password facoltativa** (decisione 103). In "Esporta tutto", passo 2: interruttore "Proteggi con password", password scritta due volte (almeno 8 caratteri, controllo in tempo reale) e l'avvertenza che senza password il file non si riapre. Il contenuto (dati e foto, compresi nomi e numero di tessere) si cifra con AES-256-GCM; la chiave si ricava dalla password con PBKDF2-HMAC-SHA256 a 200.000 ripetizioni (sul Mac 50.000 richiedono circa 150 ms: circa un secondo su un telefono medio). Sale, nonce e ripetizioni stanno nell'intestazione in chiaro, così un file protetto si riconosce senza password e il numero si potrà alzare in futuro. Libreria `cryptography`, Dart puro. Nessuna chiave dentro l'app.
- **All'importazione** un file protetto apre la richiesta della password (videate 34, 35): pulsante spento a campo vuoto, password errata ritentabile senza limiti, "Il file non è stato modificato". Decifratura in un isolate. I parametri letti dal file sono controllati (per esempio un numero di ripetizioni enorme, che bloccherebbe il telefono, si rifiuta).
- Provato sull'emulatore: file salvato con la password, intestazione leggibile e nessun nome in chiaro nel contenuto; password sbagliata segnalata, password giusta porta al riepilogo.
- L'interruttore spento era quasi invisibile su fondo bianco: ora ha un grigio ben leggibile in tutta l'app.
- Con questo "Esporta tutto" e "Importa tutto" sono completi. Prossimo passo proposto: condivisione di una sezione e di una tessera, con lo stesso file.
- Fabio ha provato la password sul telefono: funziona.

## 18 novembre 2026: condivisione, tappa 1 (invio)

- Piano in tre tappe approvato da Fabio: 1) invio; 2) ricezione da dentro l'app, con la voce "Importa tutto" trasformata in **"Importa da file"** (riconosce da sola copia completa, sezione o tessera: scelta di Fabio) e la migrazione del database per gli identificativi d'origine (decisione 79); 3) "Apri con FacileCards" da altre app.
- **Invio**: "Condividi" nel menu della sezione (videata 36; solo se la sezione ha tessere) e icona di condivisione nella barra della scheda (videata 5, ora come nel disegno: stella, matita, condivisione, cestino). Stesso flusso di "Esporta tutto" generalizzato (`ExportTarget`): passo 1 con i quattro avvisi della videata 9 (usare, vedere, inoltrare, non ritirare), passo 2 come la videata 10 con "Ho capito", anteprima del messaggio e del file, password facoltativa e il solo pulsante "Condividi". Messaggio: "Ti invio le tessere della sezione «…». Per aprirle serve FacileCards:" con il link a Google Play (`storeUrl` in `lib/links.dart`, funziona dalla pubblicazione). Nome del file: quello della sezione o della tessera, ripulito dai caratteri vietati. Sopra i 20 MB un avviso (decisione 92).
- Nel file condiviso viaggiano codici, intestatario, note, scadenza e foto (decisione 67), ma non preferita, date di inserimento e di uso, né il nome del proprietario: sono personali. Prove su cosa contiene il file di una sezione e di una tessera.
- Messe in coda due richieste di Fabio, d'accordo anche Claude: icona di condivisione Android a tre pallini al posto di quella stile iPhone; menu ⋮ con due voci separate, "Sezioni" e "Dati" (copie, importazione, cestino), al posto di "Sezioni e cestino".
- Fabio ha provato l'invio di sezione e tessera sul telefono: funziona.

## 18 novembre 2026: condivisione, tappa 2 (ricezione)

- **Prima migrazione del database** (versione 1 → 2): sezioni con `originId` e `receivedAt`, tessere con `originId`, per riconoscere una sezione già ricevuta (decisione 79) e sostituirne la copia (decisione 80). Anche se l'app non è rilasciata, il telefono di Fabio ha dati veri: quindi una vera migrazione, con la copia di sicurezza prevista dalla decisione 88 (`facilecards.sqlite.v1.bak`, fatta con `VACUUM INTO` all'apertura, prima di drift) e la prova su un database versione 1. Gli schemi delle versioni stanno in `test/fixtures/` (B8). Provata anche sull'emulatore, che aveva un database versione 1: tessere intatte, copia creata.
- **"Importa da file"** al posto di "Importa tutto" (scelta di Fabio): riconosce copia completa, sezione o tessera e apre la schermata giusta; la parte che apre il file è separata dalla scelta, così servirà anche ai file arrivati da altre app (tappa 3).
- **Importa sezione** (videata 11): "Nuova sezione" con il nome originale o, se già usato, "Famiglia 2"; "Unisci a una sezione esistente" (salta le tessere con stessa tipologia e stesso codice, o già ricevute); "Sostituisci «…»" solo se la sezione era già stata ricevuta, con "Già ricevuta il…". La sostituzione segue la decisione 80: le tessere della copia precedente assenti nel file vanno nel cestino, quelle aggiunte da chi riceve restano, quelle presenti prima e dopo si aggiornano conservando preferita e ultimo uso. Le tessere ricevute prendono un identificativo nuovo e ricordano quello d'origine.
- **Importa tessera** (decisione 107): si sceglie la sezione, proposta la Generale. Limite mostrato prima, come per la copia completa.
- Prove sulla ricezione (nuova sezione, nome già usato, unione senza doppioni, sostituzione, tessera singola, limite).

- Su richiesta di Fabio, quando una sezione è già stata ricevuta la videata 11 propone "Sostituisci" invece di "Nuova sezione" (decisione 113): chi riceve di nuovo la stessa sezione di solito vuole l'aggiornamento. Aggiornati i disegni 11 (chiaro e scuro); "Nuova sezione" ha ora una riga di spiegazione come le altre scelte.
- Fabio ha provato la migrazione e la ricezione di sezioni e tessere sul telefono: funziona.

## 18 novembre 2026: menu "Sezioni" e "Dati", icona di condivisione

- Su richiesta di Fabio il menu ⋮ dell'elenco ha ora "Sezioni" e "Dati" al posto di "Sezioni e cestino" (decisione 114): le sezioni da una parte, copia, importazione e cestino dall'altra, che sono cose diverse. Nuova videata 12b (Dati), la 12 alleggerita.
- L'icona di condivisione è quella di Android (tre pallini collegati) invece del quadrato con la freccia, che è lo stile di iPhone; cambiata anche in tutti i disegni (05, 06, 12, 18, 19, 28, 36–38, 44, chiari e scuri).
- Il disegno 12 aveva già un pulsante di condivisione su ogni riga di sezione, che nell'app mancava (c'era solo nel menu): aggiunto.
- Fabio ha provato il nuovo menu e l'icona di condivisione sul telefono: funziona.

## 18 novembre 2026: condivisione, tappa 3 ("Apri con FacileCards")

- FacileCards si dichiara ad Android come app che apre i file. Nessuna app conosce l'estensione `.facilecards`, quindi WhatsApp, Gmail e Drive la passano come file generico o zip: si accettano quei tipi, e un file che non è nostro riceve il messaggio "Non è un file di FacileCards". Effetto voluto: FacileCards compare anche tra le app proposte per altri file sconosciuti, come fanno le app simili.
- Il codice nativo copia subito il file (il permesso di leggerlo dura poco) e lo tiene finché Flutter non lo chiede; Flutter lo chiede dopo che l'elenco è comparso, così l'avvio resta rapido, e dopo la configurazione iniziale se è il primo avvio. Avvio dell'attività cambiato in `singleTask`: con l'app già aperta il file arriva a quella, invece di aprirne una seconda dentro l'app di provenienza.
- "Condividi verso FacileCards" (pannello Condividi delle altre app) lasciato fuori: si aggiunge solo se le prove con le app vere lo richiedono.
- Fabio ha provato "Apri con FacileCards" sul telefono: funziona.

## 18 novembre 2026: traduzioni (inglese e francese)

- Tutti i testi dell'interfaccia (357) sono passati dai sorgenti ai file di traduzione di Flutter (`lib/l10n/app_it.arb`, `app_en.arb`, `app_fr.arb`), come chiede l'analisi (5.8): niente più testi nel codice. Fatto adesso perché ogni schermata nuova avrebbe aggiunto lavoro.
- La lingua si cambia dalle impostazioni e si applica subito; nella configurazione iniziale l'interfaccia segue la lingua man mano che la si sceglie. Prima della configurazione vale la lingua del telefono (o l'inglese).
- I messaggi d'errore dei file `.facilecards` nascono in un isolate, dove la lingua scelta non è nota: ora la logica lancia un codice (`TransferProblem`) e il testo si ricava quando si mostra.
- Le tipologie generiche (Biblioteca, Palestra, Tessera generica) si traducono; i nomi dei negozi sono marchi e restano come sono (analisi, 5.8). Restano com'erano anche i nomi delle sezioni: sono dati dell'utente.
- Inglese britannico e date all'europea (decisione 115). Trovato e corretto sull'emulatore: in francese lo zero prende il singolare, e il testo "1 carte" compariva anche con zero tessere.
- Le traduzioni le ho scritte io: da far rileggere prima della pubblicazione.
- Fabio ha provato le traduzioni sul telefono: funziona.

## 18 novembre 2026: backup automatico di Android

- Come previsto dalla decisione 93, il backup di Android salva database e foto; le regole sono scritte a elenco chiuso, così cache e copie di sicurezza `.bak` delle migrazioni restano fuori e non entra niente per sbaglio. In futuro ne resterà fuori anche lo stato dell'acquisto Pro.
- Limite di Android: 25 MB per app, e oltre quel limite l'app non viene salvata per niente. Con 50 tessere e due foto da 500 KB al massimo si potrebbe arrivare a 50 MB, ma di solito le foto sono poche: invece di complicare il backup, la schermata Dati avvisa oltre 20 MB e invita a "Esporta tutto".
- Provato sull'emulatore con il trasporto locale (`bmgr`): backup, disinstallazione, reinstallazione, tessere tornate. Nota per le prove: un'app fermata con "Forza interruzione" non viene salvata finché non la si riapre.
- Fabio ha provato il backup di Android sul telefono: funziona.

## 18 novembre 2026: eliminazione trascinando la riga

- Come nel disegno 17: la riga trascinata a sinistra scopre il pulsante "Elimina", che porta alla stessa scelta della scheda (cestino o eliminazione definitiva, decisione 75). Avevo proposto un'eliminazione immediata con "Annulla", ma il disegno e la decisione chiedono la scelta: si è seguito il disegno.
- Widget nostro (`swipe_to_delete.dart`), senza plugin: una sola riga aperta alla volta, un tocco sulla riga aperta la richiude invece di aprire la tessera.
- Fabio ha provato l'eliminazione trascinando sul telefono: funziona.
