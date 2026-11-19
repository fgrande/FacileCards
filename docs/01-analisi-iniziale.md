# FacileCards — Analisi iniziale

Versione 1.19 — 16 novembre 2026 — bozza da validare

**Cambio di impostazione.** Questa versione sostituisce integralmente le precedenti (0.1–0.7): FacileCards diventa un'app **solo locale**, senza backend, senza cloud, senza login. Le voci marcate **(proposta)** sono mie e vanno confermate o corrette.

**Novità della 1.19:** rilettura completa. Ampliato il paragrafo 5.4 su versione a pagamento e Google Play; la sezione 10, in fondo al documento, elenca i punti da approfondire; loghi delle catene: iniziali su colore (decisione 77); percorso (sezione 7) riallineato alle decisioni; corrette le decisioni superate (6, 29, 60) e la numerazione dei punti di attenzione.

---

## 1. Obiettivo

FacileCards è un portafoglio digitale di tessere fedeltà. L'utente registra le proprie tessere (tipologia da catalogo + codice personale), le organizza in sezioni e le mostra in cassa dal telefono. Tutti i dati vivono sul dispositivo.

Il motivo per cui il progetto esiste è descritto in `00-perche.md`, testo di riferimento da riusare su sito, store e documentazione: all'arrivo in cassa la tessera deve comparire subito, senza dipendere dalla rete.

Il requisito guida è la **velocità**: dall'apertura dell'app alla tessera a schermo devono passare pochi istanti.

## 2. Decisioni prese

| # | Decisione |
|---|---|
| 1 | **Solo app, solo locale.** Tessere, sezioni e preferenze vivono sul dispositivo. Nessun backend, nessun cloud, nessun login, nessuna area web o di amministrazione |
| 2 | **Prima piattaforma: Android** |
| 3 | **Catalogo tipologie** come archivio di base: per ora nome, logo, colore e tipo di codice |
| 4 | **Più istanze della stessa tipologia** (es. una intestata a sé, una al coniuge) |
| 5 | **Nome della tessera modificabile**; il valore iniziale viene dal catalogo |
| 6 | **Tessera Generica**: foto ridimensionate a circa 1600 px sul lato lungo, massimo 500 KB per immagine. Conta come ogni altra tessera. Campi obbligatori: vedi decisione 72 |
| 7 | **Una tessera appartiene a una sola sezione** e può essere spostata in un'altra |
| 8 | **Sezione "Default"** sempre presente: rinominabile, non eliminabile |
| 9 | **Una sezione con tessere non si elimina**: vanno prima eliminate le tessere, oppure l'app chiede conferma per eliminarle tutte |
| 10 | **Schermata principale a elenco unico, in due modalità**: tutte le tessere insieme, oppure raggruppate per sezione. L'ordinamento vale sull'intero elenco nel primo caso, dentro ogni sezione nel secondo |
| 11 | **Ordinamenti**: alfabetico, data di inserimento, data di ultimo utilizzo, ciascuno crescente o decrescente |
| 12 | **Condivisione tramite file.** Una sezione si esporta in un file e si invia con WhatsApp o qualsiasi canale di condivisione del dispositivo. Per aggiornare si reinvia l'intera sezione. Il destinatario ne fa ciò che vuole: chi invia perde ogni controllo su quanto condiviso |
| 13 | **Versione gratuita**: massimo 50 tessere; annunci al piede dell'elenco iniziale e al piede della schermata della singola tessera |
| 14 | **Versione a pagamento (2 €, una tantum)**: nessun annuncio e nessun limite di tessere |
| 15 | **Importazione e limite**: nella versione gratuita un file non si importa se farebbe superare le 50 tessere; nella versione a pagamento non ci sono limiti |
| 16 | **Destinazione dell'importazione scelta dall'utente**: unione in una sezione esistente, oppure nuova sezione con un nome non ancora usato. Se la sezione era già stata ricevuta, è disponibile anche "sostituisci la copia precedente" |
| 17 | **Limite calcolato sul risultato**: contano le tessere che resterebbero a operazione conclusa; se superano 50 l'importazione è rifiutata per intero |
| 18 | **La sezione importata mantiene il nome originale**, modificabile sia durante l'importazione sia in seguito |
| 19 | **Esporta tutto / Importa tutto** come backup manuale, attraverso lo stesso pannello di condivisione (es. verso Google Drive); la conservazione del file è a cura dell'utente |
| 20 | **Eliminazione a scelta**: l'app chiede se eliminare definitivamente subito; altrimenti la tessera va nel cestino, da cui è recuperabile per 30 giorni. Le tessere nel cestino non vengono esportate |
| 21 | **Catalogo aggiornato solo con gli aggiornamenti dell'app**, per ora |
| 22 | **Nessun annuncio a schermo intero** né interruzioni rilevanti, per ora; da rivalutare sull'interfaccia definitiva |
| 23 | **Si condivide una sezione intera oppure una singola tessera** |
| 24 | **I nomi delle sezioni sono univoci** sul dispositivo |
| 25 | **Tessera già esistente = stessa tipologia e stesso codice**: nelle unioni si aggiungono solo quelle nuove |
| 26 | **"Importa tutto" chiede**: azzerare e importare, oppure unire aggiungendo solo le tessere nuove |
| 27 | **Le tessere nel cestino non contano nel limite**; il recupero è bloccato se non c'è posto |
| 28 | **Il recupero di una tessera permette di scegliere la sezione di destinazione**; quella proposta è la sezione d'origine, che viene ripristinata se nel frattempo era stata eliminata |
| 29 | **Tessere senza codice** (caso ormai residuale, dato che il codice è obbligatorio anche per la Generica): i doppioni si riconoscono dall'identificativo interno della tessera, che viaggia nel file |
| 30 | **In un'unione la tessera già presente resta com'è**, anche se nel file ha nome o note diversi |
| 31 | **I doppioni si cercano solo nella sezione di destinazione**; "Importa tutto" procede sezione per sezione |
| 32 | **"Azzera e importa" sposta nel cestino** le tessere rimosse |
| 33 | **Progetto personale**, con account sviluppatore e account annunci personali; nessuna scadenza |
| 34 | **Annunci con Google AdMob** |
| 35 | **Mercato iniziale italiano; interfaccia in italiano, inglese e francese**, predisposta per altre lingue (spagnolo, tedesco) |
| 36 | **Gestione del catalogo**: le prime tipologie si preparano in questo progetto; gli utenti ne richiedono altre via email e vengono integrate nel sorgente con le nuove versioni. Una tipologia può essere ritirata o sostituita da una nuova, con scadenza forzata applicata dall'aggiornamento dell'app |
| 37 | **Foto fronte/retro facoltative su qualunque tessera**, anche da catalogo |
| 38 | **Non solo tessere fedeltà**: anche biblioteca, palestra e simili; l'app mostra solo codici (a barre, QR…) |
| 39 | **Tipologia ritirata**: le tessere esistenti restano utilizzabili e modificabili, con un avviso; non se ne possono creare di nuove |
| 40 | **Tipologie "di categoria"** per enti locali e numerosi: una "Biblioteca" e una "Palestra" con icona propria e nome libero, invece di una per ogni ente |
| 41 | **Catalogo iniziale**: Carrefour, Basko, Decathlon, Acqua & Sapone, Sapore di Mare, Kiabi, PAM, Terranova, Calliope, Mercatò, Scarpe&Scarpe |
| 42 | **Email di contatto**: quella dell'account sviluppatore con cui verrà pubblicata l'app, usata anche per le richieste di nuove tessere |
| 43 | **Account Google Play Console** da aprire con l'account Google personale dello sviluppatore |
| 44 | **Sito del progetto**: indirizzo pubblico `https://facilecards.eu` (decisione 108); i file stanno in `site/`; la pubblicazione è rinviata e il servizio di hosting si sceglie in quel momento (decisione 109) |
| 45 | **Tipologia sostitutiva**: a seconda del caso la tessera mantiene il codice oppure ne richiede uno nuovo; lo stabilisce il catalogo per ogni sostituzione |
| 46 | **Sviluppatore unico.** Analisi e documentazione in italiano per ora, da convertire in inglese in seguito |
| 47 | **Nome del progetto e dell'app: FacileCards** |
| 48 | **Struttura delle cartelle**: un unico repository privato `FacileCards/` con `app/` (progetto Flutter), `site/` (sito) e `docs/` (documentazione), più `README.md` e `CLAUDE.md` nella radice (decisione 109) |
| 49 | **Colore primario: blu.** Logo: una tessera con il pollice alzato (ipotesi in `02-videate.md`) |
| 50 | **Dopo l'acquisto si sblocca tutto subito** (limite e annunci): non c'è altro da gestire |
| 51 | **Nessun accordo con le catene** (offerte, volantini): non previsto, probabilmente mai |
| 52 | **Obiettivo di velocità**: tessera a schermo entro 2 secondi dall'avvio a freddo |
| 53 | **All'apertura si vede sempre l'elenco**; per trovare la tessera: ricerca per nome, ordinamenti, tessere preferite |
| 54 | **Widget nella schermata iniziale del telefono**: ognuno apre direttamente una tessera; se ne possono mettere più di uno |
| 55 | **Nessun blocco dell'app** (né biometria né PIN) |
| 56 | **Tester per il test chiuso**: le 12 persone sono disponibili |
| 57 | **Nome FacileCards verificato** dallo sviluppatore su Google Play e nei registri dei marchi: nessun risultato |
| 58 | **Le tessere preferite stanno in cima all'elenco**; la resa grafica potrà essere rivista |
| 59 | **Widget**: mostra logo e nome della tessera, non il codice; il tocco apre l'app direttamente su quella tessera |
| 60 | **Videate** (`02-videate.md`): allineate alle decisioni il 16 novembre 2026, in versione chiara e scura; da aggiornare a blocchi, non a ogni singola decisione |
| 61 | **Google Wallet fuori dalla prima versione** |
| 62 | **Altri dati per tessera**: note, intestatario (proposto in automatico, modificabile), scadenza facoltativa |
| 63 | **Tessere scadute o in scadenza** evidenziate in un'area dedicata dell'interfaccia |
| 64 | **Messaggio di condivisione**: accompagna il file con il nome dell'app e il link allo store |
| 65 | **Configurazione iniziale con tre domande**: nominativo dell'intestatario, facoltativo (chiarito il 17 nov 2026), si propone come intestatario delle nuove tessere; lingua (predefinita quella del telefono); avviso scadenze attivo o no e numero di giorni di preavviso (predefinito: attivo, 30 giorni) |
| 66 | **Avviso scadenze regolato dalla configurazione**: se attivo, una tessera è "in scadenza" a partire dal numero di giorni impostato |
| 67 | **Nel file condiviso viaggia tutto**: note, intestatario e scadenza compresi. Le tessere si condividono tra familiari, non con sconosciuti |
| 68 | **Esportazione con doppia conferma**: prima di condividere, l'app spiega che le tessere stanno per essere consegnate ad altre persone e chiede di confermare due volte, perché l'utente capisca ciò che sta facendo |
| 69 | **Doppia conferma anche per "Esporta tutto"**, con testo adattato |
| 70 | **Scadenze solo dentro l'app**: una campanella con indicatore, espandibile per vedere i dettagli; nessuna notifica di sistema |
| 71 | **Scansione del codice dalla fotocamera fin dalla prima versione** |
| 72 | **Tessera Generica**: codice e foto del fronte obbligatori; foto del retro facoltativa |
| 73 | **Tipologia ritirata segnalata sull'icona**: un segnale di avviso sull'icona della tessera, nell'elenco e nella scheda; toccandolo si apre un riquadro con la spiegazione |
| 74 | **Tema chiaro / scuro / come il telefono**, selezionabile dalle impostazioni |
| 75 | **Eliminazione di una tessera in due modi**: trascinando la riga verso sinistra nell'elenco (compare il pulsante di eliminazione) oppure dal pulsante cestino dentro la tessera. In entrambi i casi segue la scelta tra cestino ed eliminazione definitiva |
| 76 | **Versioni di Android**: minimo API 24 (Android 7.0, il limite di Flutter), target e compilazione API 36 (Android 16, richiesto da Google Play) |
| 77 | **Loghi delle catene**: iniziali su colore, come nelle videate; nessun logo reale |
| 78 | **Rimborso della versione Pro con più di 50 tessere**: restano tutte, consultabili e utilizzabili; si blocca solo l'aggiunta finché non si scende sotto 50 o si riacquista |
| 79 | **Riconoscere una sezione già ricevuta**: ogni sezione importata conserva l'identificativo d'origine; il riconoscimento non dipende dal nome, quindi resiste alla rinomina. Si perde se la sezione viene unita a un'altra (il file è trattato come nuovo); se viene divisa, lo conserva la sezione che tiene la parte principale delle tessere d'origine |
| 80 | **Cosa fa "sostituisci"**: si tolgono (nel cestino, 30 giorni) solo le tessere della copia precedente assenti nella nuova; le tessere aggiunte dal destinatario restano; per le tessere presenti prima e dopo si conservano preferita e ultimo utilizzo |
| 81 | **Tessera "usata"**: conta come usata all'apertura della sua schermata; le tessere mai aperte vanno in fondo nell'ordinamento per ultimo utilizzo |
| 82 | **Formato del codice e tipologia**: nel catalogo il formato è facoltativo. Se la tipologia lo indica, il codice scansionato deve essere letto in quel formato, altrimenti viene rifiutato (controllo contro l'errore di tipologia); se non lo indica, si accetta qualunque formato. Il formato effettivo si salva comunque sulla singola tessera |
| 83 | **Tipologia ritirata, termine e meccanismo**: "scadenza" resta solo la data scritta sulla tessera; per la tipologia il termine nell'interfaccia è **"Formato Tessera non più valido"**. Quando una catena cambia tessera, in fase di sviluppo la voce vecchia viene marcata come non più valida con un indicatore nel catalogo (non selezionabile per nuove tessere, ma con lo stesso identificativo interno, così le tessere già create restano associate) e si aggiunge una nuova voce "Basko" con il formato nuovo. Il nome non si modifica a mano: è l'app che, in base all'indicatore, la presenta come "vecchia" (es. "Basko OLD") nella lingua dell'utente. Per passare al formato nuovo l'utente scansiona una nuova tessera con la voce nuova; la vecchia resta finché non la elimina |
| 84 | **Sezione di partenza e lingua**: alla configurazione iniziale la sezione di partenza prende il nome nella lingua scelta ("Generale" in italiano; "General" in inglese, "Général" in francese, da confermare) e poi resta com'è, perché rinominabile; stessa regola per le sezioni proposte come "Biblioteca" e "Palestra" |
| 85 | **Ordine delle sezioni nella vista raggruppata**: la sezione di partenza per prima, le altre in ordine alfabetico; il riordino manuale resta un'eventuale aggiunta futura |
| 86 | **Preferite nella vista per sezione**: compaiono nel blocco "Preferite" in cima e anche nella loro sezione |
| 87 | **Ricerca su tutti i campi**: nome della tessera, intestatario, note e nome del negozio |
| 88 | **Database con Drift** (libreria Flutter per SQLite) e migrazioni a passi: numero di versione dello schema, passaggi in ordine dentro una transazione, copia di sicurezza del database prima di migrare, prove su database di esempio di ogni versione rilasciata; il file di condivisione ha il suo numero di versione (più vecchio: convertito; più nuovo: rifiutato con invito ad aggiornare; campi sconosciuti ignorati) |
| 89 | **Scorciatoia in Home invece del widget** (sostituisce nella forma le decisioni 54 e 59): un'icona sulla schermata iniziale, con nome e logo della tessera, che apre direttamente quella tessera; se ne possono aggiungere quante si vuole; non è la stessa cosa delle preferite. Si realizza con le scorciatoie fissate di Android, non con un widget vero e proprio |
| 90 | **Scorciatoia in Home: dettagli**: su Android 7.x la funzione è nascosta; se la tessera collegata è nel cestino o eliminata, il tocco apre un pannello che lo comunica e offre di ripristinarla (se è nel cestino) o di eliminare la scorciatoia |
| 91 | **Orientamento**: app bloccata in verticale; eccezione nella schermata della tessera, dove un tocco sul codice lo ingrandisce a tutto schermo, anche in orizzontale |
| 92 | **Dimensione dei file di condivisione**: nessun tetto; se il file supera una soglia (circa 20 MB, da tarare) l'app lo segnala nella schermata di esportazione e l'utente decide se continuare; nessun avviso per "Esporta tutto". Il formato resta un archivio compresso con descrittore JSON e foto come file separati (le foto non si incorporano in Base64: non riducono il peso) |
| 93 | **Backup**: l'app non usa il cloud e non ne ha bisogno, ma il backup automatico di Android resta attivo (database e foto), così funziona liberamente per chi lo ha acceso sul proprio account Google; in più c'è sempre l'esportazione manuale ("Esporta tutto") su Drive, SD o altro, per avere i dati in mano anche se il backup di Google è disattivato. Lo stato dell'acquisto non viene salvato nel backup: si ricontrolla con Google Play. Da fare: informativa e dichiarazione di Play Console aggiornate, e verifica del limite di spazio del backup di Android (circa 25 MB per app) con molte foto |
| 94 | **Accessibilità (livello minimo)**: testo che segue la dimensione scelta nel telefono, con schermate che reggono caratteri molto grandi; etichette di lettura per il lettore di schermo su pulsanti e tessere (nel codice a barre: "codice della tessera <nome>"); contrasto sufficiente nei due temi, da controllare sulle videate |
| 95 | **Annunci, dettagli**: solo banner adattivi, senza video a riproduzione automatica; categorie bloccate in AdMob: giochi d'azzardo e scommesse, contenuti per adulti, prestiti e finanza ad alto rischio, annunci politici (modificabili dal pannello senza aggiornare l'app); se l'utente nega il consenso (EEA) si mostrano banner non personalizzati, con la voce "Gestisci consenso annunci" sempre presente nelle impostazioni; nella schermata della tessera il codice è disegnato per primo e il banner entra in uno spazio già riservato, senza mai spostarlo o ridurlo |
| 96 | **Arresti anomali e statistiche**: nessuno strumento di raccolta dentro l'app; ci si affida ai dati diagnostici che Play Console fornisce da sola |
| 97 | **Prove automatiche**: prove sulla logica dei dati (limite, importazione e unione, riconoscimento sezioni, cestino, migrazioni, lettura dei file di condivisione) e uno o due controlli di base sulle schermate; il resto dell'interfaccia si prova a mano. Le prove girano anche nella pipeline di GitHub (GitHub Actions) a ogni invio di modifiche, così non dipendono dalla memoria dello sviluppatore |
| 98 | **Nome della versione a pagamento: "Pro"** (identificativo del prodotto sullo store: `facilecards_pro`, da non cambiare più una volta creato). Nessun limite di tessere (il limite è la memoria del telefono) e nessun annuncio |
| 99 | **Avvertenza sui marchi**: stessa frase in tre lingue, ovunque compaiano nomi di catene: scheda di Google Play (in fondo alla descrizione), impostazioni dell'app (voce "Informazioni") e piè di pagina di ogni pagina del sito, informativa compresa. IT: "FacileCards è un'app indipendente e non è affiliata, sponsorizzata né approvata dalle aziende citate. I nomi e i marchi appartengono ai rispettivi proprietari." EN: "FacileCards is an independent app and is not affiliated with, sponsored by or endorsed by the companies mentioned. All names and trademarks belong to their respective owners." FR: "FacileCards est une application indépendante, non affiliée, sponsorisée ni approuvée par les entreprises citées. Les noms et marques appartiennent à leurs propriétaires respectifs." |
| 100 | **Scansione**: fotocamera a tutto schermo con cornice, torcia, lettura anche da un'immagine della galleria e inserimento a mano; si ferma al primo codice riconosciuto (nessuna scelta se ce ne sono più di uno); il permesso della fotocamera si chiede al primo tocco su "Scansiona", non all'avvio; se negato, schermata con "Apri impostazioni", "Inserisci a mano" e lettura da galleria (che non richiede il permesso) |
| 101 | **Foto della tessera**: nella scheda della tessera, al posto del pulsante "Foto tessera", la miniatura della foto del fronte; toccandola si apre la foto a tutto schermo, con scorrimento a destra e a sinistra tra fronte e retro, zoom con due dita e tocco singolo per chiudere. Una barra fissa in basso permette di sostituire o eliminare la foto mostrata (con conferma per l'eliminazione). Se manca la foto del fronte, al posto della miniatura c'è il pulsante "Aggiungi foto" per acquisire fronte e retro; se manca solo il retro, la pagina del retro offre "Aggiungi foto" |
| 102 | **Importa tutto**: dopo la scelta del file, riepilogo dell'archivio (sezioni, tessere, data); due modi: "Unisci alle tessere esistenti" (consigliato; aggiunge solo ciò che manca, riconosciuto dall'identificativo, quindi nessun duplicato dopo un ripristino del backup di Android) e "Sostituisci tutto" (le tessere attuali vanno nel cestino per 30 giorni); il risultato sul limite è mostrato prima di importare e, se si supera il limite, il pulsante è disattivato con invito a Pro; "Sostituisci tutto" richiede una seconda conferma con i numeri ("sostituire 13 tessere con 41") |
| 103 | **Password facoltativa sui file di condivisione** (sezione, tessera singola, "Esporta tutto"): mai obbligatoria. Se impostata, dati e foto sono cifrati (AES-256) con una chiave ricavata dalla password; l'intestazione del file (versione del formato, indicatore "cifrato", parametri di derivazione della chiave, data di creazione) resta in chiaro: serve a chiedere la password solo quando serve e a distinguere un file protetto da uno rovinato; nomi, codici, intestatari, note e foto, compresi il nome della sezione e il numero di tessere, sono nella parte cifrata. Chi riceve un file protetto non può aprirlo senza password (il pulsante resta disattivato a campo vuoto). Nessun recupero se la si dimentica (avvertenza nella schermata). Nessuna cifratura con chiave interna all'app, che non proteggerebbe davvero. All'importazione la password errata si può ritentare senza limiti. I testi non citano la presenza di altri intestatari |
| 104 | **Eliminazione di una sezione**: "Generale" non si elimina; dal menu della sezione (Condividi, Rinomina, Elimina sezione). Se contiene tessere, si sceglie se spostarle in un'altra sezione (predefinita Generale) o eliminarle con la sezione (cestino 30 giorni); il risultato è scritto prima della conferma. Una sezione vuota si elimina con una sola conferma. Il nome della sezione eliminata torna libero; recuperando dal cestino una tessera di una sezione eliminata, la sezione viene ricreata, e se il nome è stato riusato la tessera va nella sezione che lo porta |
| 105 | **Consenso agli annunci**: al primo avvio (dopo la configurazione iniziale e prima della prima schermata) una schermata nostra ("FacileCards è gratuita grazie agli annunci", e che senza consenso si vedono comunque annunci, ma non personalizzati), poi la finestra standard di Google (UMP) nello Spazio economico europeo, nel Regno Unito e in Svizzera; altrove non compare. La voce "Gestisci consenso annunci" nelle impostazioni la riapre |
| 106 | **Versione Pro nell'interfaccia**: l'acquisto si ritrova da solo cambiando telefono (stesso account Google; l'app lo controlla con Google Play all'avvio, e non carica gli annunci finché il controllo non è finito); "Ripristina acquisto" resta come ripiego nel riquadro della versione gratuita; con Pro: riquadro "Pro attivo", nessun banner e nessuna voce sul consenso agli annunci, il codice a barre non si ingrandisce; pagamento non ancora confermato: avviso "Acquisto in elaborazione" |
| 107 | **Importazione di una singola tessera**: stessa videata dell'importazione di una sezione; si sceglie la sezione di destinazione (predefinita "Generale") e si vede l'esito sul limite prima di importare |
| 108 | **Dominio e identificativo dell'app**: dominio `facilecards.eu` (registrato il 16 nov 2026); identificativo Android (applicationId) `eu.facilecards.app`, modificabile solo fino al primo caricamento su Google Play |
| 109 | **Repository unico e privato**: app, sito e documenti stanno in un solo repository privato, con la cronologia ripartita da zero il 16 nov 2026. Una sola pipeline (`.github/workflows/ci.yml`: analisi e test dell'app, attiva solo quando cambia `app/`); nessuna pipeline per il sito, che per ora non si pubblica. Prima dell'invio a Google Play l'informativa deve però essere online a un indirizzo pubblico: l'hosting si sceglie allora (GitHub Pages da repository privato richiede un piano a pagamento; da verificare le alternative gratuite). `CLAUDE.md` nella radice tiene traccia del da fare |
| 110 | **Lettura da galleria nella videata 8** (modifica la decisione 100, chiesta da Fabio il 17 nov 2026): sotto il campo Codice due pulsanti affiancati, "Scansiona" (principale) e "Da galleria". Dalla galleria si legge senza aprire la fotocamera e senza chiederne il permesso; vale lo stesso controllo del formato atteso (decisione 82). La schermata della fotocamera (22) tiene solo torcia e "Inserisci il codice a mano", che resta un ripiego; la videata 24 (fotocamera non consentita) tiene anche la lettura da galleria |
| 111 | **Numerazione delle versioni** (17 nov 2026): un solo punto, la riga `version: X.Y.Z+N` di `app/pubspec.yaml`, valida per Google Play e, in futuro, per l'App Store. `X.Y.Z` è la versione vista dagli utenti (correzioni: Z; funzioni nuove: Y; cambi grossi: X), uguale sulle due piattaforme a parità di funzioni. `N` è il numero di build: sale di 1 a ogni file caricato su uno store, test chiusi compresi, e non si riusa mai (un solo contatore per i due store). Ogni caricamento ha un'etichetta git `vX.Y.Z+N`; per ogni rilascio si annota la versione dello schema del database e si conserva un database di esempio (decisione 88) |
| 112 | **Dove si salva "Esporta tutto"** (18 nov 2026, richiesta di Fabio): "Salva sul telefono" apre il selettore di Android ("Salva in…"), così si sceglie la cartella, anche Drive o scheda SD; l'app ricorda dove si è salvato l'ultima volta e riapre il selettore lì (da Android 8; su Android 7 parte dalla posizione predefinita). Nome proposto: `FacileCards-AAAA-MM-GG.facilecards` |
| 113 | **Sezione già ricevuta: proposto "Sostituisci"** (18 nov 2026, richiesta di Fabio): nella videata 11, se la sezione del file è già stata ricevuta (decisione 79), la scelta proposta è "Sostituisci «nome»" invece di "Nuova sezione", perché chi la riceve di nuovo di solito vuole l'aggiornamento. Le altre due scelte restano disponibili; "Nuova sezione" mostra il campo del nome solo quando è scelta |
| 114 | **Menu dell'elenco: "Sezioni" e "Dati"** (18 nov 2026, richiesta di Fabio): la voce "Sezioni e cestino" del menu ⋮ si divide in due. "Sezioni" (videata 12) gestisce solo le sezioni: nuova, condividi (pulsante sulla riga e nel menu della sezione), rinomina, elimina. "Dati" (videata 12b) raccoglie Esporta tutto, Importa da file, il promemoria "Ultima copia" e il Cestino. Nei disegni e nell'app l'icona di condivisione è quella di Android (tre pallini collegati), non il quadrato con la freccia |
| 115 | **Inglese dell'app** (18 nov 2026): inglese britannico ("favourites", "bin" per il cestino), date con giorno e mese all'europea ("31 December 2027"), prezzo scritto "€2.00"; il mercato è europeo. In francese lo zero vuole il singolare ("0 carte") |
| 116 | **Account Google per Play Console e AdMob** (18 nov 2026, Fabio): si usa l'account personale di Fabio, lo stesso per i due servizi, con verifica in due passaggi. Sostituisce il consiglio di un account dedicato (sezione 8), che serviva solo in caso di passaggio del progetto ad altri |
| 117 | **Hosting del sito** (19 nov 2026, Fabio; completa la decisione 109): il sito si pubblica sull'hosting statico di Porkbun, dove è registrato il dominio `facilecards.eu`. Una pipeline del repository invia la cartella `site/` a ogni sua modifica; il repository resta privato. Scartate GitHub Pages da un repository pubblico a parte e le alternative gratuite (Cloudflare Pages, Netlify) |
| 118 | **App per pagare dalla tessera** (19 nov 2026, richiesta di Fabio): nella scheda della tessera, nella fascia in alto a destra del nome, un pulsante con l'icona e il nome di un'app scelta dall'utente (per esempio Satispay o Google Wallet), per passare al pagamento senza uscire da FacileCards e cercare l'app. Per ora una sola app. Si sceglie nella configurazione iniziale (facoltativa; se sul telefono c'è Satispay viene proposta) e nelle impostazioni, da una schermata con "Nessuna", le app per pagare presenti sul telefono e le altre app (videata 46). Con "Nessuna", o se l'app scelta è stata disinstallata, il pulsante non compare. L'elenco delle app installate si legge solo sul telefono e non viene trasmesso |

## 3. Requisiti funzionali

**Tessere**
- Ogni tessera = tipologia dal catalogo + codice + nome (modificabile).
- Inserimento del codice a mano o con scansione dalla fotocamera (presente fin dalla prima versione); la scansione rileva anche il formato del codice.
- Visualizzazione con logo e colore della tipologia e codice (a barre / QR) generato dall'app.
- Per ogni tessera si registrano data di inserimento e data di ultimo utilizzo.
- Su qualunque tessera si possono aggiungere, facoltativamente, le foto di fronte e retro.
- Dati facoltativi: note, intestatario, data di scadenza. L'intestatario è precompilato con il nominativo indicato nella configurazione iniziale e resta modificabile.
- Se l'avviso scadenze è attivo, le tessere scadute o entro i giorni di preavviso impostati sono segnalate da una campanella con indicatore nella schermata principale; toccandola si espande l'elenco con i dettagli. Nessuna notifica di sistema. Le tessere restano comunque utilizzabili.

**Tessera Generica**
- Per le tessere non presenti in catalogo: codice (con il suo formato) e foto del fronte, entrambi obbligatori; foto del retro facoltativa.

**Configurazione iniziale**
- Al primo avvio l'app pone tre sole domande:
  1. **Nominativo dell'intestatario**, usato come valore proposto per le nuove tessere.
  2. **Lingua**, preimpostata su quella del telefono.
  3. **Avviso scadenze**: attivo o no, e con quanti giorni di preavviso (preimpostato: attivo, 30 giorni).
- Gli stessi valori restano modificabili dalle impostazioni **(ipotesi)**.

**Catalogo**
- Contiene tessere fedeltà e altre tessere il cui uso consiste nel mostrare un codice (biblioteca, palestra…).
- Le tipologie iniziali vengono preparate in questo progetto; le successive arrivano dalle richieste degli utenti via email e vengono pubblicate con le nuove versioni dell'app.
- Una tipologia può essere **ritirata** (il gestore ha dismesso la tessera) o **sostituita** da una nuova versione: l'aggiornamento dell'app porta con sé la scadenza. Le tessere esistenti di quella tipologia restano utilizzabili e modificabili, con un segnale di avviso sull'icona che, toccato, apre la spiegazione; non se ne possono creare di nuove.
- Per biblioteche, palestre e simili esistono tipologie "di categoria", con icona propria e nome scelto dall'utente.
- I nomi delle tipologie sono marchi e non si traducono.

**Sezioni**
- Create liberamente; "Default" sempre presente.
- Spostamento delle tessere tra sezioni.
- Eliminazione solo se vuota, oppure con conferma esplicita di eliminazione di tutte le tessere contenute.
- Il nome è sempre modificabile, anche per le sezioni importate.
- Due sezioni non possono avere lo stesso nome: il controllo vale in creazione, rinomina e importazione.
- Nella vista raggruppata: Default per prima, poi le altre in ordine alfabetico **(proposta)**.

**Condivisione**
- *Esporta*: da una sezione, o da una singola tessera, si genera un file che passa al pannello di condivisione di Android (WhatsApp, email, Drive, Bluetooth…), accompagnato da un breve messaggio con il nome dell'app e il link allo store, così chi non ha FacileCards sa come aprirlo.
- *Doppia conferma prima dell'esportazione* (vale anche per "Esporta tutto", con testo adattato):
  1. **Avviso**: cosa sta per essere condiviso (sezione o tessera, numero di tessere) e cosa significa: chi riceve il file può usare le tessere, vede codici, intestatario, note e foto, e può a sua volta inoltrarlo; una volta inviato, non si può ritirare.
  2. **Conferma esplicita**: un secondo passaggio distinto dal primo (per esempio una casella "Ho capito" da spuntare prima che il pulsante "Condividi" si attivi), così non basta toccare due volte nello stesso punto.
- *Importa*: basta toccare il file ricevuto e scegliere FacileCards; in alternativa, dall'app, comando "Importa" con selezione del file. FacileCards mostra un'anteprima (nome della sezione, numero di tessere) e chiede dove metterle:
  - **nuova sezione**: nome proposto quello originale, modificabile, rifiutato se già in uso;
  - **unione in una sezione esistente**: vengono aggiunte solo le tessere non già presenti (stessa tipologia e stesso codice);
  - **sostituzione**: disponibile quando il file è una nuova versione di una sezione già ricevuta; le tessere della copia precedente vengono rimpiazzate da quelle del file.
- Un file con una singola tessera si importa scegliendo la sezione in cui inserirla.
- Prima di procedere l'app calcola quante tessere resterebbero a operazione conclusa e, nella versione gratuita, rifiuta se superano 50.
- Le tessere importate diventano a tutti gli effetti tessere del destinatario: modificabili, spostabili, eliminabili, riesportabili.
- Nessun collegamento resta tra la copia di chi invia e quella di chi riceve.

**Eliminazione e cestino**
- Una tessera si elimina trascinando la sua riga verso sinistra nell'elenco, oppure con il pulsante cestino dentro la tessera.
- A ogni eliminazione l'app chiede: "eliminare definitivamente?". Sì: la tessera e le sue foto sono cancellate subito. No: la tessera va nel cestino.
- Dal cestino si recupera entro 30 giorni; poi la cancellazione diventa definitiva.
- Le tessere nel cestino non compaiono nell'elenco e non vengono esportate, né nella condivisione né nel backup.
- Non contano nel limite di 50.
- Al recupero l'utente sceglie la sezione di destinazione; quella proposta è la sezione d'origine. Se era stata eliminata, scegliendola viene ricreata con il suo nome.
- Nella versione gratuita il recupero è bloccato se si è già a 50 tessere.

**Backup**
- *Esporta tutto*: un unico file con tutte le sezioni e le tessere, passato al pannello di condivisione; l'utente lo salva dove preferisce (Google Drive, email a sé stesso…).
- *Importa tutto*: ripristina da quel file. L'app chiede se **azzerare e importare** (il contenuto attuale viene sostituito da quello del file) oppure **unire** (le sezioni del file vengono aggiunte o completate, inserendo solo le tessere non già presenti per tipologia e codice).

**Limite e versione a pagamento**
- Gratuita: a 50 tessere la creazione è bloccata, con invito all'acquisto. Importazione e recupero dal cestino sono tutto-o-niente: l'app calcola quante tessere resterebbero a operazione conclusa e rifiuta se superano 50, indicando di quante si sfora.
- A pagamento: acquisto in-app una tantum di 2 € che toglie annunci e limite.

**Annunci (versione gratuita)**
- Banner al piede dell'elenco iniziale.
- Banner al piede della schermata della singola tessera.

## 4. Modello dati (locale)

```
Section ──< Card >── CardType   (catalogo, inclusa la "Generica")
              └──< CardImage    (fronte / retro, facoltative)
Settings                        (nominativo, lingua, tema, avviso scadenze e giorni, ordinamento, modalità elenco, stato dell'acquisto in cache)
```

- **CardType** — identificativo stabile, nome, logo, colore, formato del codice (EAN-13, Code 128, Code 39, ITF, QR, PDF417, Aztec, Data Matrix…), regole di validazione, categoria (fedeltà, biblioteca, palestra, altro), paese, flag `isGeneric`, stato (attiva / ritirata), data di scadenza, eventuale tipologia che la sostituisce e indicazione se la sostituzione richiede un nuovo codice.
- **Card** — identificativo univoco (UUID), tipologia, nome, codice, formato (per le generiche), note, intestatario, data di scadenza (tutti facoltativi), sezione, data di inserimento, data di ultimo utilizzo, indicatore di preferita, data di eliminazione (valorizzata se è nel cestino).
- **CardImage** — tessera, lato, file nello spazio privato dell'app.
- **Section** — identificativo univoco (UUID), nome (univoco), flag `isDefault`. Una sezione eliminata che ha ancora tessere nel cestino resta registrata, nascosta, finché quelle tessere non vengono recuperate o cancellate.

Gli identificativi univoci servono alla condivisione: permettono di riconoscere, a una seconda importazione, che una sezione o una tessera era già stata ricevuta.

## 5. Architettura

```
┌─────────────────────────────────────────────┐
│ App Flutter (Android)                       │
│  - database locale SQLite                   │
│  - foto nello spazio privato dell'app       │
│  - catalogo incluso nel pacchetto           │
│  - generazione dei codici sul dispositivo   │
│  - esporta / importa file di sezione        │
│  - annunci (AdMob) e acquisto (Google Play) │
└─────────────────────────────────────────────┘
```

Non esistono componenti lato server. Gli unici servizi esterni sono quelli di Google per annunci e acquisto.

### 5.1 Velocità

- La lista si disegna dal database locale; nessuna attesa di rete in nessun caso.
- I codici sono generati sul dispositivo.
- L'SDK degli annunci è inizializzato **dopo** il primo frame; il banner si carica in modo asincrono e non blocca mai la comparsa di elenco o tessera.
- Lo spazio del banner è riservato in anticipo, così l'arrivo dell'annuncio non sposta il contenuto.
- Aprendo una tessera: luminosità al massimo, schermo sempre acceso.
- **Obiettivo misurabile**: tessera a schermo entro 2 secondi dall'avvio a freddo, misurato su un telefono di fascia media.
- L'app si apre sempre sull'elenco. Acceleratori: ricerca per nome in cima all'elenco, ordinamenti, tessere preferite (mostrate in cima, prima delle altre).
- **Widget**: sulla schermata iniziale del telefono si possono mettere uno o più widget, ciascuno collegato a una tessera. Mostra logo e nome, non il codice (sarebbe piccolo e visibile a chiunque); il tocco apre l'app direttamente su quella tessera, saltando l'elenco. È il percorso più rapido in assoluto.
- Senza rete l'app funziona per intero; semplicemente non mostra annunci.

### 5.2 File di condivisione (proposta)

- Un unico file con estensione propria (es. `.facilecards`): archivio compresso contenente un descrittore JSON (versione del formato, sezione, tessere) e le eventuali foto.
- Lo stesso formato serve per una sezione intera, per una singola tessera e per il backup completo; il descrittore indica di quale dei tre casi si tratta.
- **Apertura del file.** L'app si registra su Android come destinataria di quel tipo di file, così toccandolo in WhatsApp compare "Apri con FacileCards". Android però riconosce i file dal tipo dichiarato dall'app che li invia, non dall'estensione, e per un formato sconosciuto WhatsApp e altre app dichiarano un tipo generico: FacileCards potrebbe quindi comparire tra le app proposte anche per file che non la riguardano, oppure non comparire con alcune app. Per questo esistono sempre due vie di riserva: "Condividi con → FacileCards" e il comando "Importa" dentro l'app, con selezione del file. Il comportamento reale con WhatsApp, Gmail e Drive va provato presto su un prototipo.
- **Messaggio di accompagnamento.** All'esportazione l'app allega al file un testo nella lingua di chi invia: nome dell'app, cosa contiene il file, link allo store.
- Il file contiene, per ogni tessera: identificativo, tipologia (per identificativo stabile del catalogo), nome, codice, formato, intestatario, scadenza, note, foto. **Non** contiene data di ultimo utilizzo e indicatore di preferita, che sono personali.
- Numero di versione nel formato, per poter evolvere senza rompere i file già in circolazione.
- All'importazione il file è trattato come contenuto non fidato: limiti su dimensione, numero di tessere e peso delle immagini, validazione di ogni campo.
- Se il file cita una tipologia che il catalogo del destinatario non ha (app non aggiornata), la tessera viene importata come Generica con il suo codice.
- Il file di backup usa lo stesso formato, con più sezioni e con le date di inserimento e di ultimo utilizzo, perché torna al suo stesso proprietario **(proposta)**.
- Le tessere nel cestino sono sempre escluse.

### 5.3 Catalogo

Il catalogo è un file di dati nel sorgente (con colore e iniziali di ogni catena, senza loghi reali), incluso nel pacchetto e aggiornato solo con le nuove versioni dell'app.

- Gli identificativi delle tipologie non cambiano mai e non vengono mai riutilizzati: le tessere degli utenti e i file condivisi vi fanno riferimento.
- Una tipologia ritirata **non viene cancellata** dal catalogo: resta con stato "ritirata", così le tessere esistenti continuano a mostrare logo e nome. Non è più proposta per le nuove tessere.
- Se è indicata una tipologia sostitutiva, l'app la propone all'utente. Il catalogo specifica per ogni sostituzione se il codice resta valido (la tessera cambia tipologia con una conferma) o se ne serve uno nuovo (l'utente lo inserisce o lo scansiona; la vecchia tessera resta finché non la elimina).
- A ogni avvio dopo un aggiornamento, l'app confronta le tessere con il catalogo e segnala quelle scadute.
- Le richieste di nuove tipologie arrivano a un indirizzo email dedicato, raggiungibile da una voce dell'app.

**Catalogo iniziale**

| Tipologia | Settore | Formato del codice | Logo e colore |
|---|---|---|---|
| Carrefour | Supermercati | da rilevare | da definire |
| Basko | Supermercati | da rilevare | da definire |
| PAM | Supermercati | da rilevare | da definire |
| Mercatò | Supermercati | da rilevare | da definire |
| Sapore di Mare | Surgelati | da rilevare | da definire |
| Acqua & Sapone | Casa e persona | da rilevare | da definire |
| Decathlon | Sport | da rilevare | da definire |
| Kiabi | Abbigliamento | da rilevare | da definire |
| Terranova | Abbigliamento | da rilevare | da definire |
| Calliope | Abbigliamento | da rilevare | da definire |
| Scarpe&Scarpe | Calzature | da rilevare | da definire |
| Biblioteca | Categoria | scelto dall'utente | icona |
| Palestra | Categoria | scelto dall'utente | icona |
| Tessera Generica | — | scelto dall'utente | neutro |

Il formato del codice non va ipotizzato: si rileva scansionando una tessera reale di ogni catena, cosa che la funzione di scansione dell'app farà comunque. Una stessa catena può avere tessere con formati diversi (plastica vecchia, app nuova): in quel caso la tipologia accetta più formati.

### 5.4 Versione a pagamento e Google Play

**Una sola app, non due.** Sullo store esiste un'unica scheda "FacileCards", scaricabile gratis. La versione a pagamento non è un'altra app: è un **acquisto in-app** che sblocca, dentro la stessa app, l'assenza di annunci e di limite. Due app separate (gratuita e "Pro") sono da evitare: due schede, due test chiusi, recensioni divise e, soprattutto, nessun modo di portare le tessere dall'una all'altra se non con un'esportazione manuale.

**Sullo store**

- In Play Console si crea un **prodotto una tantum** (non consumabile), con un identificativo fisso, per esempio `facilecards_pro`, e il prezzo di 2 €. Il prezzo si imposta per paese e si può cambiare in seguito senza aggiornare l'app.
- Per vendere serve il profilo pagamenti (sezione 8.2, punto 3).
- Nella scheda dell'app comparirà la dicitura "Acquisti in-app" accanto a "Contiene annunci".

**Nell'app**

1. L'utente tocca "Pro": l'app apre la finestra di acquisto di Google Play, che gestisce pagamento, ricevuta ed eventuale rimborso. L'app non vede mai i dati di pagamento.
2. A pagamento riuscito l'app riceve l'acquisto, **lo conferma a Google** e sblocca subito limite e annunci. La conferma è obbligatoria: un acquisto non confermato entro tre giorni viene rimborsato automaticamente.
3. Lo stato "Pro" viene salvato in locale, così agli avvii successivi l'app non deve attendere nulla (coerente con l'obiettivo di velocità).
4. A ogni avvio, in secondo piano e dopo aver mostrato l'elenco, l'app chiede a Google Play gli acquisti dell'account e riallinea lo stato salvato.

**Casi da gestire**

- **Nuovo telefono o reinstallazione.** L'acquisto è legato all'account Google: con lo stesso account viene ritrovato al primo controllo. Serve comunque una voce "Ripristina acquisto" nelle impostazioni, per forzare il controllo.
- **Pagamento in sospeso.** Alcuni metodi di pagamento si completano dopo ore o giorni: l'acquisto arriva come "in attesa" e lo sblocco avviene solo quando diventa effettivo.
- **Rimborso o revoca.** Al controllo successivo l'acquisto non risulta più e l'app torna gratuita. Se nel frattempo le tessere sono più di 50: restano tutte, ma non se ne possono aggiungere (**proposta**, domanda A2).
- **Telefono senza rete.** Vale lo stato salvato in locale.
- **Acquisto già posseduto.** Se l'utente tocca "acquista" avendo già comprato, Google lo segnala: l'app deve semplicemente sbloccare.
- **Famiglia.** L'acquisto vale per un account Google: ogni familiare che vuole la versione Pro la compra per sé (da verificare se la condivisione in famiglia di Google Play si applica agli acquisti in-app; di norma no).

**Quanto resta dei 2 €.** Il prezzo è comprensivo di IVA, che Google trattiene e versa. Sul resto Google applica la propria commissione: per i piccoli sviluppatori nell'Unione Europea, dal 30 giugno 2026, è nell'ordine del 15% (10% di commissione di servizio più la tariffa di fatturazione). Indicativamente restano circa 1,40 € per vendita, prima delle imposte sul reddito. Cifre da verificare in Play Console.

**Sviluppo e prova**

- Libreria Flutter ufficiale: `in_app_purchase`.
- In Play Console si indicano i "tester delle licenze": i loro acquisti di prova non vengono addebitati. Gli acquisti si possono provare già nel test chiuso.
- La verifica avviene sul dispositivo: senza un server è aggirabile da chi modifica l'app. Per un prodotto da 2 € è un rischio accettabile.

### 5.5 Backup e cambio telefono

Senza cloud, i dati esistono solo sul dispositivo: telefono perso, rotto o sostituito significa tessere perse, salvo contromisure.

- **Backup automatico di Android**: salva i dati dell'app nell'account Google dell'utente e li ripristina su un nuovo dispositivo, senza nostro intervento. Ha un limite di spazio per app (circa 25 MB, da verificare), sufficiente per i dati ma non per molte foto di tessere generiche.
- **Esporta tutto / Importa tutto**: lo stesso meccanismo del file di sezione, esteso a tutte le sezioni in un unico file che l'utente salva dove vuole tramite il pannello di condivisione. Copre anche il passaggio futuro da Android a iOS. Non è automatico: protegge solo chi si ricorda di farlo, quindi conviene un promemoria discreto nell'app.

### 5.6 Localizzazione

- Tutti i testi dell'interfaccia stanno in file di traduzione, uno per lingua (meccanismo standard di Flutter): nessun testo scritto nel codice.
- Lingue al lancio: italiano, inglese, francese. Aggiungere spagnolo o tedesco significa aggiungere un file.
- La lingua è scelta nella configurazione iniziale e modificabile dalle impostazioni; il valore proposto è quello del telefono, o l'inglese se la lingua del telefono non è tra quelle previste **(proposta)**.
- Date e numeri formattati secondo la lingua.
- Vanno tradotti anche scheda sullo store, informativa sulla privacy e messaggio di consenso agli annunci.

### 5.7 Google Wallet (non previsto nella prima versione)

Tecnicamente un'app può aggiungere una tessera a Google Wallet con il pulsante "Aggiungi a Google Wallet". Per farlo serve:

- un **account emittente** nella console Google Pay & Wallet, con un profilo da far approvare a Google per uscire dalla modalità di prova;
- un **modello di tessera** (di tipo generico o fedeltà) definito una volta dallo sviluppatore;
- per ogni tessera dell'utente, un **oggetto** creato dall'app e passato a Wallet.

Con la libreria Android di Google l'app può farlo senza un nostro server: la richiesta è autenticata dall'impronta della firma dell'app. La via alternativa, tramite servizio web, richiede invece una chiave privata che non può stare dentro un'app e quindi un backend.

Motivi per non farlo ora:

- **I dati escono dal telefono.** La tessera finirebbe sui server di Google, associata al nostro account emittente: contraddice "tutto resta sul dispositivo", che è la promessa del progetto e dell'informativa.
- **Diventeremmo emittenti di tessere altrui.** Le tessere porterebbero nome e colori di catene che non rappresentiamo; va verificato se le regole di Google lo consentono.
- **Wallet lo fa già da solo.** L'utente può aggiungere una tessera fedeltà direttamente in Google Wallet: chi lo preferisce non ha bisogno di noi.
- **Non serve all'obiettivo.** Il percorso veloce lo danno già widget e avvio rapido.

Se in futuro lo si volesse, la forma più sensata è un comando facoltativo sulla singola tessera, con un avviso chiaro che i dati vengono inviati a Google.

## 6. Punti di attenzione

1. **Banner nella schermata della tessera.** È il momento in cui l'utente porge il telefono alla cassa: il banner non deve rubare luminosità né spazio al codice, e va tenuto ben separato da esso per evitare tocchi accidentali, che le regole di AdMob penalizzano. Il codice deve restare il contenuto dominante della schermata.
2. **Tessere di una tipologia ritirata.** Restano utilizzabili e modificabili con un avviso, perché il gestore può ritirare la grafica ma accettare ancora il vecchio codice. La tipologia sparisce solo dall'elenco di scelta per le nuove tessere; anche l'importazione di un file che la contiene deve restare possibile.
3. **Il file contiene i codici in chiaro.** Chiunque ne entri in possesso può usare le tessere. È coerente con la scelta fatta (chi invia perde il controllo), ma l'app deve dirlo al momento dell'esportazione.
4. **Perdita dei dati.** Vedi 5.5: senza backup automatico o esportazione completa, un telefono perso azzera tutto.
5. **Privacy.** Non raccogliendo alcun dato, l'impianto GDPR si riduce molto. Restano obbligatori: informativa sulla privacy per lo store, dichiarazione dei dati trattati dall'SDK pubblicitario e raccolta del consenso agli annunci nello Spazio Economico Europeo tramite una piattaforma certificata.
6. **Marchi.** Il catalogo usa solo nomi di catene con iniziali su colore, non i loghi reali: il rischio è ridotto ma resta l'avvertenza di non affiliazione (C3).
7. **Dimensione dell'app.** Il catalogo è dentro il pacchetto: senza loghi reali pesa pochissimo.
8. **Leggibilità in cassa.** Alcuni scanner leggono male i codici lineari da schermo: dimensioni generose, contrasto pieno, codice in chiaro come ripiego.
9. **Tessere dinamiche.** Codici che cambiano o tessere solo in-app non sono gestibili e va detto chiaramente.
10. **iOS in futuro.** L'acquisto su Google Play non si trasferisce all'App Store: senza un nostro server, chi cambia piattaforma dovrà riacquistare. I file di sezione invece funzionano tra le due piattaforme.
11. **"Azzera e importa" è distruttivo.** Sostituisce tutto il contenuto del telefono: richiede una conferma esplicita. Le tessere rimosse vanno nel cestino, da cui sono recuperabili per 30 giorni.
12. **Unione di tessere uguali ma modificate.** Una tessera già presente non viene toccata: chi riceve un aggiornamento con un nome corretto non lo vedrà, a meno di usare "sostituisci". Va spiegato nella schermata di importazione.
13. **Test obbligatorio prima della pubblicazione.** Per gli account sviluppatore personali creati dopo il 13 novembre 2023, Google Play richiede un test chiuso con almeno 12 tester iscritti per 14 giorni consecutivi prima di poter pubblicare. Vanno trovate 12 persone con account Google disposte a installare e usare l'app (sezione 8.2).
14. **Dati personali visibili sullo store.** Vendendo un acquisto in-app e mostrando annunci, lo sviluppatore opera come venditore: per le regole europee nome e recapiti possono comparire nella scheda dell'app. Da verificare in fase di registrazione quali dati diventano pubblici, soprattutto l'indirizzo.
15. **Nome del proprietario del telefono.** Un'app Android non può leggerlo liberamente: servirebbe il permesso di accesso ai contatti o un accesso con account Google, entrambi in contrasto con un'app senza login e senza raccolta di dati. Per questo il nominativo viene chiesto nella configurazione iniziale.
16. **Condivisione consapevole.** Il file contiene codici, intestatario, note e foto, e non è ritirabile: per questo l'esportazione richiede una doppia conferma. Perché sia efficace il secondo passaggio deve richiedere un gesto diverso dal primo; due pulsanti "OK" in sequenza vengono toccati senza leggere.
17. **Aspetti fiscali.** Annunci e vendite producono redditi da dichiarare; se l'attività è continuativa può servire la partita IVA. Non sono un consulente fiscale: conviene sentire un commercialista prima della pubblicazione.
18. **Nome FacileCards.** Verificato dallo sviluppatore su Google Play e nei registri dei marchi senza trovare risultati (decisione 57). Resta l'esistenza di **PassFacile**, un'app italiana per esercenti che creano tessere fedeltà digitali: settore vicino e parola in comune, ma nome e pubblico diversi.

## 7. Ipotesi di percorso

| Fase | Contenuto |
|---|---|
| 0 — Preparazione | Installazione di Flutter (sezione 9), creazione del progetto in `app/`, prototipo della schermata tessera con lettura reale in cassa |
| 1 — Nucleo | Database locale, sezioni, tessere da catalogo e Generica, scansione, codice a barre a schermo, configurazione iniziale, localizzazione (it, en, fr), catalogo iniziale |
| 2 — Uso quotidiano | Ricerca, ordinamenti, due modalità di elenco, preferite, note / intestatario / scadenza con campanella, foto, tema, eliminazione e cestino |
| 3 — Condivisione | Formato del file, esportazione con doppia conferma, importazione con le tre destinazioni, esporta / importa tutto, prove con WhatsApp, Gmail e Drive |
| 4 — Pubblicazione | Sito e informativa, account Google Play e AdMob, annunci con consenso, acquisto in-app e limite di 50 tessere, tipologie ritirate, test chiuso (12 tester per 14 giorni), pubblicazione |
| 5 — Dopo il lancio | Scorciatoia in Home (decisione 89), nuove tipologie su richiesta, altre lingue, iOS |

La scorciatoia in Home è nella fase 5 solo per mettere prima l'essenziale: è una funzione piccola e può essere anticipata alla fase 4 senza spostare il lancio in modo sensibile.

## 8. Account, annunci e pubblicazione

Servono tre cose, tutte gratuite tranne la registrazione a Google Play: un piccolo sito, un account Google Play Console e un account AdMob. Si usa **lo stesso account Google** per Play Console e AdMob: quello personale di Fabio (chiarito il 18 nov 2026, decisione 116). Un account dedicato servirebbe solo se il progetto dovesse passare a qualcun altro; in quel caso le app si trasferiscono comunque a un altro account sviluppatore (vedi 8.2, punto 1).

Le regole di Google cambiano spesso: le pagine ufficiali indicate in fondo fanno fede rispetto a questo riepilogo.

### 8.1 Perché AdMob

Per un'app Flutter su Android è la scelta naturale: è il servizio di Google per gli annunci nelle app, ha un plugin Flutter ufficiale (`google_mobile_ads`), gestisce il consenso europeo con un proprio strumento certificato e non ha costi né soglie minime di traffico. Alternative (Meta Audience Network, Unity Ads, AppLovin) sono orientate ai giochi e avrebbero senso solo in un secondo momento, come fonti aggiuntive dentro AdMob.

Nota sui nomi: **Google Ads** è il servizio con cui si *comprano* annunci; quello con cui si *guadagna* mostrandoli in un'app è **AdMob**.

### 8.2 Ordine consigliato

1. **Account Google.** Quello personale, con verifica in due passaggi attiva e un filtro per la posta di Google Play e AdMob (alcuni avvisi hanno una scadenza). Se un giorno servisse cambiare:
   - *Google Play*: l'account proprietario di norma non si cambia, ma le app si possono trasferire a un altro account sviluppatore (registrato e verificato, con la sua quota), conservando utenti e recensioni; si possono anche invitare altri utenti con permessi limitati.
   - *AdMob*: l'account non si trasferisce; si aggiungono altri utenti come amministratori, oppure si apre un account nuovo e si aggiornano nell'app gli identificativi degli annunci.
   - Indipendentemente dall'account, chi vende nell'Unione europea (l'acquisto Pro) deve mostrare sulla scheda dello store nome, indirizzo, email e telefono di contatto.
2. **Sito del progetto.** Una o due pagine statiche: servono per l'informativa sulla privacy (richiesta da Google Play) e per il file `app-ads.txt` (richiesto da AdMob, vedi punto 6). L'indirizzo va indicato come "sito web dello sviluppatore" nella scheda dello store.
   - *Sito statico gratuito* significa pagine HTML semplici, senza database né programmi lato server, ospitate da un servizio che non fa pagare per questo uso. È stato scelto **GitHub Pages**: il sito risponde a `https://facilecards.eu` (dettagli in 8.7).
   - `app-ads.txt` deve stare nella **radice** del sito: `https://facilecards.eu/app-ads.txt`.
   - L'unica alternativa a pagamento è un dominio proprio (es. `facilecards.app`), nell'ordine di 10–20 euro l'anno, collegabile allo stesso GitHub Pages anche in un secondo momento. Dà un indirizzo più presentabile ma non è necessario.
3. **Google Play Console** — account sviluppatore di tipo *personale*.
   - Registrazione su play.google.com/console, quota una tantum di 25 dollari.
   - Verifica dell'identità con documento, e di email e telefono di contatto.
   - Per vendere l'acquisto in-app va creato anche il profilo pagamenti (dati anagrafici e IBAN).
   - *Come capire se si ha già un account*: aprire play.google.com/console dopo aver effettuato l'accesso con il proprio account Google. Se compare la console con l'elenco delle app, l'account esiste; se compare la proposta di registrazione con la scelta tra "personale" e "organizzazione", non esiste. Va ripetuto per ogni account Google che si possiede.
   - *Come capire se serve il test con 12 tester*: la data di creazione coincide con quella della ricevuta dei 25 dollari, rintracciabile nella posta o su pay.google.com tra le attività. In ogni caso la console lo dice da sola: creando un'app, se il requisito si applica, la sezione "Produzione" resta bloccata e la pagina iniziale dell'app mostra l'avviso sul test chiuso.
4. **Test chiuso.** Con un account personale nuovo, prima di pubblicare bisogna tenere l'app in test chiuso con almeno 12 tester iscritti per 14 giorni consecutivi, poi chiedere l'accesso alla produzione. I 14 giorni partono solo quando i 12 tester sono iscritti, e Google valuta anche che l'app venga realmente usata: conviene iniziare a raccogliere i tester mentre lo sviluppo è ancora in corso.
5. **Account AdMob.**
   - Registrazione su apps.admob.com con lo stesso account Google; paese Italia, valuta euro (non modificabili in seguito con facilità).
   - Inserimento dei dati di pagamento: senza, l'account non viene verificato e le app restano in attesa.
   - L'approvazione dell'account richiede in genere un giorno, in rari casi fino a due settimane.
6. **Registrazione dell'app in AdMob.**
   - Si aggiunge l'app (all'inizio come "non pubblicata", per sviluppare e provare) e si ottiene l'**ID app**, da inserire nella configurazione Android.
   - Si creano due **unità pubblicitarie** di tipo banner: una per l'elenco iniziale, una per la schermata della tessera. Tenerle distinte permette di misurare quanto rende ciascuna.
   - Si pubblica sul sito il file `app-ads.txt` con la riga fornita da AdMob: serve a dimostrare la proprietà dell'app.
   - Quando l'app è sullo store la si collega in AdMob: parte una revisione, e solo dopo l'approvazione gli annunci vengono serviti a pieno regime.
7. **Messaggio di consenso europeo.** In AdMob, sezione "Privacy e messaggi", si crea il messaggio per il GDPR nelle tre lingue; nell'app lo mostra la libreria di Google per il consenso (UMP), che è già certificata. Senza una piattaforma di consenso certificata, in Europa vengono serviti solo annunci limitati, che rendono meno.

### 8.3 Regole da non violare mai

La sospensione dell'account AdMob per "attività non valida" è difficile da far revocare. Le cause tipiche:

- **Toccare i propri annunci**, anche una sola volta e anche per prova. Durante lo sviluppo si usano solo gli ID di test forniti da Google e si registrano i propri telefoni come dispositivi di test.
- **Chiedere ad amici e tester di toccare gli annunci.**
- **Annunci troppo vicini a elementi toccabili**, che provocano tocchi involontari. Riguarda da vicino il banner sotto la tessera: va tenuto staccato dal codice e dai pulsanti.
- **Annunci su schermate senza contenuto** (caricamento, errore, uscita).

### 8.4 Incassi

- I guadagni maturano mese per mese; il pagamento avviene con bonifico sul conto indicato, il mese successivo a quello in cui il saldo supera la soglia di pagamento.
- Raggiunta una prima soglia più bassa (circa 10 dollari o equivalente), Google chiede di verificare l'identità e spedisce per posta ordinaria un codice PIN all'indirizzo indicato: va inserito in AdMob entro 4 mesi, altrimenti gli annunci si fermano. La lettera può impiegare alcune settimane, quindi l'indirizzo deve essere esatto fin dall'inizio.
- Le vendite dell'acquisto in-app seguono un canale separato (profilo pagamenti di Google Play), con la commissione dello store trattenuta alla fonte.

### 8.5 Gestione ordinaria

- **Centro norme di AdMob**: da controllare periodicamente; le violazioni arrivano anche per email e hanno una scadenza per la correzione.
- **Aggiornare gli SDK** di annunci e acquisti: Google ne ritira le versioni vecchie e impone un livello minimo di Android per gli aggiornamenti dell'app.
- **Dichiarazioni su Google Play** (sicurezza dei dati, presenza di annunci, classificazione dei contenuti): vanno mantenute coerenti con ciò che l'app fa davvero.
- **Controllare il rendimento per unità pubblicitaria**: è il dato che dirà se il banner sotto la tessera vale il disturbo che crea.

### 8.6 Pagine ufficiali

- Guida introduttiva di AdMob: https://support.google.com/admob/answer/15948559
- Configurazione di un'app in AdMob: https://support.google.com/admob/answer/2773509
- Revisione dell'app e app-ads.txt: https://support.google.com/admob/answer/10564477
- Passaggi per ricevere i pagamenti: https://support.google.com/admob/answer/3001017
- Verifica dell'indirizzo con PIN: https://support.google.com/admob/answer/2772302
- Soglie di pagamento: https://support.google.com/admob/answer/2772208
- Consenso europeo in Flutter: https://developers.google.com/admob/flutter/privacy/gdpr
- Requisiti di test per account personali su Google Play: https://support.google.com/googleplay/android-developer/answer/14151465

### 8.7 Sito del progetto

**Indirizzo.** `https://facilecards.eu` (dominio registrato il 16 nov 2026; decisione 108). Il sito vive nella cartella `site/` del repository unico e privato (decisione 109) e si pubblica su Porkbun (decisione 117).

**Come si pubblica.** Hosting statico di Porkbun, dove è registrato il dominio (decisione 117). La pipeline `.github/workflows/site.yml` lancia `tools/deploy_site.py`, che invia la cartella `site/` con l'API di Porkbun a ogni sua modifica su `main` (chiavi nei segreti `PB_API_KEY` e `PB_SECRET_KEY` del repository). L'informativa deve essere online prima dell'invio a Google Play, e `app-ads.txt` deve stare nella radice del dominio.

**Struttura.** Pagine HTML statiche, nessuna compilazione:

```
site/
├── index.html          presentazione dell'app (italiano)
├── en.html, fr.html    presentazione in inglese e francese
├── privacy/
│   ├── index.html      informativa in italiano
│   ├── en.html         inglese
│   └── fr.html         francese
├── app-ads.txt         riga fornita da AdMob (nella radice)
├── assets/             stile, icona
└── README.md           appunti, non pubblicato
```

**Contenuto dell'informativa.** È breve perché l'app non raccoglie nulla: tessere, codici e foto restano sul dispositivo e non vengono trasmessi allo sviluppatore; la fotocamera serve solo a scansionare i codici e fotografare le tessere; gli annunci sono forniti da Google AdMob, che tratta identificatori del dispositivo secondo il consenso espresso; l'acquisto passa da Google Play; nome e contatto del titolare.

**Stato.**
- [x] File del sito preparati (presentazione e informativa in italiano, inglese, francese)
- [x] Dominio `facilecards.eu` acquistato
- [x] Titolare, contatto e data inseriti nell'informativa
- [ ] Scegliere dove pubblicare il sito (decisione 109) e collegare il dominio
- [ ] Far rileggere il testo dell'informativa
- [ ] Inserire in `app-ads.txt` la riga fornita da AdMob (dopo la creazione dell'account, punto 5 di 8.2)
- [ ] Indicare l'indirizzo del sito e quello dell'informativa nella scheda di Google Play
- [ ] Valutare un indirizzo e-mail sul dominio per il contatto dell'informativa e di Google Play

## 9. Installare Flutter su Mac

Guida per preparare il Mac ad aprire il progetto `app/` e provarlo su un emulatore Android. Riguarda solo macOS e solo lo sviluppo per Android: Xcode completo e gli strumenti per iOS non servono in questa fase.

I passi seguono la documentazione ufficiale di Flutter, consultata il 16 novembre 2026; versioni e nomi delle voci di menu possono cambiare, quindi in caso di differenze fanno fede le pagine indicate in 9.9.

### 9.1 Prima di iniziare

- **Tipo di processore.** Menu Apple → "Informazioni su questo Mac": alla voce "Chip" o "Processore" si legge se il Mac è Apple Silicon (M1, M2, M3…) o Intel. Serve per scegliere il pacchetto giusto. Flutter sta ritirando il supporto ai Mac Intel: le versioni future richiederanno Apple Silicon.
- **Spazio su disco.** Tra SDK di Flutter, Android Studio, SDK di Android e immagini dell'emulatore servono parecchi gigabyte: conviene averne liberi almeno 20 (stima prudente, non un requisito ufficiale).
- **Terminale.** Tutti i comandi vanno dati nell'app Terminale, con la shell predefinita di macOS (zsh).

### 9.2 Strumenti da riga di comando di Apple

Flutter usa Git, che su Mac arriva con gli strumenti da riga di comando di Xcode.

```
xcode-select --install
```

Se compare una finestra, scegliere "Installa" e attendere la fine. Se il comando risponde che gli strumenti sono già installati, si può proseguire.

### 9.3 SDK di Flutter

1. Aprire https://docs.flutter.dev/install/manual, scegliere macOS e scaricare il pacchetto adatto al processore (Apple Silicon oppure Intel). Il file ha un nome del tipo `flutter_macos_<versione>-stable.zip`.
2. Creare la cartella che ospiterà l'SDK ed estrarvi il pacchetto (adattare il nome del file a quello scaricato):

   ```
   mkdir -p ~/develop
   unzip ~/Downloads/flutter_macos_*-stable.zip -d ~/develop/
   ```

   L'SDK si troverà in `~/develop/flutter`. Non va messo in cartelle sincronizzate (iCloud, Dropbox) né in percorsi con spazi.
3. Rendere disponibile il comando `flutter` aggiungendo l'SDK al PATH. Aprire (o creare) il file `~/.zprofile` e aggiungere in fondo questa riga:

   ```
   export PATH="$HOME/develop/flutter/bin:$PATH"
   ```

   In alternativa, da Terminale:

   ```
   echo 'export PATH="$HOME/develop/flutter/bin:$PATH"' >> ~/.zprofile
   ```

4. Chiudere e riaprire il Terminale (e gli editor aperti), poi verificare:

   ```
   flutter --version
   dart --version
   ```

   Se uno dei due comandi "non viene trovato", il PATH non è stato applicato: controllare la riga in `~/.zprofile` e riaprire il Terminale.

### 9.4 Android Studio e SDK di Android

Android Studio serve anche se poi si scrive il codice con un altro editor: è il modo più semplice per installare l'SDK di Android e l'emulatore.

1. Scaricare l'ultima versione stabile da https://developer.android.com/studio (scegliendo la variante per il proprio processore), trascinarla in Applicazioni e avviarla.
2. Seguire la procedura guidata iniziale accettando le scelte proposte: scarica l'SDK di Android.
3. Aprire l'**SDK Manager**: dalla finestra di benvenuto "More Actions" → "SDK Manager" (con un progetto aperto: "Tools" → "SDK Manager").
4. Scheda **SDK Platforms**: selezionare la prima voce con **API Level 36** e, se non risulta installata, premere "Apply".
5. Scheda **SDK Tools**: verificare che siano selezionati, e in caso installarli con "Apply":
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
   - CMake
   - NDK (Side by side)
6. Accettare le licenze di Android da Terminale, rispondendo `y` a ogni richiesta:

   ```
   flutter doctor --android-licenses
   ```

   Alla fine deve comparire "All SDK package licenses accepted."

### 9.5 Emulatore Android

1. In Android Studio aprire il **Device Manager**: dalla finestra di benvenuto "More Actions" → "Virtual Device Manager" (con un progetto aperto: "Tools" → "Device Manager").
2. Premere "Create Virtual Device" (l'icona `+`).
3. Scegliere "Phone" e un modello, per esempio un Pixel recente; poi "Next".
4. Scegliere l'immagine di sistema: su Apple Silicon le **ARM Images**, su Intel le **x86 Images**. Se accanto alla versione di Android c'è l'icona di scaricamento, premerla e attendere.
5. In "Additional settings", sezione "Emulated Performance", impostare "Graphics acceleration" su una voce che contenga "Hardware".
6. Confermare con "Finish" e avviare l'emulatore con il pulsante di esecuzione accanto al suo nome.

Per FacileCards conviene creare due emulatori: un telefono di dimensioni medie e uno **piccolo**, per controllare che codice a barre e annuncio convivano anche sugli schermi ridotti.

### 9.6 Verifica complessiva

```
flutter doctor
```

Devono avere il segno di spunta le righe **Flutter**, **Android toolchain** e **Android Studio**. Gli avvisi su Xcode, CocoaPods e Chrome si possono ignorare: riguardano iOS e web.

```
flutter emulators
flutter devices
```

Il primo elenca gli emulatori creati; il secondo mostra quelli in esecuzione e i telefoni collegati. Deve comparire almeno una voce con piattaforma **android**.

### 9.7 Editor

Si può lavorare con uno dei due:

- **Visual Studio Code**: installare l'estensione "Flutter" (porta con sé quella di Dart). Il dispositivo si sceglie in basso a destra, l'app si avvia con F5.
- **Android Studio**: "Settings" → "Plugins", cercare "Flutter" e installarlo (installa anche Dart), poi riavviare.

L'estensione o il plugin non sostituiscono l'SDK: senza i passi di 9.3 il comando `flutter` non esiste.

### 9.8 Aprire e provare il progetto

Con l'emulatore avviato:

```
cd ~/Works/GitHub/FacileCards/FacileCard
flutter pub get
flutter run
```

- `flutter pub get` scarica le librerie del progetto; va ripetuto quando cambia `pubspec.yaml`.
- `flutter run` compila e installa l'app sull'emulatore. La prima compilazione richiede alcuni minuti, le successive molto meno.
- Con l'app in esecuzione, nel Terminale: `r` ricarica le modifiche al volo, `R` riavvia l'app, `q` la chiude.
- Se sono presenti più dispositivi: `flutter run -d <identificativo>`, con l'identificativo letto da `flutter devices`.
- Per avviare un emulatore senza aprire Android Studio: `flutter emulators --launch <identificativo>`.

**Telefono vero.** L'emulatore non basta per due aspetti centrali del progetto: la scansione con la fotocamera (quella dell'emulatore è simulata) e la misura dei tempi di avvio. Per provare su un telefono Android: attivare le "Opzioni sviluppatore" e il "Debug USB" sul telefono, collegarlo al Mac, autorizzare il computer quando richiesto e verificare con `flutter devices`.

### 9.9 Problemi frequenti e pagine ufficiali

| Sintomo | Rimedio |
|---|---|
| `flutter: command not found` | La riga del PATH manca o il Terminale non è stato riaperto (9.3) |
| `flutter doctor` segnala "cmdline-tools component is missing" | Installare "Android SDK Command-line Tools" dall'SDK Manager (9.4, punto 5) |
| `flutter doctor` segnala licenze non accettate | `flutter doctor --android-licenses` |
| `flutter doctor` non trova l'SDK di Android | Aprire Android Studio almeno una volta e completare la procedura guidata |
| L'emulatore è molto lento | Controllare immagine ARM su Apple Silicon e accelerazione grafica "Hardware" (9.5) |
| Nessun dispositivo in `flutter devices` | L'emulatore non è avviato, oppure il telefono non ha autorizzato il computer |

- Installazione manuale di Flutter: https://docs.flutter.dev/install/manual
- Configurazione di Android per Flutter: https://docs.flutter.dev/platform-integration/android/setup
- Risoluzione dei problemi: https://docs.flutter.dev/install/troubleshoot
- Android Studio: https://developer.android.com/studio

### 9.10 Versioni di Android del progetto

Un progetto Android dichiara tre livelli di API, nel file `android/app/build.gradle.kts`:

| Valore | Significato | Per FacileCards |
|---|---|---|
| `minSdk` | La versione più vecchia di Android su cui l'app si installa | **24** (Android 7.0) |
| `targetSdk` | La versione per cui l'app dichiara di essere stata provata; Google Play ne impone una recente | **36** (Android 16) |
| `compileSdk` | La versione dell'SDK usata per compilare | **36** |

- **Minimo 24.** È il limite inferiore di Flutter stesso: dalla versione 3.35 Flutter supporta Android dall'API 24 alla 36, e non funziona sulle precedenti. Non c'è motivo di alzarlo: più è basso, più telefoni vecchi restano serviti, e l'app non usa funzioni che richiedano versioni recenti.
- **Il minimo può salire per colpa delle librerie.** Annunci, acquisti in-app e scansione dei codici dichiarano ciascuna un proprio minimo: se una richiede più di 24, il progetto deve adeguarsi. Va verificato quando si aggiungono le dipendenze; `flutter run` segnala il conflitto in modo esplicito.
- **Target 36 obbligatorio.** Dal 31 agosto 2026 Google Play accetta nuove app e aggiornamenti solo se dichiarano come target Android 16 (API 36). Il requisito sale di un livello ogni anno, verso fine agosto: è una manutenzione ricorrente da mettere in conto.
- Un progetto creato con una versione recente di Flutter eredita questi valori dall'SDK (`flutter.minSdkVersion`, `flutter.targetSdkVersion`): di norma non vanno scritti a mano, basta tenere Flutter aggiornato.

Per gli emulatori ne consegue: uno con l'API più recente (36) e uno con l'API minima (24), per essere certi che l'app parta ai due estremi.

### 9.11 Su quanti telefoni veri provare

**Non esiste un minimo imposto.** Google Play non richiede di provare l'app su un certo numero di modelli. Il requisito del test chiuso (12 tester per 14 giorni, sezione 8.2) riguarda le persone, non i telefoni: dodici tester con lo stesso modello sarebbero formalmente sufficienti.

In pratica, per questa app:

| Livello | Telefoni | Cosa si verifica |
|---|---|---|
| Indispensabile | **1 telefono Android vero** | Scansione con la fotocamera, tempi di avvio, lettura del codice in cassa |
| Consigliato | **2–3 telefoni diversi** | Uno recente; uno vecchio o economico con schermo piccolo; possibilmente uno di un produttore con interfaccia propria molto diffusa (per esempio Samsung) |
| Gratuito | **I telefoni dei 12 tester** | Varietà reale di modelli, versioni di Android e dimensioni dello schermo |

Cosa conta davvero nella scelta, più del numero:

- **Un telefono lento.** L'obiettivo dei 2 secondi va misurato sul telefono peggiore, non sul migliore.
- **Uno schermo piccolo.** È dove codice a barre, dettagli e annuncio si contendono lo spazio.
- **Tecnologie di schermo diverse.** La leggibilità di un codice a barre da parte degli scanner di cassa dipende da luminosità e tipo di schermo: è l'unica prova che nessun emulatore può sostituire, e va fatta in negozi veri, con scanner diversi.
- **Versioni di Android ai due estremi.** Se non si dispone di un telefono con Android 7 o 8, l'emulatore con API 24 copre la compatibilità, ma non le prestazioni.

Ai tester conviene chiedere modello e versione di Android al momento dell'iscrizione, così si sa in anticipo quali combinazioni sono coperte. Play Console offre inoltre un rapporto automatico pre-lancio, che esegue l'app su alcuni dispositivi reali di Google a ogni caricamento: utile come controllo aggiuntivo, da verificare nella console al primo caricamento.

Pagine ufficiali:
- Piattaforme supportate da Flutter: https://docs.flutter.dev/reference/supported-platforms
- Requisito di livello API di Google Play: https://support.google.com/googleplay/android-developer/answer/11926878

---

## 10. Punti da approfondire e da decidere

Esito della rilettura del 16 novembre 2026. Nessuno blocca l'avvio dello sviluppo; sono ordinati per quanto incidono sul progetto.

### A. Da decidere prima di scrivere il codice che li riguarda

Tutti i punti di questo gruppo sono stati decisi (decisioni 77–86).

### B. Da definire durante lo sviluppo

- B1. **Formati dei codici del catalogo iniziale**: da rilevare scansionando tessere reali; colori da definire (le catene sono rappresentate da iniziali su colore, decisione 77).
- B3. **Scorciatoia in Home: eliminarla.** Android non permette a un'app di togliere l'icona dalla Home: si può solo disattivarla, e l'icona resta finché l'utente non la rimuove a mano. Il pannello "Elimina scorciatoia" la disattiva e deve dirlo chiaramente.
- B8. **Evoluzione dei dati.** Regola decisa (88). Resta da fare: scrivere le prove di migrazione man mano che lo schema cambia.

### C. Da preparare per la pubblicazione

- C1. **Materiali della scheda**: testi in tre lingue, schermate, immagine di presentazione, icona.
- C2. **Dichiarazioni in Play Console**: sicurezza dei dati, presenza di annunci, classificazione dei contenuti, pubblico di destinazione.
- C5. **Informativa sulla privacy**: aggiornata il 16 novembre 2026 per backup di Android, consenso e annunci non personalizzati, versione Pro; resta da far rileggere prima della pubblicazione e da riallineare se cambiano annunci, backup o acquisti.
