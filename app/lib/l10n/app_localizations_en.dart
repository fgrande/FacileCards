// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get usedNever => 'never used';

  @override
  String get usedToday => 'used today';

  @override
  String get usedYesterday => 'used yesterday';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get aWeekAgo => 'a week ago';

  @override
  String weeksAgo(int count) {
    return '$count weeks ago';
  }

  @override
  String get aMonthAgo => 'a month ago';

  @override
  String monthsAgo(int count) {
    return '$count months ago';
  }

  @override
  String get deletedToday => 'Deleted today';

  @override
  String get deletedYesterday => 'Deleted yesterday';

  @override
  String deletedDaysAgo(int count) {
    return 'Deleted $count days ago';
  }

  @override
  String get expired => 'Expired';

  @override
  String get expiresToday => 'Expires today';

  @override
  String get expiresTomorrow => 'Expires tomorrow';

  @override
  String expiresInDays(int count) {
    return 'Expires in $count days';
  }

  @override
  String get badgeToday => 'Today';

  @override
  String get badgeTomorrow => 'Tomorrow';

  @override
  String badgeInDays(int count) {
    return 'In $count days';
  }

  @override
  String expiredOn(String date) {
    return 'Expired on $date';
  }

  @override
  String expiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String get language => 'Language';

  @override
  String get setupWelcome => 'Welcome to FacileCards';

  @override
  String get setupIntro => 'A few questions and you\'re ready.';

  @override
  String get setupNameLabel => 'Your name (optional)';

  @override
  String get setupNameHelp => 'We suggest it as the holder of new cards.';

  @override
  String get setupLanguageHelp =>
      'It\'s your phone\'s language. You can change it.';

  @override
  String get expiryAlertsTitle => 'Remind me of expiry dates';

  @override
  String get expiryAlertsSubtitle => 'For cards that have an expiry date';

  @override
  String get expiryDaysTitle => 'Days of notice';

  @override
  String get setupLater => 'You can change everything in Settings.';

  @override
  String get setupStart => 'Start';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get yourName => 'Your name';

  @override
  String get optional => 'Optional';

  @override
  String get settingsPersonal => 'Personal';

  @override
  String get nameNotSet => 'Not set';

  @override
  String get theme => 'Theme';

  @override
  String get expiryAlerts => 'Expiry reminders';

  @override
  String expiryAlertsOn(int days) {
    return '$days days before · tap to change';
  }

  @override
  String get off => 'Off';

  @override
  String get settingsVersion => 'Version';

  @override
  String get freeVersion => 'Free version';

  @override
  String freeVersionCount(int count, int limit) {
    return '$count of $limit cards · with ads';
  }

  @override
  String get purchaseComing =>
      'Purchases will be available once the app is on Google Play.';

  @override
  String get upgradePro => 'Go Pro · €2.00  →';

  @override
  String get restorePurchase => 'Restore purchase';

  @override
  String get settingsOther => 'Other';

  @override
  String get requestMissingCard => 'Request a missing card';

  @override
  String get missingCardSubject => 'Missing card in FacileCards';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get aboutApp => 'About FacileCards';

  @override
  String noAppToOpen(String url) {
    return 'There\'s no app to open $url';
  }

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Same as phone';

  @override
  String get aboutTitle => 'About';

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String developedBy(String name) {
    return 'Developed by $name';
  }

  @override
  String get trademarkDisclaimer =>
      'FacileCards is an independent app and is not affiliated with, sponsored by or endorsed by the companies mentioned. All names and trademarks belong to their respective owners.';

  @override
  String get website => 'FacileCards website';

  @override
  String cardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String countOfLimit(int count, int limit) {
    return '$count of $limit';
  }

  @override
  String get expiryTooltip => 'Expiry dates';

  @override
  String get listEmpty => 'No cards yet. Tap + and choose the shop.';

  @override
  String get listNoMatch => 'No cards found.';

  @override
  String get favorites => 'Favourites';

  @override
  String get allCards => 'All cards';

  @override
  String get viewAll => 'All';

  @override
  String get viewBySection => 'By section';

  @override
  String get sortLastUsed => 'Last used';

  @override
  String get sortName => 'Name A–Z';

  @override
  String get menuSections => 'Sections';

  @override
  String get menuData => 'Data';

  @override
  String get searchCards => 'Search cards';

  @override
  String get addCard => 'Add a card';

  @override
  String expiryPanelFooter(int days) {
    return 'Reminder $days days before expiry\nCards remain usable.';
  }

  @override
  String get photoFront => 'Front photo';

  @override
  String get photoBack => 'Back photo';

  @override
  String get moveToSection => 'Move to section';

  @override
  String get addPhoto => 'Add photo';

  @override
  String photoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String deleteCardQuestion(String name) {
    return 'Delete “$name”?';
  }

  @override
  String trashRecoverable(int days) {
    return 'It can be recovered from the bin for $days days.';
  }

  @override
  String get deleteForever => 'Delete permanently';

  @override
  String get moveToTrash => 'Move to bin';

  @override
  String get holder => 'Holder';

  @override
  String get expiry => 'Expiry date';

  @override
  String get notes => 'Notes';

  @override
  String get favorite => 'Favourite';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String formatNotDrawable(String format) {
    return 'Format cannot be drawn: $format';
  }

  @override
  String invalidCode(String error) {
    return 'Invalid code: $error';
  }

  @override
  String get move => 'Move';

  @override
  String addedOn(String date) {
    return 'Added on $date';
  }

  @override
  String get genericTypeHint => 'Code and front photo';

  @override
  String get freeNameHint => 'Name of your choice';

  @override
  String get newCard => 'New card';

  @override
  String get editCard => 'Edit card';

  @override
  String get searchShop => 'Search for a shop';

  @override
  String get shops => 'Shops';

  @override
  String get otherCards => 'Other cards';

  @override
  String get replace => 'Replace';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get anyCodeFormat => 'Any code format';

  @override
  String codeFormatIs(String format) {
    return 'Code format: $format';
  }

  @override
  String get remove => 'Remove';

  @override
  String get section => 'Section';

  @override
  String get enterCardName => 'Enter the card name.';

  @override
  String get enterCode => 'Enter or scan the code.';

  @override
  String get genericNeedsFront => 'A generic card needs a photo of the front.';

  @override
  String limitReached(int limit) {
    return 'You\'ve reached the limit of $limit cards.';
  }

  @override
  String get saving => 'Saving…';

  @override
  String get name => 'Name';

  @override
  String get code => 'Code';

  @override
  String get scan => 'Scan';

  @override
  String get fromGallery => 'From gallery';

  @override
  String get none => 'None';

  @override
  String get notesHint => 'Optional';

  @override
  String get photosFrontRequired => 'PHOTOS (FRONT REQUIRED)';

  @override
  String get photosOptional => 'PHOTOS (OPTIONAL)';

  @override
  String get addToFavorites => 'Add to favourites';

  @override
  String get sideFront => 'Front';

  @override
  String get sideBack => 'Back';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get cameraDeniedUseGallery =>
      'Camera access is not allowed: you can choose the photo from the gallery.';

  @override
  String get photoFailed => 'Couldn\'t take the photo.';

  @override
  String get notAnImage => 'The chosen file is not an image.';

  @override
  String get frontPhotoRequired =>
      'A generic card requires a front photo: you can replace it.';

  @override
  String get deleteFrontPhotoQuestion => 'Delete the front photo?';

  @override
  String get deleteBackPhotoQuestion => 'Delete the back photo?';

  @override
  String get deletePhotoExplain =>
      'The photo is removed from this card.\nThe code stays as it is.';

  @override
  String get deletePhoto => 'Delete photo';

  @override
  String get noFrontPhoto => 'No front photo';

  @override
  String get noBackPhoto => 'No back photo';

  @override
  String get swipeToBack => 'Swipe to see the back';

  @override
  String get swipeToFront => 'Swipe to go back to the front';

  @override
  String get swipeToBackZoom =>
      'Swipe to see the back · pinch to zoom\nTap the photo to close';

  @override
  String get swipeToFrontZoom =>
      'Swipe to go back to the front · pinch to zoom\nTap the photo to close';

  @override
  String get noCodeFound => 'No code found';

  @override
  String get noCodeFoundDetail =>
      'Choose a photo where the code is clearly visible.';

  @override
  String get photoReadFailed => 'Couldn\'t read the photo';

  @override
  String get tryAnotherImage => 'Try another image.';

  @override
  String get typeGeneric => 'Generic card';

  @override
  String get typeLibrary => 'Library';

  @override
  String get typeGym => 'Gym';

  @override
  String get categoryLoyalty => 'Loyalty card';

  @override
  String get categoryOther => 'Card';

  @override
  String get formatUnknown => 'Format not recognised';

  @override
  String get formatUnknownDetail => 'Try framing the code again.';

  @override
  String get thisType => 'this card type';

  @override
  String codeNotOfType(String name) {
    return 'This code doesn\'t look like $name';
  }

  @override
  String codeNotOfTypeDetail(String read, String expected) {
    return 'Check the card type or use Generic card.\nRead: $read · expected: $expected';
  }

  @override
  String get scanFrame => 'Frame the card\'s code';

  @override
  String get scanAuto => 'It reads by itself: no need to tap anything.';

  @override
  String get torch => 'Torch';

  @override
  String get enterCodeManually => 'Enter the code manually';

  @override
  String get cameraNeeded => 'Camera needed';

  @override
  String get cameraUnavailable => 'The camera is not available';

  @override
  String get cameraNeededDetail =>
      'To read a card\'s code, FacileCards uses the camera. Images stay on your phone.';

  @override
  String get cameraUnavailableDetail =>
      'You can read the code from a photo in the gallery or type it in.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get readFromGalleryPhoto => 'Read from a gallery photo';

  @override
  String get scanTitle => 'Scan the code';

  @override
  String get newSection => 'New section';

  @override
  String get renameSection => 'Rename section';

  @override
  String get sectionNameTaken =>
      'Enter a name not already used by another section.';

  @override
  String deleteQuestion(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get sectionEmpty => 'The section is empty.';

  @override
  String notDeletable(String count) {
    return '$count · can\'t be deleted';
  }

  @override
  String get emptySection => 'Empty';

  @override
  String get rename => 'Rename';

  @override
  String get deleteSection => 'Delete section';

  @override
  String sectionContains(String count) {
    return 'The section contains $count. What should we do with them?';
  }

  @override
  String get moveCardsToOtherSection => 'Move the cards to another section';

  @override
  String sectionIs(String name) {
    return 'Section: $name';
  }

  @override
  String get changeSection => 'Change section';

  @override
  String get deleteCardsToo => 'Delete the cards too';

  @override
  String staysInTrash(int days) {
    return 'They stay in the bin for $days days.';
  }

  @override
  String resultIn(String count, String section) {
    return 'Result: $count in $section';
  }

  @override
  String resultInTrash(String count) {
    return 'Result: $count in the bin';
  }

  @override
  String get sectionNameHint => 'E.g. Family';

  @override
  String get dataTitle => 'Data';

  @override
  String get archive => 'Archive';

  @override
  String get exportAll => 'Export all';

  @override
  String get exportAllSubtitle => 'Save a copy of all cards';

  @override
  String get importFromFile => 'Import from file';

  @override
  String get importFromFileSubtitle => 'A full copy, a section or a card';

  @override
  String get deletedCards => 'Deleted cards';

  @override
  String get trash => 'Bin';

  @override
  String trashSubtitle(String count, int days) {
    return '$count · deleted after $days days';
  }

  @override
  String get noBackupYet => 'You haven\'t made a copy yet.';

  @override
  String get lastCopyToday => 'Last copy: today.';

  @override
  String get lastCopyYesterday => 'Last copy: yesterday.';

  @override
  String lastCopyDaysAgo(int days) {
    return 'Last copy: $days days ago.';
  }

  @override
  String onlyOnThisPhone(String when) {
    return 'Your cards exist only on this phone.\n$when';
  }

  @override
  String noRoomLimit(int limit) {
    return 'No room: you\'ve reached the limit of $limit cards.';
  }

  @override
  String deleteForeverQuestion(String name) {
    return 'Delete “$name” forever?';
  }

  @override
  String get cannotRecover => 'It can\'t be recovered.';

  @override
  String trashExplain(int days) {
    return 'Deleted cards stay here for $days days. Tap a card to restore it.';
  }

  @override
  String get trashEmpty => 'The bin is empty.';

  @override
  String wasIn(String when, String section) {
    return '$when · was in $section';
  }

  @override
  String get deleteForeverTooltip => 'Delete forever';

  @override
  String restoreInto(String name) {
    return 'Restore “$name” to…';
  }

  @override
  String afterRestore(int count, int limit) {
    return 'After restoring: $count of $limit cards';
  }

  @override
  String get restore => 'Restore';

  @override
  String get sectionWillBeRecreated => 'Deleted section: it will be recreated';

  @override
  String get transferNotFacileCards => 'This is not a FacileCards file.';

  @override
  String get transferNotFacileCardsOrDamaged =>
      'This is not a FacileCards file, or it is damaged.';

  @override
  String get transferBadVersion => 'Invalid file version.';

  @override
  String get transferNewerVersion =>
      'The file was created by a newer version of FacileCards: please update the app.';

  @override
  String get transferBadHeader => 'Invalid file header.';

  @override
  String get transferTooBig => 'The file is too large.';

  @override
  String get transferIncomplete => 'The file is incomplete.';

  @override
  String get transferContentDamaged => 'The file content is damaged.';

  @override
  String get transferDataDamaged => 'The file data is damaged.';

  @override
  String get transferBadData => 'Invalid file data.';

  @override
  String get transferTooManyCards => 'The file contains too many cards.';

  @override
  String get transferBadSection => 'Invalid section.';

  @override
  String get transferRepeatedSection => 'Section repeated in the file.';

  @override
  String get transferBadCard => 'Invalid card.';

  @override
  String get transferRepeatedCard => 'Card repeated in the file.';

  @override
  String get transferCardWithoutSection =>
      'A card refers to a section that doesn\'t exist.';

  @override
  String get transferBadPhoto => 'Invalid photo.';

  @override
  String get transferPhotoTooBig => 'A photo is too large.';

  @override
  String get transferBadId => 'Invalid identifier in the file.';

  @override
  String get transferBadValue => 'Invalid value in the file.';

  @override
  String get transferMissingValue => 'Missing value in the file.';

  @override
  String get transferValueTooLong => 'Value too long in the file.';

  @override
  String get transferBadDate => 'Invalid date in the file.';

  @override
  String get transferProtectedDamaged => 'The protected file is damaged.';

  @override
  String get transferSectionNameTaken =>
      'Choose a name not already used by another section.';

  @override
  String transferLimitExceeded(int count, int limit) {
    return 'This import would bring you to $count cards: the limit is $limit.';
  }

  @override
  String passwordTooShort(int min) {
    return 'At least $min characters.';
  }

  @override
  String get passwordsDiffer => 'The two passwords don\'t match.';

  @override
  String aboutSize(String size) {
    return 'about $size';
  }

  @override
  String get shareSection => 'Share section';

  @override
  String get shareCard => 'Share card';

  @override
  String shareMessageCard(String name, String url) {
    return 'I\'m sending you the card “$name”.\nTo open it you need FacileCards:\n$url';
  }

  @override
  String shareMessageSection(String name, String url) {
    return 'I\'m sending you the cards in the section “$name”.\nTo open them you need FacileCards:\n$url';
  }

  @override
  String get copySaved => 'Copy saved.';

  @override
  String get copySaveFailed => 'Couldn\'t save the copy. Try again.';

  @override
  String get saveCopyTitle => 'Save the copy of your cards';

  @override
  String get backupShareText =>
      'Copy of all my FacileCards cards. Open it with the FacileCards app, from \"Import from file\".';

  @override
  String get copyPrepareFailed => 'Couldn\'t prepare the copy. Try again.';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get allYourCards => 'All your cards';

  @override
  String sectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sections',
      one: '1 section',
    );
    return '$_temp0';
  }

  @override
  String get aboutToBackup =>
      'You\'re about to create a copy of all your cards';

  @override
  String get aboutToShareCard =>
      'You\'re about to hand this card over to other people';

  @override
  String get aboutToShareCards =>
      'You\'re about to hand these cards over to other people';

  @override
  String get backupPoint1 => 'The file contains everything';

  @override
  String get backupPoint1Detail => 'Codes, holders, notes and photos.';

  @override
  String get backupPoint2 => 'Whoever opens it can use the cards';

  @override
  String get validAtCheckout => 'Valid at the checkout, just like your own.';

  @override
  String get backupPoint3 => 'Keep it somewhere safe';

  @override
  String get backupPoint3Detail => 'A personal archive, not a chat.';

  @override
  String get backupPoint4 => 'You can protect it with a password';

  @override
  String get backupPoint4Detail => 'In the next step, if you like.';

  @override
  String get sharePoint1Card => 'Whoever receives the file can use the card';

  @override
  String get sharePoint1Cards => 'Whoever receives the file can use the cards';

  @override
  String get sharePoint2Card => 'They see everything it contains';

  @override
  String get sharePoint2Cards => 'They see everything they contain';

  @override
  String get sharePoint2Detail => 'Codes, holder, notes and photos.';

  @override
  String get sharePoint3 => 'They can forward it to anyone';

  @override
  String get sharePoint3Detail => 'FacileCards can\'t prevent it.';

  @override
  String get sharePoint4 => 'You can\'t take it back';

  @override
  String get sharePoint4Detail => 'Once sent, the file is no longer yours.';

  @override
  String largeFileWarning(String size) {
    return 'The file is large ($size), mostly because of the photos: some apps might not be able to send it.';
  }

  @override
  String understoodBackup(String cards) {
    return 'I understand: I\'m exporting $cards into a single file.';
  }

  @override
  String understoodCard(String name) {
    return 'I understand: I\'m sharing the card “$name” with the people I send the file to.';
  }

  @override
  String understoodSection(String cards, String name) {
    return 'I understand: I\'m sharing $cards from the section “$name” with the people I send the file to.';
  }

  @override
  String get messageWithFile => 'Message sent with the file';

  @override
  String get passwordForgetWarning =>
      'If you forget it you won\'t be able to open the file again.\nNobody can recover it, not even us.';

  @override
  String get sharePanelHint =>
      'Your phone\'s share panel will open: you choose the app and the recipient.';

  @override
  String get hide => 'Hide';

  @override
  String get show => 'Show';

  @override
  String get protectWithPassword => 'Protect with a password';

  @override
  String get passwordOptional => 'Optional.';

  @override
  String get passwordOptionalShare =>
      'Optional: whoever opens the file will have to enter it.';

  @override
  String get password => 'Password';

  @override
  String get repeatPassword => 'Repeat the password';

  @override
  String passwordsOk(int min) {
    return 'Passwords match · at least $min characters';
  }

  @override
  String passwordRule(int min) {
    return 'At least $min characters, typed twice.';
  }

  @override
  String get continueButton => 'Continue';

  @override
  String get saveOnPhone => 'Save on phone';

  @override
  String get shareEllipsis => 'Share…';

  @override
  String get back => 'Back';

  @override
  String get cannotImport => 'Can\'t import';

  @override
  String get fileReadFailedMaybeBig =>
      'Couldn\'t read the file. It may be too large.';

  @override
  String get fileReadFailed => 'Couldn\'t read the file.';

  @override
  String get fileContentUnexpected =>
      'The file is damaged: the content is not what was expected.';

  @override
  String get replaceAllInFile =>
      'Your current cards are all in the file: they stay, with the file\'s data.';

  @override
  String trashedAll(int count, Object days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Your $count current cards will go to the bin and stay there for $days days.',
      one:
          'Your current card will go to the bin and stay there for $days days.',
    );
    return '$_temp0';
  }

  @override
  String trashedSome(int count, Object days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count current cards will go to the bin and stay there for $days days.',
      one: '1 current card will go to the bin and stay there for $days days.',
    );
    return '$_temp0';
  }

  @override
  String othersStay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The other $count are also in the file and stay.',
      one: 'The other one is also in the file and stays.',
    );
    return '$_temp0';
  }

  @override
  String get replaceAllQuestion => 'Replace all cards?';

  @override
  String aboutToReplace(String cards, int incoming) {
    return 'You\'re about to replace $cards with $incoming.';
  }

  @override
  String get trashNotCounted =>
      'Cards in the bin don\'t count towards the limit.';

  @override
  String replaceXWithY(int current, int incoming) {
    return 'Replace $current with $incoming';
  }

  @override
  String importedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards imported.',
      one: '1 card imported.',
    );
    return '$_temp0';
  }

  @override
  String get importFailedNothingChanged =>
      'Import failed: your cards have not changed.';

  @override
  String wouldBeOverLimit(int count) {
    return 'With this choice you\'d have $count cards';
  }

  @override
  String freeLimitDetail(int limit) {
    return 'The free version\'s limit is $limit.\nWith Pro there\'s no limit.';
  }

  @override
  String get allAlreadyPresent => 'All the cards in the file are already here';

  @override
  String get nothingToAdd => 'There\'s nothing to add.';

  @override
  String addsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adds $count new cards',
      one: 'Adds 1 new card',
    );
    return '$_temp0';
  }

  @override
  String alreadyPresent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count already here',
      one: '1 already here',
    );
    return '$_temp0';
  }

  @override
  String afterImport(int count, int limit) {
    return 'After the import: $count of $limit cards';
  }

  @override
  String replacesXWithY(String cards, int incoming) {
    return 'Replaces $cards with $incoming';
  }

  @override
  String get importAll => 'Import all';

  @override
  String get archiveOfApp => 'FacileCards archive';

  @override
  String archiveOf(String owner) {
    return '$owner\'s archive';
  }

  @override
  String createdOn(String date) {
    return 'Created on $date';
  }

  @override
  String get howToImport => 'How to import them';

  @override
  String get mergeWithExisting => 'Merge with existing cards';

  @override
  String get mergeWithExistingDetail =>
      'Adds only the missing ones. Recommended.';

  @override
  String get replaceAll => 'Replace all';

  @override
  String replaceAllDetail(int days) {
    return 'Current cards go to the bin for $days days.';
  }

  @override
  String get androidBackupNote =>
      'If you\'ve already restored your data with Android backup, cards that are already here won\'t be duplicated.';

  @override
  String get discoverPro => 'Discover Pro · €2.00';

  @override
  String get importButton => 'Import';

  @override
  String importCards(String cards) {
    return 'Import $cards';
  }

  @override
  String get passwordProtectedFile => 'Password-protected file';

  @override
  String get enterFilePassword =>
      'Enter the password chosen by whoever created the file.';

  @override
  String get wrongPassword => 'Wrong password. Check and try again.';

  @override
  String get fileNotModified =>
      'The file has not been changed. You can try again.';

  @override
  String get opening => 'Opening…';

  @override
  String get openFile => 'Open the file';

  @override
  String get sectionUpdated => 'Section updated.';

  @override
  String get cardAlreadyInSection =>
      'This card is already in the chosen section';

  @override
  String get allAlreadyInSection =>
      'All the cards are already in the chosen section';

  @override
  String updatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards updated',
      one: '1 card updated',
    );
    return '$_temp0';
  }

  @override
  String noLongerInFile(int count, int days) {
    return '$count no longer in the file: in the bin for $days days';
  }

  @override
  String skippedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count already here, not added',
      one: '1 already here, not added',
    );
    return '$_temp0';
  }

  @override
  String get importCardTitle => 'Import card';

  @override
  String get importSectionTitle => 'Import section';

  @override
  String cardReceivedOn(String date) {
    return 'Card received on $date';
  }

  @override
  String cardsCreatedOn(String cards, String date) {
    return '$cards · created on $date';
  }

  @override
  String alreadyReceivedOn(String date) {
    return 'Already received on $date';
  }

  @override
  String get whichSection => 'Which section';

  @override
  String get whereToPut => 'Where to put them';

  @override
  String get newSectionDetail => 'With a name not used yet';

  @override
  String get nameNotUsedYet => 'Name (not used yet)';

  @override
  String get nameAlreadyUsed => 'This name is already used by another section.';

  @override
  String get mergeIntoSection => 'Merge into an existing section';

  @override
  String get mergeIntoSectionDetail => 'Adds only the new cards';

  @override
  String replaceSection(String name) {
    return 'Replace “$name”';
  }

  @override
  String get replaceSectionDetail => 'Replaces the copy received earlier';

  @override
  String get importedCardYours =>
      'The imported card becomes yours: you can edit, move or delete it.';

  @override
  String get importedCardsYours =>
      'The imported cards become yours: you can edit, move or delete them.';

  @override
  String get importTheCard => 'Import the card';

  @override
  String androidBackupTooBig(String size) {
    return 'Your photos take up $size: Android\'s automatic backup saves at most 25 MB and may no longer save your cards. Use “Export all”.';
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
  String get adsIntroTitle => 'FacileCards is free\nthanks to ads';

  @override
  String get adsIntroSubtitle =>
      'We\'ll ask you how you\'d like them to be shown.';

  @override
  String get adLabel => 'Ad';

  @override
  String get adsIntroNote =>
      'If you don\'t consent, you\'ll still see ads, but not personalised ones.\nYou can change your choice at any time in Settings.';

  @override
  String get manageAdConsent => 'Manage ad consent';

  @override
  String get adConsentNotRequired =>
      'Ad consent is not required in your country.';

  @override
  String get payApp => 'Payment app';

  @override
  String get payAppOptional => 'Payment app (optional)';

  @override
  String get payAppSetupHelp =>
      'Opens from the card with one tap, to pay at the checkout.';

  @override
  String payAppSettingsSub(String name) {
    return '$name · opens from the card';
  }

  @override
  String get payAppIntro =>
      'Opens with one tap from the card, to pay at the checkout without leaving FacileCards.';

  @override
  String get payAppNone => 'None';

  @override
  String get payAppNoneSub => 'The button is not shown';

  @override
  String get payAppsFound => 'Found on your phone';

  @override
  String get payAppsNoneFound =>
      'We didn\'t find any payment apps on your phone.';

  @override
  String get payAppsExplain =>
      'Listed are known payment apps and those that pay by holding the phone near the card reader.';

  @override
  String get payAppMissing => 'Is your app missing? Ask us to add it';

  @override
  String get payAppMissingSubject => 'Payment app to add to FacileCards';

  @override
  String openPayApp(String name) {
    return 'Open $name';
  }

  @override
  String payAppGone(String name) {
    return '$name is no longer installed.';
  }
}
