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
