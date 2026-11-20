# FacileCards — Videate e logo (ipotesi)

Versione 0.12 — 16 novembre 2026

Seconda ipotesi di aspetto dell'app, allineata alle decisioni dell'analisi (`01-analisi-iniziale.md`, versione 1.19). Le videate sono disegni statici (SVG), non l'app: servono a ragionare su disposizione, gerarchia e testi prima di scrivere codice.

![Panoramica delle videate](videate/00-panoramica.png)

## Stile

| Elemento | Scelta |
|---|---|
| Colore primario | Blu `#1F5FD6` |
| Blu scuro (ombre, stato premuto) | `#17479F` |
| Blu chiaro (riquadri informativi) | `#DCE7FF`, testo `#0B2A66` |
| Sfondo / superfici | `#F4F6FB` / `#FFFFFF` |
| Testo / testo secondario | `#161B26` / `#5F6B80` |
| Avvisi | Ambra `#B26A00` su `#FFF3D6`; scaduto: rosso `#C62828` |
| Carattere | Roboto (quello di sistema su Android) |
| Componenti | Material 3: barre, campi, pulsanti a pillola |

Le tessere sono rappresentate da un riquadro colorato con le iniziali (decisione 77: niente loghi reali). I colori dei riquadri sono indicativi.

## Videate

| # | Videata | Cosa mostra | Decisioni |
|---|---|---|---|
| 1 | [Configurazione iniziale](videate/01-configurazione-iniziale.svg) | Le domande del primo avvio: nome (facoltativo), lingua, app per pagare (facoltativa, proposta Satispay se c'è), avviso scadenze con giorni | 65, 118 |
| 2 | [Elenco, tutte le tessere](videate/02-elenco-tutte.svg) | Ricerca su tutti i campi, selettore Tutte / Per sezione, ordinamento, preferite in cima, campanella delle scadenze, contatore, annuncio al piede | 10, 53, 58, 70 |
| 3 | [Elenco per sezione](videate/03-elenco-per-sezione.svg) | Preferite in cima (e ripetute nella loro sezione), poi una intestazione per sezione: Generale per prima, le altre in ordine alfabetico | 10, 58, 85, 86 |
| 4 | [Scadenze](videate/04-scadenze.svg) | Campanella espansa: tessere scadute e in scadenza | 63, 70 |
| 5 | [Tessera](videate/05-tessera.svg) | Miniatura della foto del fronte (toccandola si apre il visualizzatore, videate 25–27); codice a barre grande, numero in chiaro, intestatario, scadenza, note; nella fascia in alto, a destra del nome, il pulsante con icona e nome dell'app per pagare (decisione 118, anche nelle videate 6, 18, 19, 28, 44); nella barra: preferita, modifica, condividi, cestino; annuncio al piede, staccato dal codice | 13, 62, 75, 118 |
| 6 | [Tessera con formato non più valido](videate/06-tessera-tipologia-ritirata.svg) | Segnale di avviso sull'icona della tessera; toccandolo si apre il riquadro con la spiegazione e la proposta della nuova tipologia. Lo stesso segnale compare nell'elenco (videata 2, PAM) | 39, 45, 73 |
| 7 | [Nuova tessera: tipologia](videate/07-nuova-tessera-tipologia.svg) | Ricerca nel catalogo; negozi; tipologie di categoria e Tessera Generica | 40, 72 |
| 8 | [Nuova tessera: dati](videate/08-nuova-tessera-dati.svg) | Nome, codice con "Scansiona" e "Da galleria", sezione, scadenza, intestatario, note, foto, preferita | 5, 37, 62, 71, 110 |
| 9 | [Condividi: avviso](videate/09-condividi-avviso.svg) | Primo passaggio della doppia conferma: cosa comporta la condivisione | 68 |
| 10 | [Condividi: conferma](videate/10-condividi-conferma.svg) | Secondo passaggio: casella "Ho capito", messaggio che accompagna il file, password facoltativa | 64, 68, 103 |
| 11 | [Importa sezione](videate/11-importa-sezione.svg) | Anteprima del file, tre destinazioni (se già ricevuta, proposta "Sostituisci"), esito sul limite di 50 | 16, 17, 18, 79, 80, 113 |
| 12 | [Sezioni](videate/12-sezioni.svg) | Sezioni con condivisione e menu; nuova sezione | 104, 114 |
| 12b | [Dati](videate/12b-dati.svg) | Esporta tutto, Importa da file, promemoria "Ultima copia", cestino | 19, 26, 114 |
| 13 | [Cestino: recupero](videate/13-cestino-recupero.svg) | Scelta della sezione di destinazione, sezione eliminata che viene ricreata, esito sul limite | 20, 27, 28 |
| 14 | [Impostazioni](videate/14-impostazioni.svg) | Valori della configurazione iniziale (anche l'app per pagare, anche nella 42), tema (come il telefono / chiaro / scuro), versione, richiesta di una tessera mancante, consenso annunci, informativa | 36, 65, 74, 118 |
| 15 | [Limite raggiunto](videate/15-limite-versione-pro.svg) | Proposta della versione Pro a 2 € | 13, 14, 98 |
| 16 | [Scorciatoie in Home](videate/16-scorciatoie-home.svg) | Schermata iniziale del telefono con icone che aprono direttamente una tessera | 89 |
| 17 | [Elimina: scorrimento](videate/17-elimina-scorrimento.svg) | Riga dell'elenco trascinata verso sinistra, con il pulsante di eliminazione | 75 |
| 18 | [Elimina: conferma](videate/18-elimina-conferma.svg) | Scelta tra cestino ed eliminazione definitiva, raggiungibile sia dallo scorrimento sia dal cestino nella barra della tessera | 20, 75 |
| 19 | [Aggiungi alla schermata Home](videate/19-scorciatoia-aggiungi.svg) | Riquadro di conferma aperto dal collegamento sotto i pulsanti della tessera | 89, 90 |
| 20 | [Scorciatoia: tessera nel cestino](videate/20-scorciatoia-tessera-eliminata.svg) | Toccando una scorciatoia la cui tessera è eliminata: ripristino o eliminazione della scorciatoia | 90 |
| 21 | [Informazioni](videate/21-informazioni.svg) | Versione, sviluppatore, avvertenza sui marchi, informativa e sito | 99 |
| 22 | [Scansione](videate/22-scansione.svg) | Fotocamera a tutto schermo con cornice, torcia, inserimento a mano; si ferma da sola alla lettura | 71, 82, 100, 110 |
| 23 | [Scansione: formato errato](videate/23-scansione-formato-errato.svg) | Codice letto in un formato diverso da quello della tipologia: la cornice diventa ambra e compare il messaggio | 82 |
| 24 | [Fotocamera non consentita](videate/24-fotocamera-negata.svg) | Se il permesso è negato: apri impostazioni, inserisci a mano, leggi da galleria | 100 |
| 25 | [Foto: fronte](videate/25-foto-fronte.svg) | Foto a tutto schermo; scorrimento verso il retro, pizzico per ingrandire, tocco per chiudere; barra fissa con Sostituisci ed Elimina foto | 101 |
| 26 | [Foto: retro](videate/26-foto-retro.svg) | Lo stesso visualizzatore sul retro | 101 |
| 27 | [Foto: retro mancante](videate/27-foto-retro-mancante.svg) | Pagina con il pulsante per aggiungere la foto del retro | 101 |
| 28 | [Tessera senza foto](videate/28-tessera-senza-foto.svg) | Al posto della miniatura, il pulsante "Aggiungi foto" | 101 |
| 29 | [Importa tutto](videate/29-importa-tutto.svg) | Riepilogo dell'archivio, scelta tra unire e sostituire tutto, esito sul limite | 17, 18, 102 |
| 30 | [Importa tutto: oltre il limite](videate/30-importa-tutto-limite.svg) | Messaggio rosso, invito a Pro, pulsante disattivato | 15, 102 |
| 31 | [Importa tutto: conferma della sostituzione](videate/31-importa-tutto-conferma.svg) | Seconda conferma, con i numeri e il cestino | 102 |
| 32 | [Esporta tutto: avviso](videate/32-esporta-tutto-avviso.svg) | Primo passaggio: cosa contiene il file e come custodirlo | 64, 68, 103 |
| 33 | [Esporta tutto: conferma](videate/33-esporta-tutto-conferma.svg) | Casella "Ho capito", password facoltativa con ripetizione, salva sul telefono o condividi | 103 |
| 34 | [Importa: file protetto](videate/34-importa-password.svg) | Richiesta della password | 103 |
| 35 | [Importa: password errata](videate/35-importa-password-errata.svg) | Campo in rosso e messaggio, si può riprovare | 103 |
| 36 | [Menu della sezione](videate/36-sezione-menu.svg) | Condividi, Rinomina, Elimina sezione | 104 |
| 37 | [Elimina sezione con tessere](videate/37-elimina-sezione.svg) | Spostare le tessere in un'altra sezione o eliminarle (cestino 30 giorni), con il risultato scritto | 20, 104 |
| 38 | [Elimina sezione vuota](videate/38-elimina-sezione-vuota.svg) | Una sola conferma | 104 |
| 39 | [Elimina foto](videate/39-elimina-foto.svg) | Conferma dentro il visualizzatore | 101 |
| 40 | [Consenso agli annunci: presentazione](videate/40-consenso-presentazione.svg) | Schermata nostra, prima di quella di Google: perché gli annunci, e cosa cambia se non si acconsente | 105 |
| 41 | [Consenso agli annunci: finestra di Google](videate/41-consenso-finestra-google.svg) | Rappresentazione indicativa: testo e aspetto reali li fornisce Google (UMP) | 105 |
| 42 | [Impostazioni, versione Pro](videate/42-impostazioni-pro.svg) | "Pro attivo · grazie!"; senza la voce sul consenso agli annunci | 106 |
| 43 | [Acquisto in elaborazione](videate/43-acquisto-in-elaborazione.svg) | Pagamento non ancora confermato da Google Play | 106 |
| 44 | [Tessera, versione Pro](videate/44-tessera-pro.svg) | Senza banner; il codice non viene ingrandito | 106 |
| 45 | [Elenco, versione Pro](videate/45-elenco-pro.svg) | Senza banner; il pulsante "+" scende | 106 |
| 46 | [App per pagare](videate/46-app-per-pagare.svg) | Scelta dell'app da aprire dalla tessera: "Nessuna" e le app per pagare trovate sul telefono (elenco nostro e app che pagano con NFC), con le icone vere; "Manca la tua app? Chiedi di aggiungerla" | 36, 118 |
| 47 | [Scelta della lingua](videate/47-scelta-lingua.svg) | Finestra aperta dalla configurazione iniziale (1) e dalle Impostazioni (14): bandiera, nome della lingua nella lingua stessa, spunta su quella attuale; la lingua scelta si mostra con la sua bandiera anche nel campo e nella riga. Per l'inglese la bandiera del Regno Unito | 35 |

## Tema scuro

Le stesse videate a sfondo scuro sono in `videate/scuro/`, con gli stessi nomi di file.

![Panoramica delle videate, tema scuro](videate/scuro/00-panoramica.png)

| Elemento | Chiaro | Scuro |
|---|---|---|
| Sfondo | `#F4F6FB` | `#0F131A` |
| Superfici | `#FFFFFF` | `#1A2029` |
| Bordi | `#D5DBE7` | `#323A48` |
| Testo / testo secondario | `#161B26` / `#5F6B80` | `#E8ECF3` / `#9AA5B8` |
| Blu primario | `#1F5FD6` | `#4C87F2` |
| Riquadri informativi | `#DCE7FF`, testo `#0B2A66` | `#1B2B4B`, testo `#CFE0FF` |
| Avvisi | ambra `#B26A00` su `#FFF3D6` | ambra `#F0B24A` su `#3A2C0C` |
| Scaduto / elimina | `#C62828` | `#E5534B` |

Regole seguite:

- **Il riquadro del codice a barre resta bianco** anche nel tema scuro: gli scanner leggono male i codici su fondo scuro, e in quella schermata la luminosità è comunque al massimo.
- I colori delle tessere (riquadri con le iniziali e intestazione della scheda) non cambiano con il tema.
- Il blu primario è più chiaro nel tema scuro, per restare leggibile come testo su fondo scuro.

Il set scuro è ricavato dal chiaro sostituendo i colori: mostra la resa generale, non è una rifinitura schermata per schermata.

## Logo

Una tessera con il pollice alzato: "tessera" per ciò che l'app contiene, "pollice" per facile.

| File | Uso |
|---|---|
| [`logo/facilecards-icon.svg`](logo/facilecards-icon.svg) (e `.png` 512×512) | Icona dell'app |
| [`logo/facilecards-mark.svg`](logo/facilecards-mark.svg) | Solo simbolo, su fondo chiaro |
| [`logo/facilecards-logo.svg`](logo/facilecards-logo.svg) | Simbolo e nome, per sito e scheda dello store |

![Icona](logo/facilecards-icon.png)

## Scelte fatte disegnando, da confermare

1. **Preferite nella vista per sezione (videata 3).** Decisione 86: compaiono nel blocco in cima e anche nella loro sezione.
2. **Preferite e ordinamento.** Dentro il gruppo delle preferite vale lo stesso ordinamento scelto per il resto dell'elenco.
3. **Dove si attiva la preferita.** Stella nella barra della tessera (videata 5) e voce nella scheda di inserimento (videata 8).
4. **Avviso di scadenza anche nella riga (videata 3).** Oltre alla campanella, la riga della tessera in scadenza mostra il testo in ambra.
5. **Annuncio sotto la tessera (videate 5 e 6).** Con intestatario, scadenza e note lo spazio si è ridotto: da valutare sui telefoni piccoli, dove i dettagli potrebbero finire sotto lo scorrimento.
6. **Segnale di tipologia ritirata.** Stesso segnale ambra sull'icona nell'elenco e nella tessera; il riquadro si apre solo toccandolo, quindi il codice non si sposta.
7. **Pulsante di aggiunta (videate 2 e 3).** Copre in parte l'ultima riga visibile: è il comportamento standard su Android.
8. **Voci sulla scheda della tessera.** Il collegamento "Aggiungi alla schermata Home" (videata 5) è una collocazione provvisoria: potrebbe finire in un menu della barra.

## Non ancora disegnato

Nessuna videata da disegnare per ora. L'importazione di una singola tessera usa la videata 11, con una sola differenza: invece delle tre destinazioni di una sezione si sceglie la sezione in cui metterla (predefinita "Generale") e si vede l'esito sul limite ("Dopo l'importazione: 14 di 50 tessere").
