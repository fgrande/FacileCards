// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get usedNever => 'jamais utilisée';

  @override
  String get usedToday => 'utilisée aujourd\'hui';

  @override
  String get usedYesterday => 'utilisée hier';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get aWeekAgo => 'il y a une semaine';

  @override
  String weeksAgo(int count) {
    return 'il y a $count semaines';
  }

  @override
  String get aMonthAgo => 'il y a un mois';

  @override
  String monthsAgo(int count) {
    return 'il y a $count mois';
  }

  @override
  String get deletedToday => 'Supprimée aujourd\'hui';

  @override
  String get deletedYesterday => 'Supprimée hier';

  @override
  String deletedDaysAgo(int count) {
    return 'Supprimée il y a $count jours';
  }

  @override
  String get expired => 'Expirée';

  @override
  String get expiresToday => 'Expire aujourd\'hui';

  @override
  String get expiresTomorrow => 'Expire demain';

  @override
  String expiresInDays(int count) {
    return 'Expire dans $count jours';
  }

  @override
  String get badgeToday => 'Aujourd\'hui';

  @override
  String get badgeTomorrow => 'Demain';

  @override
  String badgeInDays(int count) {
    return 'Dans $count jours';
  }

  @override
  String expiredOn(String date) {
    return 'Expirée le $date';
  }

  @override
  String expiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String get language => 'Langue';

  @override
  String get setupWelcome => 'Bienvenue dans FacileCards';

  @override
  String get setupIntro => 'Quelques questions et c\'est parti.';

  @override
  String get setupNameLabel => 'Votre nom (facultatif)';

  @override
  String get setupNameHelp =>
      'Nous le proposons comme titulaire des nouvelles cartes.';

  @override
  String get setupLanguageHelp =>
      'C\'est celle du téléphone. Vous pouvez la changer.';

  @override
  String get expiryAlertsTitle => 'M\'avertir des expirations';

  @override
  String get expiryAlertsSubtitle =>
      'Pour les cartes qui ont une date d\'expiration';

  @override
  String get expiryDaysTitle => 'Jours de préavis';

  @override
  String get setupLater => 'Vous pourrez tout modifier dans les réglages.';

  @override
  String get setupStart => 'Commencer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get close => 'Fermer';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get yourName => 'Votre nom';

  @override
  String get optional => 'Facultatif';

  @override
  String get settingsPersonal => 'Personnel';

  @override
  String get nameNotSet => 'Non indiqué';

  @override
  String get theme => 'Thème';

  @override
  String get expiryAlerts => 'Rappel d\'expiration';

  @override
  String expiryAlertsOn(int days) {
    return '$days jours avant · touchez pour modifier';
  }

  @override
  String get off => 'Désactivé';

  @override
  String get settingsVersion => 'Version';

  @override
  String get freeVersion => 'Version gratuite';

  @override
  String freeVersionCount(int count, int limit) {
    return '$count sur $limit cartes · avec publicités';
  }

  @override
  String get purchaseComing =>
      'L\'achat sera disponible lors de la publication sur Google Play.';

  @override
  String get upgradePro => 'Passer à Pro · 2,00 €  →';

  @override
  String get restorePurchase => 'Restaurer l\'achat';

  @override
  String get settingsOther => 'Autre';

  @override
  String get requestMissingCard => 'Demander une carte manquante';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutApp => 'À propos de FacileCards';

  @override
  String noAppToOpen(String url) {
    return 'Aucune application pour ouvrir $url';
  }

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Comme le téléphone';

  @override
  String get aboutTitle => 'À propos';

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String developedBy(String name) {
    return 'Développée par $name';
  }

  @override
  String get trademarkDisclaimer =>
      'FacileCards est une application indépendante, non affiliée, sponsorisée ni approuvée par les entreprises citées. Les noms et marques appartiennent à leurs propriétaires respectifs.';

  @override
  String get website => 'Site de FacileCards';

  @override
  String cardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes',
      one: '$count carte',
    );
    return '$_temp0';
  }

  @override
  String countOfLimit(int count, int limit) {
    return '$count sur $limit';
  }

  @override
  String get expiryTooltip => 'Expirations';

  @override
  String get listEmpty => 'Aucune carte. Touchez + et choisissez le magasin.';

  @override
  String get listNoMatch => 'Aucune carte trouvée.';

  @override
  String get favorites => 'Favorites';

  @override
  String get allCards => 'Toutes les cartes';

  @override
  String get viewAll => 'Toutes';

  @override
  String get viewBySection => 'Sections';

  @override
  String get sortLastUsed => 'Dernière utilisation';

  @override
  String get sortName => 'Nom A–Z';

  @override
  String get menuSections => 'Sections';

  @override
  String get menuData => 'Données';

  @override
  String get searchCards => 'Rechercher des cartes';

  @override
  String get addCard => 'Ajouter une carte';

  @override
  String expiryPanelFooter(int days) {
    return 'Rappel $days jours avant l\'expiration\nLes cartes restent utilisables.';
  }

  @override
  String get photoFront => 'Photo du recto';

  @override
  String get photoBack => 'Photo du verso';

  @override
  String get moveToSection => 'Déplacer vers la section';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String photoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '$count photo',
    );
    return '$_temp0';
  }

  @override
  String deleteCardQuestion(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String trashRecoverable(int days) {
    return 'Elle reste récupérable dans la corbeille pendant $days jours.';
  }

  @override
  String get deleteForever => 'Supprimer définitivement';

  @override
  String get moveToTrash => 'Mettre à la corbeille';

  @override
  String get holder => 'Titulaire';

  @override
  String get expiry => 'Date d\'expiration';

  @override
  String get notes => 'Notes';

  @override
  String get favorite => 'Favorite';

  @override
  String get edit => 'Modifier';

  @override
  String get share => 'Partager';

  @override
  String get delete => 'Supprimer';

  @override
  String formatNotDrawable(String format) {
    return 'Format impossible à afficher : $format';
  }

  @override
  String invalidCode(String error) {
    return 'Code non valide : $error';
  }

  @override
  String get move => 'Déplacer';

  @override
  String addedOn(String date) {
    return 'Ajoutée le $date';
  }

  @override
  String get genericTypeHint => 'Code et photo du recto';

  @override
  String get freeNameHint => 'Nom au choix';

  @override
  String get newCard => 'Nouvelle carte';

  @override
  String get editCard => 'Modifier la carte';

  @override
  String get searchShop => 'Rechercher un magasin';

  @override
  String get shops => 'Magasins';

  @override
  String get otherCards => 'Autres cartes';

  @override
  String get replace => 'Remplacer';

  @override
  String get removePhoto => 'Retirer la photo';

  @override
  String get photoEditTitle => 'Ajuster la photo';

  @override
  String get photoEditHint =>
      'Faites glisser le cadre ou ses coins · pincez pour zoomer';

  @override
  String get rotateLeft => 'Pivoter à gauche';

  @override
  String get rotateRight => 'Pivoter à droite';

  @override
  String get cardShape => 'Format carte';

  @override
  String get resetEdit => 'Réinitialiser';

  @override
  String get usePhoto => 'Utiliser';

  @override
  String get anyCodeFormat => 'Tout format de code';

  @override
  String codeFormatIs(String format) {
    return 'Format du code : $format';
  }

  @override
  String get remove => 'Retirer';

  @override
  String get section => 'Section';

  @override
  String get enterCardName => 'Saisissez le nom de la carte.';

  @override
  String get enterCode => 'Saisissez ou scannez le code.';

  @override
  String get genericNeedsFront =>
      'Une carte générique nécessite une photo du recto.';

  @override
  String limitReached(int limit) {
    return 'Vous avez atteint la limite de $limit cartes.';
  }

  @override
  String get saving => 'Enregistrement…';

  @override
  String get name => 'Nom';

  @override
  String get code => 'Code';

  @override
  String get scan => 'Scanner';

  @override
  String get fromGallery => 'Depuis la galerie';

  @override
  String get none => 'Aucune';

  @override
  String get notesHint => 'Facultatives';

  @override
  String get photosFrontRequired => 'PHOTOS (RECTO OBLIGATOIRE)';

  @override
  String get photosOptional => 'PHOTOS (FACULTATIVES)';

  @override
  String get addToFavorites => 'Ajouter aux favorites';

  @override
  String get sideFront => 'Recto';

  @override
  String get sideBack => 'Verso';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get cameraDeniedUseGallery =>
      'L\'appareil photo n\'est pas autorisé : vous pouvez choisir la photo dans la galerie.';

  @override
  String get photoFailed => 'Impossible de prendre la photo.';

  @override
  String get notAnImage => 'Le fichier choisi n\'est pas une image.';

  @override
  String get frontPhotoRequired =>
      'Pour une carte générique, la photo du recto est obligatoire : vous pouvez la remplacer.';

  @override
  String get deleteFrontPhotoQuestion => 'Supprimer la photo du recto ?';

  @override
  String get deleteBackPhotoQuestion => 'Supprimer la photo du verso ?';

  @override
  String get deletePhotoExplain =>
      'La photo est retirée de cette carte.\nLe code reste inchangé.';

  @override
  String get deletePhoto => 'Supprimer la photo';

  @override
  String get noFrontPhoto => 'Aucune photo du recto';

  @override
  String get noBackPhoto => 'Aucune photo du verso';

  @override
  String get swipeToBack => 'Faites glisser pour voir le verso';

  @override
  String get swipeToFront => 'Faites glisser pour revenir au recto';

  @override
  String get swipeToBackZoom =>
      'Faites glisser pour voir le verso · pincez pour zoomer\nTouchez la photo pour fermer';

  @override
  String get swipeToFrontZoom =>
      'Faites glisser pour revenir au recto · pincez pour zoomer\nTouchez la photo pour fermer';

  @override
  String get noCodeFound => 'Aucun code trouvé';

  @override
  String get noCodeFoundDetail =>
      'Choisissez une photo où le code est bien visible.';

  @override
  String get photoReadFailed => 'Impossible de lire la photo';

  @override
  String get tryAnotherImage => 'Essayez avec une autre image.';

  @override
  String get typeGeneric => 'Carte générique';

  @override
  String get typeLibrary => 'Bibliothèque';

  @override
  String get typeGym => 'Salle de sport';

  @override
  String get categoryLoyalty => 'Carte de fidélité';

  @override
  String get categoryOther => 'Carte';

  @override
  String get formatUnknown => 'Format non reconnu';

  @override
  String get formatUnknownDetail => 'Essayez de cadrer à nouveau le code.';

  @override
  String get thisType => 'ce type de carte';

  @override
  String codeNotOfType(String name) {
    return 'Ce code ne semble pas être de $name';
  }

  @override
  String codeNotOfTypeDetail(String read, String expected) {
    return 'Vérifiez le type de carte ou utilisez Carte générique.\nLu : $read · attendu : $expected';
  }

  @override
  String get scanFrame => 'Cadrez le code de la carte';

  @override
  String get scanAuto =>
      'La lecture est automatique : inutile de toucher quoi que ce soit.';

  @override
  String get torch => 'Lampe';

  @override
  String get enterCodeManually => 'Saisir le code à la main';

  @override
  String get cameraNeeded => 'Appareil photo nécessaire';

  @override
  String get cameraUnavailable => 'L\'appareil photo n\'est pas disponible';

  @override
  String get cameraNeededDetail =>
      'Pour lire le code d\'une carte, FacileCards utilise l\'appareil photo. Les images restent sur le téléphone.';

  @override
  String get cameraUnavailableDetail =>
      'Vous pouvez lire le code depuis une photo de la galerie ou le saisir à la main.';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get readFromGalleryPhoto => 'Lire depuis une photo de la galerie';

  @override
  String get scanTitle => 'Scanner le code';

  @override
  String get newSection => 'Nouvelle section';

  @override
  String get renameSection => 'Renommer la section';

  @override
  String get sectionNameTaken =>
      'Saisissez un nom qui n\'est pas déjà utilisé par une autre section.';

  @override
  String deleteQuestion(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get sectionEmpty => 'La section est vide.';

  @override
  String notDeletable(String count) {
    return '$count · non supprimable';
  }

  @override
  String get emptySection => 'Vide';

  @override
  String get rename => 'Renommer';

  @override
  String get deleteSection => 'Supprimer la section';

  @override
  String sectionContains(String count) {
    return 'La section contient $count. Qu\'en faisons-nous ?';
  }

  @override
  String get moveCardsToOtherSection =>
      'Déplacer les cartes vers une autre section';

  @override
  String sectionIs(String name) {
    return 'Section : $name';
  }

  @override
  String get changeSection => 'Changer de section';

  @override
  String get deleteCardsToo => 'Supprimer aussi les cartes';

  @override
  String staysInTrash(int days) {
    return 'Elles restent $days jours dans la corbeille.';
  }

  @override
  String resultIn(String count, String section) {
    return 'Résultat : $count dans $section';
  }

  @override
  String resultInTrash(String count) {
    return 'Résultat : $count dans la corbeille';
  }

  @override
  String get sectionNameHint => 'Ex. Famille';

  @override
  String get dataTitle => 'Données';

  @override
  String get archive => 'Archive';

  @override
  String get exportAll => 'Tout exporter';

  @override
  String get exportAllSubtitle => 'Enregistrer une copie de toutes les cartes';

  @override
  String get importFromFile => 'Importer depuis un fichier';

  @override
  String get importFromFileSubtitle =>
      'Une copie complète, une section ou une carte';

  @override
  String get deletedCards => 'Cartes supprimées';

  @override
  String get trash => 'Corbeille';

  @override
  String trashSubtitle(String count, int days) {
    return '$count · supprimées après $days jours';
  }

  @override
  String get noBackupYet => 'Vous n\'avez pas encore fait de copie.';

  @override
  String get lastCopyToday => 'Dernière copie : aujourd\'hui.';

  @override
  String get lastCopyYesterday => 'Dernière copie : hier.';

  @override
  String lastCopyDaysAgo(int days) {
    return 'Dernière copie : il y a $days jours.';
  }

  @override
  String onlyOnThisPhone(String when) {
    return 'Vos cartes n\'existent que sur ce téléphone.\n$when';
  }

  @override
  String noRoomLimit(int limit) {
    return 'Plus de place : vous avez atteint la limite de $limit cartes.';
  }

  @override
  String deleteForeverQuestion(String name) {
    return 'Supprimer « $name » définitivement ?';
  }

  @override
  String get cannotRecover => 'Elle ne pourra plus être récupérée.';

  @override
  String trashExplain(int days) {
    return 'Les cartes supprimées restent ici $days jours. Touchez une carte pour la récupérer.';
  }

  @override
  String get trashEmpty => 'La corbeille est vide.';

  @override
  String wasIn(String when, String section) {
    return '$when · était dans $section';
  }

  @override
  String get deleteForeverTooltip => 'Supprimer définitivement';

  @override
  String restoreInto(String name) {
    return 'Récupérer « $name » dans…';
  }

  @override
  String afterRestore(int count, int limit) {
    return 'Après récupération : $count sur $limit cartes';
  }

  @override
  String get restore => 'Récupérer';

  @override
  String get sectionWillBeRecreated => 'Section supprimée : elle sera recréée';

  @override
  String get transferNotFacileCards => 'Ce n\'est pas un fichier FacileCards.';

  @override
  String get transferNotFacileCardsOrDamaged =>
      'Ce n\'est pas un fichier FacileCards, ou il est endommagé.';

  @override
  String get transferBadVersion => 'Version du fichier non valide.';

  @override
  String get transferNewerVersion =>
      'Le fichier a été créé par une version plus récente de FacileCards : mettez l\'application à jour.';

  @override
  String get transferBadHeader => 'En-tête du fichier non valide.';

  @override
  String get transferTooBig => 'Le fichier est trop volumineux.';

  @override
  String get transferIncomplete => 'Le fichier est incomplet.';

  @override
  String get transferContentDamaged => 'Le contenu du fichier est endommagé.';

  @override
  String get transferDataDamaged => 'Les données du fichier sont endommagées.';

  @override
  String get transferBadData => 'Données du fichier non valides.';

  @override
  String get transferTooManyCards => 'Le fichier contient trop de cartes.';

  @override
  String get transferBadSection => 'Section non valide.';

  @override
  String get transferRepeatedSection => 'Section répétée dans le fichier.';

  @override
  String get transferBadCard => 'Carte non valide.';

  @override
  String get transferRepeatedCard => 'Carte répétée dans le fichier.';

  @override
  String get transferCardWithoutSection =>
      'Une carte fait référence à une section qui n\'existe pas.';

  @override
  String get transferBadPhoto => 'Photo non valide.';

  @override
  String get transferPhotoTooBig => 'Une photo est trop volumineuse.';

  @override
  String get transferBadId => 'Identifiant non valide dans le fichier.';

  @override
  String get transferBadValue => 'Donnée non valide dans le fichier.';

  @override
  String get transferMissingValue => 'Donnée manquante dans le fichier.';

  @override
  String get transferValueTooLong => 'Donnée trop longue dans le fichier.';

  @override
  String get transferBadDate => 'Date non valide dans le fichier.';

  @override
  String get transferProtectedDamaged => 'Le fichier protégé est endommagé.';

  @override
  String get transferSectionNameTaken =>
      'Choisissez un nom qui n\'est pas déjà utilisé par une autre section.';

  @override
  String transferLimitExceeded(int count, int limit) {
    return 'Avec cette importation, vous auriez $count cartes : la limite est de $limit.';
  }

  @override
  String passwordTooShort(int min) {
    return 'Au moins $min caractères.';
  }

  @override
  String get passwordsDiffer =>
      'Les deux mots de passe ne sont pas identiques.';

  @override
  String aboutSize(String size) {
    return 'environ $size';
  }

  @override
  String get shareSection => 'Partager la section';

  @override
  String get shareCard => 'Partager la carte';

  @override
  String shareMessageCard(String name, String url) {
    return 'Je t\'envoie la carte « $name ».\nPour l\'ouvrir, il faut FacileCards :\n$url';
  }

  @override
  String shareMessageSection(String name, String url) {
    return 'Je t\'envoie les cartes de la section « $name ».\nPour les ouvrir, il faut FacileCards :\n$url';
  }

  @override
  String get copySaved => 'Copie enregistrée.';

  @override
  String get copySaveFailed => 'Impossible d\'enregistrer la copie. Réessayez.';

  @override
  String get saveCopyTitle => 'Enregistrer la copie des cartes';

  @override
  String get backupShareText =>
      'Copie de toutes mes cartes FacileCards. Elle s\'ouvre avec l\'application FacileCards, depuis « Importer depuis un fichier ».';

  @override
  String get copyPrepareFailed => 'Impossible de préparer la copie. Réessayez.';

  @override
  String stepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get allYourCards => 'Toutes vos cartes';

  @override
  String sectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sections',
      one: '$count section',
    );
    return '$_temp0';
  }

  @override
  String get aboutToBackup => 'Vous allez créer une copie de toutes vos cartes';

  @override
  String get aboutToShareCard =>
      'Vous allez remettre cette carte à d\'autres personnes';

  @override
  String get aboutToShareCards =>
      'Vous allez remettre ces cartes à d\'autres personnes';

  @override
  String get backupPoint1 => 'Le fichier contient tout';

  @override
  String get backupPoint1Detail => 'Codes, titulaires, notes et photos.';

  @override
  String get backupPoint2 => 'Qui l\'ouvre peut utiliser les cartes';

  @override
  String get validAtCheckout => 'Utilisable en caisse comme si c\'était vous.';

  @override
  String get backupPoint3 => 'Conservez-le dans un endroit sûr';

  @override
  String get backupPoint3Detail => 'Un espace personnel, pas une discussion.';

  @override
  String get backupPoint4 => 'Vous pouvez le protéger par un mot de passe';

  @override
  String get backupPoint4Detail => 'À l\'étape suivante, si vous le souhaitez.';

  @override
  String get sharePoint1Card => 'Qui reçoit le fichier peut utiliser la carte';

  @override
  String get sharePoint1Cards =>
      'Qui reçoit le fichier peut utiliser les cartes';

  @override
  String get sharePoint2Card => 'Il voit tout ce qu\'elle contient';

  @override
  String get sharePoint2Cards => 'Il voit tout ce qu\'elles contiennent';

  @override
  String get sharePoint2Detail => 'Codes, titulaire, notes et photos.';

  @override
  String get sharePoint3 => 'Il peut le transférer à n\'importe qui';

  @override
  String get sharePoint3Detail => 'FacileCards ne peut pas l\'empêcher.';

  @override
  String get sharePoint4 => 'Vous ne pouvez pas le reprendre';

  @override
  String get sharePoint4Detail =>
      'Une fois envoyé, le fichier ne vous appartient plus.';

  @override
  String largeFileWarning(String size) {
    return 'Le fichier est volumineux ($size), surtout à cause des photos : certaines applications pourraient ne pas réussir à l\'envoyer.';
  }

  @override
  String understoodBackup(String cards) {
    return 'J\'ai compris : j\'exporte $cards dans un seul fichier.';
  }

  @override
  String understoodCard(String name) {
    return 'J\'ai compris : je partage la carte « $name » avec les personnes à qui j\'enverrai le fichier.';
  }

  @override
  String understoodSection(String cards, String name) {
    return 'J\'ai compris : je partage $cards de la section « $name » avec les personnes à qui j\'enverrai le fichier.';
  }

  @override
  String get messageWithFile => 'Message accompagnant le fichier';

  @override
  String get passwordForgetWarning =>
      'Si vous l\'oubliez, vous ne pourrez plus ouvrir le fichier.\nPersonne ne peut le récupérer, pas même nous.';

  @override
  String get sharePanelHint =>
      'Le panneau de partage du téléphone va s\'ouvrir : vous choisissez l\'application et le destinataire.';

  @override
  String get hide => 'Masquer';

  @override
  String get show => 'Afficher';

  @override
  String get protectWithPassword => 'Protéger par un mot de passe';

  @override
  String get passwordOptional => 'Facultatif.';

  @override
  String get passwordOptionalShare =>
      'Facultatif : qui ouvre le fichier devra le saisir.';

  @override
  String get password => 'Mot de passe';

  @override
  String get repeatPassword => 'Répétez le mot de passe';

  @override
  String passwordsOk(int min) {
    return 'Mots de passe identiques · au moins $min caractères';
  }

  @override
  String passwordRule(int min) {
    return 'Au moins $min caractères, saisi deux fois.';
  }

  @override
  String get continueButton => 'Continuer';

  @override
  String get saveOnPhone => 'Enregistrer sur le téléphone';

  @override
  String get shareEllipsis => 'Partager…';

  @override
  String get back => 'Retour';

  @override
  String get cannotImport => 'Importation impossible';

  @override
  String get fileReadFailedMaybeBig =>
      'Impossible de lire le fichier. Il est peut-être trop volumineux.';

  @override
  String get fileReadFailed => 'Impossible de lire le fichier.';

  @override
  String get fileContentUnexpected =>
      'Le fichier est endommagé : le contenu n\'est pas celui attendu.';

  @override
  String get replaceAllInFile =>
      'Vos cartes actuelles sont toutes dans le fichier : elles restent, avec les données du fichier.';

  @override
  String trashedAll(int count, Object days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Vos $count cartes actuelles iront dans la corbeille et y resteront $days jours.',
      one:
          'Votre carte actuelle ira dans la corbeille et y restera $days jours.',
    );
    return '$_temp0';
  }

  @override
  String trashedSome(int count, Object days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count cartes actuelles iront dans la corbeille et y resteront $days jours.',
      one:
          '$count carte actuelle ira dans la corbeille et y restera $days jours.',
    );
    return '$_temp0';
  }

  @override
  String othersStay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les $count autres sont aussi dans le fichier et restent.',
      one: 'L\'autre est aussi dans le fichier et reste.',
    );
    return '$_temp0';
  }

  @override
  String get replaceAllQuestion => 'Remplacer toutes les cartes ?';

  @override
  String aboutToReplace(String cards, int incoming) {
    return 'Vous allez remplacer $cards par $incoming.';
  }

  @override
  String get trashNotCounted =>
      'Les cartes de la corbeille ne comptent pas dans la limite.';

  @override
  String replaceXWithY(int current, int incoming) {
    return 'Remplacer $current par $incoming';
  }

  @override
  String importedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes importées.',
      one: '$count carte importée.',
    );
    return '$_temp0';
  }

  @override
  String get importFailedNothingChanged =>
      'Échec de l\'importation : vos cartes n\'ont pas changé.';

  @override
  String wouldBeOverLimit(int count) {
    return 'Avec ce choix, vous auriez $count cartes';
  }

  @override
  String freeLimitDetail(int limit) {
    return 'La limite de la version gratuite est de $limit.\nAvec Pro, aucune limite.';
  }

  @override
  String get allAlreadyPresent =>
      'Toutes les cartes du fichier sont déjà présentes';

  @override
  String get nothingToAdd => 'Il n\'y a rien à ajouter.';

  @override
  String addsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajoute $count nouvelles cartes',
      one: 'Ajoute 1 nouvelle carte',
    );
    return '$_temp0';
  }

  @override
  String alreadyPresent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count déjà présentes',
      one: '$count déjà présente',
    );
    return '$_temp0';
  }

  @override
  String afterImport(int count, int limit) {
    return 'Après l\'importation : $count sur $limit cartes';
  }

  @override
  String replacesXWithY(String cards, int incoming) {
    return 'Remplace $cards par $incoming';
  }

  @override
  String get importAll => 'Tout importer';

  @override
  String get archiveOfApp => 'Archive FacileCards';

  @override
  String archiveOf(String owner) {
    return 'Archive de $owner';
  }

  @override
  String createdOn(String date) {
    return 'Créé le $date';
  }

  @override
  String get howToImport => 'Comment les importer';

  @override
  String get mergeWithExisting => 'Fusionner avec les cartes existantes';

  @override
  String get mergeWithExistingDetail =>
      'N\'ajoute que celles qui manquent. Recommandé.';

  @override
  String get replaceAll => 'Tout remplacer';

  @override
  String replaceAllDetail(int days) {
    return 'Les cartes actuelles vont dans la corbeille pendant $days jours.';
  }

  @override
  String get androidBackupNote =>
      'Si vous avez déjà restauré vos données avec la sauvegarde Android, les cartes déjà présentes ne sont pas dupliquées.';

  @override
  String get discoverPro => 'Découvrir Pro · 2,00 €';

  @override
  String get importButton => 'Importer';

  @override
  String importCards(String cards) {
    return 'Importer $cards';
  }

  @override
  String get passwordProtectedFile => 'Fichier protégé par mot de passe';

  @override
  String get enterFilePassword =>
      'Saisissez le mot de passe choisi par la personne qui a créé le fichier.';

  @override
  String get wrongPassword => 'Mot de passe incorrect. Vérifiez et réessayez.';

  @override
  String get fileNotModified =>
      'Le fichier n\'a pas été modifié. Vous pouvez réessayer.';

  @override
  String get opening => 'Ouverture…';

  @override
  String get openFile => 'Ouvrir le fichier';

  @override
  String get sectionUpdated => 'Section mise à jour.';

  @override
  String get cardAlreadyInSection =>
      'Cette carte est déjà dans la section choisie';

  @override
  String get allAlreadyInSection =>
      'Toutes les cartes sont déjà dans la section choisie';

  @override
  String updatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes mises à jour',
      one: '$count carte mise à jour',
    );
    return '$_temp0';
  }

  @override
  String noLongerInFile(int count, int days) {
    return '$count plus dans le fichier : dans la corbeille pendant $days jours';
  }

  @override
  String skippedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count déjà présentes, non ajoutées',
      one: '$count déjà présente, non ajoutée',
    );
    return '$_temp0';
  }

  @override
  String get importCardTitle => 'Importer la carte';

  @override
  String get importSectionTitle => 'Importer la section';

  @override
  String cardReceivedOn(String date) {
    return 'Carte reçue le $date';
  }

  @override
  String cardsCreatedOn(String cards, String date) {
    return '$cards · créé le $date';
  }

  @override
  String alreadyReceivedOn(String date) {
    return 'Déjà reçue le $date';
  }

  @override
  String get whichSection => 'Dans quelle section';

  @override
  String get whereToPut => 'Où les mettre';

  @override
  String get newSectionDetail => 'Avec un nom pas encore utilisé';

  @override
  String get nameNotUsedYet => 'Nom (pas encore utilisé)';

  @override
  String get nameAlreadyUsed =>
      'Ce nom est déjà utilisé par une autre section.';

  @override
  String get mergeIntoSection => 'Fusionner avec une section existante';

  @override
  String get mergeIntoSectionDetail => 'N\'ajoute que les nouvelles cartes';

  @override
  String replaceSection(String name) {
    return 'Remplacer « $name »';
  }

  @override
  String get replaceSectionDetail => 'Remplace la copie reçue auparavant';

  @override
  String get importedCardYours =>
      'La carte importée devient la vôtre : vous pouvez la modifier, la déplacer ou la supprimer.';

  @override
  String get importedCardsYours =>
      'Les cartes importées deviennent les vôtres : vous pouvez les modifier, les déplacer ou les supprimer.';

  @override
  String get importTheCard => 'Importer la carte';

  @override
  String androidBackupTooBig(String size) {
    return 'Les photos occupent $size : la sauvegarde automatique d\'Android enregistre au maximum 25 Mo et pourrait ne plus enregistrer vos cartes. Utilisez « Tout exporter ».';
  }

  @override
  String unitMB(String n) {
    return '$n Mo';
  }

  @override
  String unitKB(String n) {
    return '$n Ko';
  }

  @override
  String get adsIntroTitle => 'FacileCards est gratuite\ngrâce aux publicités';

  @override
  String get adsIntroSubtitle =>
      'Nous vous demandons comment vous souhaitez qu\'elles soient affichées.';

  @override
  String get adLabel => 'Annonce';

  @override
  String get adsIntroNote =>
      'Si vous refusez, vous verrez quand même des publicités, mais non personnalisées.\nVous pourrez modifier votre choix à tout moment dans les réglages.';

  @override
  String get manageAdConsent => 'Gérer le consentement aux publicités';

  @override
  String get adConsentNotRequired =>
      'Le consentement aux publicités n\'est pas requis dans votre pays.';

  @override
  String get payApp => 'Appli de paiement';

  @override
  String get payAppOptional => 'Appli de paiement (facultative)';

  @override
  String get payAppSetupHelp =>
      'S\'ouvre depuis la carte d\'un simple toucher, pour payer en caisse.';

  @override
  String payAppSettingsSub(String name) {
    return '$name · s\'ouvre depuis la carte';
  }

  @override
  String get payAppIntro =>
      'S\'ouvre d\'un toucher depuis la carte, pour payer en caisse sans quitter FacileCards.';

  @override
  String get payAppNone => 'Aucune';

  @override
  String get payAppNoneSub => 'Le bouton n\'apparaît pas';

  @override
  String get payAppsFound => 'Trouvées sur le téléphone';

  @override
  String get payAppsNoneFound =>
      'Nous n\'avons trouvé aucune appli de paiement sur le téléphone.';

  @override
  String get payAppsExplain =>
      'Sont listées les applis de paiement connues et celles qui paient en approchant le téléphone du terminal.';

  @override
  String get payAppMissing => 'Votre appli manque ? Demandez de l\'ajouter';

  @override
  String get payAppMissingSubject =>
      'Appli de paiement à ajouter à FacileCards';

  @override
  String openPayApp(String name) {
    return 'Ouvrir $name';
  }

  @override
  String payAppGone(String name) {
    return '$name n\'est plus installée.';
  }

  @override
  String get cfInvalid => 'Code fiscal non valide';

  @override
  String get cfInvalidDetail =>
      'Le code lu ne correspond pas à son caractère de contrôle : cadrez mieux et réessayez.';

  @override
  String get cfInvalidTyped =>
      'Code fiscal non valide : vérifiez qu\'il est bien saisi (16 caractères, le dernier est une lettre de contrôle).';

  @override
  String get requestTitle => 'Demander une carte';

  @override
  String get requestIntro =>
      'Dites-nous quelle carte manque : nous l\'ajouterons à la liste des magasins.';

  @override
  String get requestShopName => 'Nom du magasin';

  @override
  String get requestCodeHeader => 'Code de la carte (facultatif)';

  @override
  String get requestCodeExplain =>
      'Si vous le lisez, la demande contient le format du code : la carte sera ajoutée plus vite.';

  @override
  String requestFormatRead(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caractères',
      one: '1 caractère',
    );
    return 'Format : $label · $_temp0';
  }

  @override
  String get requestCodeStays => 'Le code reste sur le téléphone.';

  @override
  String get requestPhotoHint =>
      'Dans l\'e-mail, vous pouvez joindre une photo du logo de la carte, pour les couleurs. Sans le code.';

  @override
  String get requestMailHint =>
      'Votre appli de messagerie s\'ouvre : vérifiez le message et envoyez-le vous-même.';

  @override
  String get requestWriteMail => 'Écrire l\'e-mail';

  @override
  String get requestNoMailApp =>
      'Aucune appli de messagerie trouvée sur le téléphone.';

  @override
  String requestMailSubject(String shop) {
    return 'Carte manquante : $shop';
  }

  @override
  String requestMailBody(
    String shop,
    String format,
    String language,
    String version,
  ) {
    return 'Magasin : $shop\nFormat du code : $format\nLangue : $language · Version : $version\n\nSi possible, joignez une photo du logo de la carte (sans le code).';
  }

  @override
  String requestFormatValue(String label, String id, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caractères',
      one: '1 caractère',
    );
    return '$label ($id), $_temp0';
  }

  @override
  String get requestFormatNotRead => 'non lu';

  @override
  String notFoundQuery(String query) {
    return 'Vous ne trouvez pas « $query » ?';
  }

  @override
  String get notFoundAsk => 'Demandez à l\'ajouter';

  @override
  String get notFoundShop => 'Vous ne trouvez pas votre magasin ?';

  @override
  String get requestCodeNotSent =>
      'Le code n\'est jamais envoyé : seulement le format.';

  @override
  String get addToHome => 'Ajouter à l\'écran d\'accueil';

  @override
  String get shortcutAdded => 'Icône ajoutée à l\'écran d\'accueil';

  @override
  String get shortcutFailed => 'Impossible d\'ajouter l\'icône';

  @override
  String get shortcutInTrashTitle => 'Cette carte est dans la corbeille';

  @override
  String shortcutInTrashBody(String name, String when) {
    return '« $name » : $when.\nVous pouvez la restaurer ou supprimer le raccourci de l\'écran d\'accueil.';
  }

  @override
  String get shortcutGoneTitle => 'Cette carte n\'existe plus';

  @override
  String shortcutGoneBody(String name) {
    return '« $name » a été supprimée. Vous pouvez supprimer le raccourci de l\'écran d\'accueil.';
  }

  @override
  String get restoreCard => 'Restaurer la carte';

  @override
  String get deleteShortcut => 'Supprimer le raccourci';

  @override
  String get shortcutDisabled =>
      'Raccourci désactivé. Pour le retirer de l\'écran d\'accueil, appuyez longuement sur l\'icône et choisissez Supprimer.';
}
