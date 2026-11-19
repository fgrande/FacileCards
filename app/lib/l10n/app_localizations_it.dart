// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get usedNever => 'mai usata';

  @override
  String get usedToday => 'usata oggi';

  @override
  String get usedYesterday => 'usata ieri';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni fa',
      one: '1 giorno fa',
    );
    return '$_temp0';
  }

  @override
  String get aWeekAgo => 'una settimana fa';

  @override
  String weeksAgo(int count) {
    return '$count settimane fa';
  }

  @override
  String get aMonthAgo => 'un mese fa';

  @override
  String monthsAgo(int count) {
    return '$count mesi fa';
  }

  @override
  String get deletedToday => 'Eliminata oggi';

  @override
  String get deletedYesterday => 'Eliminata ieri';

  @override
  String deletedDaysAgo(int count) {
    return 'Eliminata $count giorni fa';
  }

  @override
  String get expired => 'Scaduta';

  @override
  String get expiresToday => 'Scade oggi';

  @override
  String get expiresTomorrow => 'Scade domani';

  @override
  String expiresInDays(int count) {
    return 'Scade tra $count giorni';
  }

  @override
  String get badgeToday => 'Oggi';

  @override
  String get badgeTomorrow => 'Domani';

  @override
  String badgeInDays(int count) {
    return 'Tra $count giorni';
  }

  @override
  String expiredOn(String date) {
    return 'Scaduta il $date';
  }

  @override
  String expiresOn(String date) {
    return 'Scade il $date';
  }

  @override
  String get language => 'Lingua';

  @override
  String get setupWelcome => 'Benvenuto in FacileCards';

  @override
  String get setupIntro => 'Tre domande e sei pronto.';

  @override
  String get setupNameLabel => 'Il tuo nome (facoltativo)';

  @override
  String get setupNameHelp =>
      'Lo proponiamo come intestatario delle nuove tessere.';

  @override
  String get setupLanguageHelp => 'È quella del telefono. Puoi cambiarla.';

  @override
  String get expiryAlertsTitle => 'Avvisami delle scadenze';

  @override
  String get expiryAlertsSubtitle =>
      'Per le tessere che hanno una data di scadenza';

  @override
  String get expiryDaysTitle => 'Giorni di preavviso';

  @override
  String get setupLater => 'Potrai cambiare tutto dalle impostazioni.';

  @override
  String get setupStart => 'Inizia';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get close => 'Chiudi';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get yourName => 'Il tuo nome';

  @override
  String get optional => 'Facoltativo';

  @override
  String get settingsPersonal => 'Personali';

  @override
  String get nameNotSet => 'Non indicato';

  @override
  String get theme => 'Tema';

  @override
  String get expiryAlerts => 'Avviso scadenze';

  @override
  String expiryAlertsOn(int days) {
    return '$days giorni prima · tocca per cambiare';
  }

  @override
  String get off => 'Spento';

  @override
  String get settingsVersion => 'Versione';

  @override
  String get freeVersion => 'Versione gratuita';

  @override
  String freeVersionCount(int count, int limit) {
    return '$count di $limit tessere · con annunci';
  }

  @override
  String get purchaseComing =>
      'L\'acquisto arriverà con la pubblicazione su Google Play.';

  @override
  String get upgradePro => 'Passa a Pro · 2,00 €  →';

  @override
  String get restorePurchase => 'Ripristina acquisto';

  @override
  String get settingsOther => 'Altro';

  @override
  String get requestMissingCard => 'Richiedi una tessera mancante';

  @override
  String get missingCardSubject => 'Tessera mancante in FacileCards';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get aboutApp => 'Informazioni su FacileCards';

  @override
  String noAppToOpen(String url) {
    return 'Non c\'è un\'app per aprire $url';
  }

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Come il telefono';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String versionNumber(String version) {
    return 'Versione $version';
  }

  @override
  String developedBy(String name) {
    return 'Sviluppata da $name';
  }

  @override
  String get trademarkDisclaimer =>
      'FacileCards è un\'app indipendente e non è affiliata, sponsorizzata né approvata dalle aziende citate. I nomi e i marchi appartengono ai rispettivi proprietari.';

  @override
  String get website => 'Sito di FacileCards';

  @override
  String cardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tessere',
      one: '1 tessera',
    );
    return '$_temp0';
  }

  @override
  String countOfLimit(int count, int limit) {
    return '$count di $limit';
  }

  @override
  String get expiryTooltip => 'Scadenze';

  @override
  String get listEmpty => 'Nessuna tessera. Tocca + e scegli il negozio.';

  @override
  String get listNoMatch => 'Nessuna tessera trovata.';

  @override
  String get favorites => 'Preferite';

  @override
  String get allCards => 'Tutte le tessere';

  @override
  String get viewAll => 'Tutte';

  @override
  String get viewBySection => 'Per sezione';

  @override
  String get sortLastUsed => 'Ultimo utilizzo';

  @override
  String get sortName => 'Nome A–Z';

  @override
  String get menuSections => 'Sezioni';

  @override
  String get menuData => 'Dati';

  @override
  String get searchCards => 'Cerca tessere';

  @override
  String get addCard => 'Aggiungi una tessera';

  @override
  String expiryPanelFooter(int days) {
    return 'Avviso a $days giorni dalla scadenza\nLe tessere restano utilizzabili.';
  }

  @override
  String get photoFront => 'Foto del fronte';

  @override
  String get photoBack => 'Foto del retro';

  @override
  String get moveToSection => 'Sposta nella sezione';

  @override
  String get addPhoto => 'Aggiungi foto';

  @override
  String photoCount(int count) {
    return '$count foto';
  }

  @override
  String deleteCardQuestion(String name) {
    return 'Eliminare «$name»?';
  }

  @override
  String trashRecoverable(int days) {
    return 'Nel cestino resta recuperabile per $days giorni.';
  }

  @override
  String get deleteForever => 'Elimina definitivamente';

  @override
  String get moveToTrash => 'Sposta nel cestino';

  @override
  String get holder => 'Intestatario';

  @override
  String get expiry => 'Scadenza';

  @override
  String get notes => 'Note';

  @override
  String get favorite => 'Preferita';

  @override
  String get edit => 'Modifica';

  @override
  String get share => 'Condividi';

  @override
  String get delete => 'Elimina';

  @override
  String formatNotDrawable(String format) {
    return 'Formato non disegnabile: $format';
  }

  @override
  String invalidCode(String error) {
    return 'Codice non valido: $error';
  }

  @override
  String get move => 'Sposta';

  @override
  String addedOn(String date) {
    return 'Inserita il $date';
  }

  @override
  String get genericTypeHint => 'Codice e foto del fronte';

  @override
  String get freeNameHint => 'Nome a scelta';

  @override
  String get newCard => 'Nuova tessera';

  @override
  String get editCard => 'Modifica tessera';

  @override
  String get searchShop => 'Cerca un negozio';

  @override
  String get shops => 'Negozi';

  @override
  String get otherCards => 'Altre tessere';

  @override
  String get replace => 'Sostituisci';

  @override
  String get removePhoto => 'Togli la foto';

  @override
  String get anyCodeFormat => 'Qualunque formato di codice';

  @override
  String codeFormatIs(String format) {
    return 'Formato del codice: $format';
  }

  @override
  String get remove => 'Togli';

  @override
  String get section => 'Sezione';

  @override
  String get enterCardName => 'Scrivi il nome della tessera.';

  @override
  String get enterCode => 'Inserisci o scansiona il codice.';

  @override
  String get genericNeedsFront =>
      'Per la tessera generica serve la foto del fronte.';

  @override
  String limitReached(int limit) {
    return 'Hai raggiunto il limite di $limit tessere.';
  }

  @override
  String get saving => 'Salvataggio…';

  @override
  String get name => 'Nome';

  @override
  String get code => 'Codice';

  @override
  String get scan => 'Scansiona';

  @override
  String get fromGallery => 'Da galleria';

  @override
  String get none => 'Nessuna';

  @override
  String get notesHint => 'Facoltative';

  @override
  String get photosFrontRequired => 'FOTO (IL FRONTE È OBBLIGATORIO)';

  @override
  String get photosOptional => 'FOTO (FACOLTATIVE)';

  @override
  String get addToFavorites => 'Aggiungi alle preferite';

  @override
  String get sideFront => 'Fronte';

  @override
  String get sideBack => 'Retro';

  @override
  String get takePhoto => 'Scatta una foto';

  @override
  String get chooseFromGallery => 'Scegli dalla galleria';

  @override
  String get cameraDeniedUseGallery =>
      'La fotocamera non è consentita: puoi scegliere la foto dalla galleria.';

  @override
  String get photoFailed => 'Non sono riuscito a prendere la foto.';

  @override
  String get notAnImage => 'Il file scelto non è un\'immagine.';

  @override
  String get frontPhotoRequired =>
      'Per la tessera generica la foto del fronte è obbligatoria: puoi sostituirla.';

  @override
  String get deleteFrontPhotoQuestion => 'Eliminare la foto del fronte?';

  @override
  String get deleteBackPhotoQuestion => 'Eliminare la foto del retro?';

  @override
  String get deletePhotoExplain =>
      'La foto viene rimossa da questa tessera.\nIl codice resta com\'è.';

  @override
  String get deletePhoto => 'Elimina foto';

  @override
  String get noFrontPhoto => 'Nessuna foto del fronte';

  @override
  String get noBackPhoto => 'Nessuna foto del retro';

  @override
  String get swipeToBack => 'Scorri per vedere il retro';

  @override
  String get swipeToFront => 'Scorri per tornare al fronte';

  @override
  String get swipeToBackZoom =>
      'Scorri per vedere il retro · pizzica per ingrandire\nTocca la foto per chiudere';

  @override
  String get swipeToFrontZoom =>
      'Scorri per tornare al fronte · pizzica per ingrandire\nTocca la foto per chiudere';

  @override
  String get noCodeFound => 'Nessun codice trovato';

  @override
  String get noCodeFoundDetail =>
      'Scegli una foto in cui il codice si veda bene.';

  @override
  String get photoReadFailed => 'Non sono riuscito a leggere la foto';

  @override
  String get tryAnotherImage => 'Prova con un\'altra immagine.';

  @override
  String get typeGeneric => 'Tessera generica';

  @override
  String get typeLibrary => 'Biblioteca';

  @override
  String get typeGym => 'Palestra';

  @override
  String get categoryLoyalty => 'Tessera fedeltà';

  @override
  String get categoryOther => 'Tessera';

  @override
  String get formatUnknown => 'Formato non riconosciuto';

  @override
  String get formatUnknownDetail => 'Prova a inquadrare di nuovo il codice.';

  @override
  String get thisType => 'questa tipologia';

  @override
  String codeNotOfType(String name) {
    return 'Questo codice non sembra di $name';
  }

  @override
  String codeNotOfTypeDetail(String read, String expected) {
    return 'Controlla la tipologia o usa Tessera generica.\nLetto: $read · atteso: $expected';
  }

  @override
  String get scanFrame => 'Inquadra il codice della tessera';

  @override
  String get scanAuto => 'Si legge da solo: non serve toccare nulla.';

  @override
  String get torch => 'Torcia';

  @override
  String get enterCodeManually => 'Inserisci il codice a mano';

  @override
  String get cameraNeeded => 'Serve la fotocamera';

  @override
  String get cameraUnavailable => 'La fotocamera non è disponibile';

  @override
  String get cameraNeededDetail =>
      'Per leggere il codice di una tessera FacileCards usa la fotocamera. Le immagini restano sul telefono.';

  @override
  String get cameraUnavailableDetail =>
      'Puoi leggere il codice da una foto della galleria o scriverlo a mano.';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get readFromGalleryPhoto => 'Leggi da una foto della galleria';

  @override
  String get scanTitle => 'Scansiona il codice';

  @override
  String get newSection => 'Nuova sezione';

  @override
  String get renameSection => 'Rinomina sezione';

  @override
  String get sectionNameTaken =>
      'Scrivi un nome che non sia già usato da un\'altra sezione.';

  @override
  String deleteQuestion(String name) {
    return 'Eliminare «$name»?';
  }

  @override
  String get sectionEmpty => 'La sezione è vuota.';

  @override
  String notDeletable(String count) {
    return '$count · non eliminabile';
  }

  @override
  String get emptySection => 'Vuota';

  @override
  String get rename => 'Rinomina';

  @override
  String get deleteSection => 'Elimina sezione';

  @override
  String sectionContains(String count) {
    return 'La sezione contiene $count. Cosa ne facciamo?';
  }

  @override
  String get moveCardsToOtherSection =>
      'Sposta le tessere in un\'altra sezione';

  @override
  String sectionIs(String name) {
    return 'Sezione: $name';
  }

  @override
  String get changeSection => 'Cambia sezione';

  @override
  String get deleteCardsToo => 'Elimina anche le tessere';

  @override
  String staysInTrash(int days) {
    return 'Restano $days giorni nel cestino.';
  }

  @override
  String resultIn(String count, String section) {
    return 'Risultato: $count in $section';
  }

  @override
  String resultInTrash(String count) {
    return 'Risultato: $count nel cestino';
  }

  @override
  String get sectionNameHint => 'Es. Famiglia';

  @override
  String get dataTitle => 'Dati';

  @override
  String get archive => 'Archivio';

  @override
  String get exportAll => 'Esporta tutto';

  @override
  String get exportAllSubtitle => 'Salva una copia di tutte le tessere';

  @override
  String get importFromFile => 'Importa da file';

  @override
  String get importFromFileSubtitle =>
      'Una copia completa, una sezione o una tessera';

  @override
  String get deletedCards => 'Tessere eliminate';

  @override
  String get trash => 'Cestino';

  @override
  String trashSubtitle(String count, int days) {
    return '$count · eliminate dopo $days giorni';
  }

  @override
  String get noBackupYet => 'Non hai ancora fatto una copia.';

  @override
  String get lastCopyToday => 'Ultima copia: oggi.';

  @override
  String get lastCopyYesterday => 'Ultima copia: ieri.';

  @override
  String lastCopyDaysAgo(int days) {
    return 'Ultima copia: $days giorni fa.';
  }

  @override
  String onlyOnThisPhone(String when) {
    return 'Le tue tessere esistono solo su questo telefono.\n$when';
  }

  @override
  String noRoomLimit(int limit) {
    return 'Non c\'è posto: hai raggiunto il limite di $limit tessere.';
  }

  @override
  String deleteForeverQuestion(String name) {
    return 'Eliminare «$name» per sempre?';
  }

  @override
  String get cannotRecover => 'Non si potrà più recuperare.';

  @override
  String trashExplain(int days) {
    return 'Le tessere eliminate restano qui $days giorni. Tocca una tessera per recuperarla.';
  }

  @override
  String get trashEmpty => 'Il cestino è vuoto.';

  @override
  String wasIn(String when, String section) {
    return '$when · era in $section';
  }

  @override
  String get deleteForeverTooltip => 'Elimina per sempre';

  @override
  String restoreInto(String name) {
    return 'Recupera «$name» in…';
  }

  @override
  String afterRestore(int count, int limit) {
    return 'Dopo il recupero: $count di $limit tessere';
  }

  @override
  String get restore => 'Recupera';

  @override
  String get sectionWillBeRecreated => 'Sezione eliminata: verrà ricreata';

  @override
  String get transferNotFacileCards => 'Non è un file di FacileCards.';

  @override
  String get transferNotFacileCardsOrDamaged =>
      'Non è un file di FacileCards, o è rovinato.';

  @override
  String get transferBadVersion => 'Versione del file non valida.';

  @override
  String get transferNewerVersion =>
      'Il file è stato creato da una versione più recente di FacileCards: aggiorna l\'app.';

  @override
  String get transferBadHeader => 'Intestazione del file non valida.';

  @override
  String get transferTooBig => 'Il file è troppo grande.';

  @override
  String get transferIncomplete => 'Il file è incompleto.';

  @override
  String get transferContentDamaged => 'Il contenuto del file è rovinato.';

  @override
  String get transferDataDamaged => 'I dati del file sono rovinati.';

  @override
  String get transferBadData => 'Dati del file non validi.';

  @override
  String get transferTooManyCards => 'Il file contiene troppe tessere.';

  @override
  String get transferBadSection => 'Sezione non valida.';

  @override
  String get transferRepeatedSection => 'Sezione ripetuta nel file.';

  @override
  String get transferBadCard => 'Tessera non valida.';

  @override
  String get transferRepeatedCard => 'Tessera ripetuta nel file.';

  @override
  String get transferCardWithoutSection =>
      'Una tessera cita una sezione che non c\'è.';

  @override
  String get transferBadPhoto => 'Foto non valida.';

  @override
  String get transferPhotoTooBig => 'Una foto è troppo grande.';

  @override
  String get transferBadId => 'Identificativo non valido nel file.';

  @override
  String get transferBadValue => 'Dato non valido nel file.';

  @override
  String get transferMissingValue => 'Dato mancante nel file.';

  @override
  String get transferValueTooLong => 'Dato troppo lungo nel file.';

  @override
  String get transferBadDate => 'Data non valida nel file.';

  @override
  String get transferProtectedDamaged => 'Il file protetto è rovinato.';

  @override
  String get transferSectionNameTaken =>
      'Scegli un nome che non sia già usato da un\'altra sezione.';

  @override
  String transferLimitExceeded(int count, int limit) {
    return 'Con questa importazione saresti a $count tessere: il limite è $limit.';
  }

  @override
  String passwordTooShort(int min) {
    return 'Almeno $min caratteri.';
  }

  @override
  String get passwordsDiffer => 'Le due password non sono uguali.';

  @override
  String aboutSize(String size) {
    return 'circa $size';
  }

  @override
  String get shareSection => 'Condividi sezione';

  @override
  String get shareCard => 'Condividi tessera';

  @override
  String shareMessageCard(String name, String url) {
    return 'Ti invio la tessera «$name».\nPer aprirla serve FacileCards:\n$url';
  }

  @override
  String shareMessageSection(String name, String url) {
    return 'Ti invio le tessere della sezione «$name».\nPer aprirle serve FacileCards:\n$url';
  }

  @override
  String get copySaved => 'Copia salvata.';

  @override
  String get copySaveFailed => 'Non sono riuscito a salvare la copia. Riprova.';

  @override
  String get saveCopyTitle => 'Salva la copia delle tessere';

  @override
  String get backupShareText =>
      'Copia di tutte le mie tessere di FacileCards. Si apre con l\'app FacileCards, da \"Importa da file\".';

  @override
  String get copyPrepareFailed =>
      'Non sono riuscito a preparare la copia. Riprova.';

  @override
  String stepOf(int step, int total) {
    return 'Passo $step di $total';
  }

  @override
  String get allYourCards => 'Tutte le tue tessere';

  @override
  String sectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sezioni',
      one: '1 sezione',
    );
    return '$_temp0';
  }

  @override
  String get aboutToBackup =>
      'Stai per creare una copia di tutte le tue tessere';

  @override
  String get aboutToShareCard =>
      'Stai per consegnare questa tessera ad altre persone';

  @override
  String get aboutToShareCards =>
      'Stai per consegnare queste tessere ad altre persone';

  @override
  String get backupPoint1 => 'Il file contiene tutto';

  @override
  String get backupPoint1Detail => 'Codici, intestatari, note e foto.';

  @override
  String get backupPoint2 => 'Chi lo apre può usare le tessere';

  @override
  String get validAtCheckout => 'Alla cassa valgono come le tue.';

  @override
  String get backupPoint3 => 'Conservalo in un posto sicuro';

  @override
  String get backupPoint3Detail => 'Un archivio personale, non una chat.';

  @override
  String get backupPoint4 => 'Puoi proteggerlo con una password';

  @override
  String get backupPoint4Detail => 'Al prossimo passaggio, se vuoi.';

  @override
  String get sharePoint1Card => 'Chi riceve il file può usare la tessera';

  @override
  String get sharePoint1Cards => 'Chi riceve il file può usare le tessere';

  @override
  String get sharePoint2Card => 'Vede tutto ciò che contiene';

  @override
  String get sharePoint2Cards => 'Vede tutto ciò che contengono';

  @override
  String get sharePoint2Detail => 'Codici, intestatario, note e foto.';

  @override
  String get sharePoint3 => 'Può inoltrarlo a chiunque';

  @override
  String get sharePoint3Detail => 'FacileCards non può impedirlo.';

  @override
  String get sharePoint4 => 'Non puoi ritirarlo';

  @override
  String get sharePoint4Detail => 'Una volta inviato, il file non è più tuo.';

  @override
  String largeFileWarning(String size) {
    return 'Il file è grande ($size), soprattutto per le foto: alcune app potrebbero non riuscire a inviarlo.';
  }

  @override
  String understoodBackup(String cards) {
    return 'Ho capito: sto esportando $cards in un unico file.';
  }

  @override
  String understoodCard(String name) {
    return 'Ho capito: sto condividendo la tessera «$name» con le persone a cui invierò il file.';
  }

  @override
  String understoodSection(String cards, String name) {
    return 'Ho capito: sto condividendo $cards della sezione «$name» con le persone a cui invierò il file.';
  }

  @override
  String get messageWithFile => 'Messaggio che accompagna il file';

  @override
  String get passwordForgetWarning =>
      'Se la dimentichi non potrai riaprire il file.\nNessuno può recuperarla, nemmeno noi.';

  @override
  String get sharePanelHint =>
      'Si aprirà il pannello di condivisione del telefono: scegli tu l\'app e il destinatario.';

  @override
  String get hide => 'Nascondi';

  @override
  String get show => 'Mostra';

  @override
  String get protectWithPassword => 'Proteggi con password';

  @override
  String get passwordOptional => 'Facoltativa.';

  @override
  String get passwordOptionalShare =>
      'Facoltativa: chi apre il file dovrà inserirla.';

  @override
  String get password => 'Password';

  @override
  String get repeatPassword => 'Ripeti la password';

  @override
  String passwordsOk(int min) {
    return 'Password uguali · almeno $min caratteri';
  }

  @override
  String passwordRule(int min) {
    return 'Almeno $min caratteri, scritta due volte.';
  }

  @override
  String get continueButton => 'Continua';

  @override
  String get saveOnPhone => 'Salva sul telefono';

  @override
  String get shareEllipsis => 'Condividi…';

  @override
  String get back => 'Indietro';

  @override
  String get cannotImport => 'Non si può importare';

  @override
  String get fileReadFailedMaybeBig =>
      'Non sono riuscito a leggere il file. Potrebbe essere troppo grande.';

  @override
  String get fileReadFailed => 'Non sono riuscito a leggere il file.';

  @override
  String get fileContentUnexpected =>
      'Il file è rovinato: il contenuto non è quello atteso.';

  @override
  String get replaceAllInFile =>
      'Le tue tessere attuali sono tutte nel file: restano, con i dati del file.';

  @override
  String trashedAll(int count, Object days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Le tue $count tessere attuali finiranno nel cestino e vi resteranno per $days giorni.',
      one:
          'La tua tessera attuale finirà nel cestino e vi resterà per $days giorni.',
    );
    return '$_temp0';
  }

  @override
  String trashedSome(int count, Object days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count tessere attuali finiranno nel cestino e vi resteranno per $days giorni.',
      one:
          '1 tessera attuale finirà nel cestino e vi resterà per $days giorni.',
    );
    return '$_temp0';
  }

  @override
  String othersStay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Le altre $count sono anche nel file e restano.',
      one: 'L\'altra è anche nel file e resta.',
    );
    return '$_temp0';
  }

  @override
  String get replaceAllQuestion => 'Sostituire tutte le tessere?';

  @override
  String aboutToReplace(String cards, int incoming) {
    return 'Stai per sostituire $cards con $incoming.';
  }

  @override
  String get trashNotCounted =>
      'Le tessere del cestino non contano per il limite.';

  @override
  String replaceXWithY(int current, int incoming) {
    return 'Sostituisci $current con $incoming';
  }

  @override
  String importedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importate $count tessere.',
      one: 'Importata 1 tessera.',
    );
    return '$_temp0';
  }

  @override
  String get importFailedNothingChanged =>
      'Importazione non riuscita: le tue tessere non sono cambiate.';

  @override
  String wouldBeOverLimit(int count) {
    return 'Con questa scelta saresti a $count tessere';
  }

  @override
  String freeLimitDetail(int limit) {
    return 'Il limite della versione gratuita è $limit.\nCon Pro non hai limiti.';
  }

  @override
  String get allAlreadyPresent => 'Tutte le tessere del file sono già presenti';

  @override
  String get nothingToAdd => 'Non c\'è niente da aggiungere.';

  @override
  String addsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aggiunge $count tessere nuove',
      one: 'Aggiunge 1 tessera nuova',
    );
    return '$_temp0';
  }

  @override
  String alreadyPresent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count già presenti',
      one: '1 già presente',
    );
    return '$_temp0';
  }

  @override
  String afterImport(int count, int limit) {
    return 'Dopo l\'importazione: $count di $limit tessere';
  }

  @override
  String replacesXWithY(String cards, int incoming) {
    return 'Sostituisce $cards con $incoming';
  }

  @override
  String get importAll => 'Importa tutto';

  @override
  String get archiveOfApp => 'Archivio di FacileCards';

  @override
  String archiveOf(String owner) {
    return 'Archivio di $owner';
  }

  @override
  String createdOn(String date) {
    return 'Creato il $date';
  }

  @override
  String get howToImport => 'Come importarle';

  @override
  String get mergeWithExisting => 'Unisci alle tessere esistenti';

  @override
  String get mergeWithExistingDetail =>
      'Aggiunge solo quelle che mancano. Consigliato.';

  @override
  String get replaceAll => 'Sostituisci tutto';

  @override
  String replaceAllDetail(int days) {
    return 'Le tessere attuali vanno nel cestino per $days giorni.';
  }

  @override
  String get androidBackupNote =>
      'Se hai già ripristinato i dati con il backup di Android, le tessere già presenti non vengono duplicate.';

  @override
  String get discoverPro => 'Scopri Pro · 2,00 €';

  @override
  String get importButton => 'Importa';

  @override
  String importCards(String cards) {
    return 'Importa $cards';
  }

  @override
  String get passwordProtectedFile => 'File protetto da password';

  @override
  String get enterFilePassword =>
      'Inserisci la password scelta da chi ha creato il file.';

  @override
  String get wrongPassword => 'Password errata. Controlla e riprova.';

  @override
  String get fileNotModified =>
      'Il file non è stato modificato. Puoi riprovare.';

  @override
  String get opening => 'Apertura…';

  @override
  String get openFile => 'Apri il file';

  @override
  String get sectionUpdated => 'Sezione aggiornata.';

  @override
  String get cardAlreadyInSection =>
      'Questa tessera c\'è già nella sezione scelta';

  @override
  String get allAlreadyInSection =>
      'Tutte le tessere ci sono già nella sezione scelta';

  @override
  String updatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tessere aggiornate',
      one: '1 tessera aggiornata',
    );
    return '$_temp0';
  }

  @override
  String noLongerInFile(int count, int days) {
    return '$count non più nel file: nel cestino per $days giorni';
  }

  @override
  String skippedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count già presenti, non si aggiungono',
      one: '1 già presente, non si aggiunge',
    );
    return '$_temp0';
  }

  @override
  String get importCardTitle => 'Importa tessera';

  @override
  String get importSectionTitle => 'Importa sezione';

  @override
  String cardReceivedOn(String date) {
    return 'Tessera ricevuta il $date';
  }

  @override
  String cardsCreatedOn(String cards, String date) {
    return '$cards · creato il $date';
  }

  @override
  String alreadyReceivedOn(String date) {
    return 'Già ricevuta il $date';
  }

  @override
  String get whichSection => 'In quale sezione';

  @override
  String get whereToPut => 'Dove metterle';

  @override
  String get newSectionDetail => 'Con un nome non ancora usato';

  @override
  String get nameNotUsedYet => 'Nome (non ancora usato)';

  @override
  String get nameAlreadyUsed => 'Questo nome è già usato da un\'altra sezione.';

  @override
  String get mergeIntoSection => 'Unisci a una sezione esistente';

  @override
  String get mergeIntoSectionDetail => 'Aggiunge solo le tessere nuove';

  @override
  String replaceSection(String name) {
    return 'Sostituisci «$name»';
  }

  @override
  String get replaceSectionDetail => 'Rimpiazza la copia ricevuta prima';

  @override
  String get importedCardYours =>
      'La tessera importata diventa tua: puoi modificarla, spostarla o eliminarla.';

  @override
  String get importedCardsYours =>
      'Le tessere importate diventano tue: puoi modificarle, spostarle o eliminarle.';

  @override
  String get importTheCard => 'Importa la tessera';

  @override
  String androidBackupTooBig(String size) {
    return 'Le foto occupano $size: il backup automatico di Android salva al massimo 25 MB e potrebbe non salvare più le tue tessere. Usa «Esporta tutto».';
  }

  @override
  String unitMB(String n) {
    return '$n MB';
  }

  @override
  String unitKB(String n) {
    return '$n KB';
  }

  @override
  String get adsIntroTitle => 'FacileCards è gratuita\ngrazie agli annunci';

  @override
  String get adsIntroSubtitle => 'Ti chiediamo come vuoi che vengano mostrati.';

  @override
  String get adLabel => 'Annuncio';

  @override
  String get adsIntroNote =>
      'Se non acconsenti, vedrai comunque annunci, ma non personalizzati.\nPotrai cambiare scelta in qualsiasi momento dalle Impostazioni.';

  @override
  String get manageAdConsent => 'Gestisci consenso annunci';

  @override
  String get adConsentNotRequired =>
      'Nel tuo paese non è richiesto un consenso per gli annunci.';
}
