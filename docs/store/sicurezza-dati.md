# Sicurezza dei dati (Google Play)

Risposte per **Contenuti dell'app → Sicurezza dei dati** nella Play Console. Preparate il 22 nov 2026 per la versione 1.0.0+1.

## Da dove vengono

- **FacileCards non raccoglie dati.** Tessere, codici, foto, note, nome e impostazioni restano sul telefono: per Google Play i dati trattati solo sul dispositivo non sono "raccolti". I file esportati o condivisi partono solo per scelta dell'utente, verso l'app che sceglie lui: non è "condivisione" ai sensi del modulo.
- **L'unica raccolta è quella di Google AdMob** (annunci). Fonte: la pagina di Google "Google Mobile Ads SDK – Play data disclosure" (developers.google.com/admob/android/privacy/play-data-disclosure), letta il 22 nov 2026. Secondo Google l'SDK raccoglie e condivide automaticamente, per pubblicità, statistiche e prevenzione delle frodi:
  - l'indirizzo IP, che può servire a stimare la posizione approssimativa;
  - le interazioni con l'app (avvio, tocchi, visualizzazione di video);
  - informazioni diagnostiche (tempo di avvio, blocchi, consumo di energia);
  - identificatori del dispositivo (ID pubblicità, ID del gruppo di app).

  Tutto è cifrato in transito (TLS).
- **Acquisti:** l'acquisto Pro non c'è ancora. Quando arriverà, il pagamento lo gestisce Google Play e lo sviluppatore non riceve dati di pagamento; il modulo andrà riletto comunque.

## Risposte, schermata per schermata

**Raccolta e sicurezza dei dati**
- La tua app raccoglie o condivide uno dei tipi di dati utente richiesti? **Sì**
- Tutti i dati utente raccolti dalla tua app sono criptati in transito? **Sì**
- Quale dei seguenti metodi di creazione dell'account supporta la tua app? **La mia app non consente agli utenti di creare un account**
- Fornisci agli utenti un modo per richiedere l'eliminazione dei loro dati? **No.** Lo sviluppatore non conserva dati; quelli di AdMob seguono gli strumenti di Google.
- Revisione di sicurezza indipendente: **No**

**Tipi di dati** (seleziona solo questi)

| Categoria | Tipo |
|---|---|
| Posizione | Posizione approssimativa |
| Attività nell'app | Interazioni con l'app |
| Informazioni e prestazioni dell'app | Diagnostica |
| ID dispositivo o altri ID | ID dispositivo o altri ID |

**Per ciascuno dei quattro tipi**

| Domanda | Risposta |
|---|---|
| Raccolti | Sì |
| Condivisi | Sì (con Google, per gli annunci) |
| Trattati in modo temporaneo? | No |
| Obbligatori o facoltativi? | Obbligatori (l'utente non può disattivarli dall'app; il consenso cambia solo la personalizzazione degli annunci) |
| Motivi della raccolta | Pubblicità o marketing; Analisi; Prevenzione di frodi, sicurezza e conformità |
| Motivi della condivisione | Gli stessi |

Tutto il resto (nome, email, foto, file, contatti, posizione esatta, informazioni finanziarie, messaggi…) **non** va selezionato: l'app non lo raccoglie.

## Da ricontrollare

- A ogni aggiornamento della libreria degli annunci: la pagina di Google può cambiare.
- Quando arriverà l'acquisto Pro e, se si farà, la richiesta di tipologie via email (decisione 36).
