import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @usedNever.
  ///
  /// In it, this message translates to:
  /// **'mai usata'**
  String get usedNever;

  /// No description provided for @usedToday.
  ///
  /// In it, this message translates to:
  /// **'usata oggi'**
  String get usedToday;

  /// No description provided for @usedYesterday.
  ///
  /// In it, this message translates to:
  /// **'usata ieri'**
  String get usedYesterday;

  /// No description provided for @daysAgo.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 giorno fa} other{{count} giorni fa}}'**
  String daysAgo(int count);

  /// No description provided for @aWeekAgo.
  ///
  /// In it, this message translates to:
  /// **'una settimana fa'**
  String get aWeekAgo;

  /// No description provided for @weeksAgo.
  ///
  /// In it, this message translates to:
  /// **'{count} settimane fa'**
  String weeksAgo(int count);

  /// No description provided for @aMonthAgo.
  ///
  /// In it, this message translates to:
  /// **'un mese fa'**
  String get aMonthAgo;

  /// No description provided for @monthsAgo.
  ///
  /// In it, this message translates to:
  /// **'{count} mesi fa'**
  String monthsAgo(int count);

  /// No description provided for @deletedToday.
  ///
  /// In it, this message translates to:
  /// **'Eliminata oggi'**
  String get deletedToday;

  /// No description provided for @deletedYesterday.
  ///
  /// In it, this message translates to:
  /// **'Eliminata ieri'**
  String get deletedYesterday;

  /// No description provided for @deletedDaysAgo.
  ///
  /// In it, this message translates to:
  /// **'Eliminata {count} giorni fa'**
  String deletedDaysAgo(int count);

  /// No description provided for @expired.
  ///
  /// In it, this message translates to:
  /// **'Scaduta'**
  String get expired;

  /// No description provided for @expiresToday.
  ///
  /// In it, this message translates to:
  /// **'Scade oggi'**
  String get expiresToday;

  /// No description provided for @expiresTomorrow.
  ///
  /// In it, this message translates to:
  /// **'Scade domani'**
  String get expiresTomorrow;

  /// No description provided for @expiresInDays.
  ///
  /// In it, this message translates to:
  /// **'Scade tra {count} giorni'**
  String expiresInDays(int count);

  /// No description provided for @badgeToday.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get badgeToday;

  /// No description provided for @badgeTomorrow.
  ///
  /// In it, this message translates to:
  /// **'Domani'**
  String get badgeTomorrow;

  /// No description provided for @badgeInDays.
  ///
  /// In it, this message translates to:
  /// **'Tra {count} giorni'**
  String badgeInDays(int count);

  /// No description provided for @expiredOn.
  ///
  /// In it, this message translates to:
  /// **'Scaduta il {date}'**
  String expiredOn(String date);

  /// No description provided for @expiresOn.
  ///
  /// In it, this message translates to:
  /// **'Scade il {date}'**
  String expiresOn(String date);

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @setupWelcome.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto in FacileCards'**
  String get setupWelcome;

  /// No description provided for @setupIntro.
  ///
  /// In it, this message translates to:
  /// **'Tre domande e sei pronto.'**
  String get setupIntro;

  /// No description provided for @setupNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Il tuo nome (facoltativo)'**
  String get setupNameLabel;

  /// No description provided for @setupNameHelp.
  ///
  /// In it, this message translates to:
  /// **'Lo proponiamo come intestatario delle nuove tessere.'**
  String get setupNameHelp;

  /// No description provided for @setupLanguageHelp.
  ///
  /// In it, this message translates to:
  /// **'È quella del telefono. Puoi cambiarla.'**
  String get setupLanguageHelp;

  /// No description provided for @expiryAlertsTitle.
  ///
  /// In it, this message translates to:
  /// **'Avvisami delle scadenze'**
  String get expiryAlertsTitle;

  /// No description provided for @expiryAlertsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Per le tessere che hanno una data di scadenza'**
  String get expiryAlertsSubtitle;

  /// No description provided for @expiryDaysTitle.
  ///
  /// In it, this message translates to:
  /// **'Giorni di preavviso'**
  String get expiryDaysTitle;

  /// No description provided for @setupLater.
  ///
  /// In it, this message translates to:
  /// **'Potrai cambiare tutto dalle impostazioni.'**
  String get setupLater;

  /// No description provided for @setupStart.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get setupStart;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTitle;

  /// No description provided for @yourName.
  ///
  /// In it, this message translates to:
  /// **'Il tuo nome'**
  String get yourName;

  /// No description provided for @optional.
  ///
  /// In it, this message translates to:
  /// **'Facoltativo'**
  String get optional;

  /// No description provided for @settingsPersonal.
  ///
  /// In it, this message translates to:
  /// **'Personali'**
  String get settingsPersonal;

  /// No description provided for @nameNotSet.
  ///
  /// In it, this message translates to:
  /// **'Non indicato'**
  String get nameNotSet;

  /// No description provided for @theme.
  ///
  /// In it, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @expiryAlerts.
  ///
  /// In it, this message translates to:
  /// **'Avviso scadenze'**
  String get expiryAlerts;

  /// No description provided for @expiryAlertsOn.
  ///
  /// In it, this message translates to:
  /// **'{days} giorni prima · tocca per cambiare'**
  String expiryAlertsOn(int days);

  /// No description provided for @off.
  ///
  /// In it, this message translates to:
  /// **'Spento'**
  String get off;

  /// No description provided for @settingsVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione'**
  String get settingsVersion;

  /// No description provided for @freeVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione gratuita'**
  String get freeVersion;

  /// No description provided for @freeVersionCount.
  ///
  /// In it, this message translates to:
  /// **'{count} di {limit} tessere · con annunci'**
  String freeVersionCount(int count, int limit);

  /// No description provided for @purchaseComing.
  ///
  /// In it, this message translates to:
  /// **'L\'acquisto arriverà con la pubblicazione su Google Play.'**
  String get purchaseComing;

  /// No description provided for @upgradePro.
  ///
  /// In it, this message translates to:
  /// **'Passa a Pro · 2,00 €  →'**
  String get upgradePro;

  /// No description provided for @restorePurchase.
  ///
  /// In it, this message translates to:
  /// **'Ripristina acquisto'**
  String get restorePurchase;

  /// No description provided for @settingsOther.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get settingsOther;

  /// No description provided for @requestMissingCard.
  ///
  /// In it, this message translates to:
  /// **'Richiedi una tessera mancante'**
  String get requestMissingCard;

  /// No description provided for @missingCardSubject.
  ///
  /// In it, this message translates to:
  /// **'Tessera mancante in FacileCards'**
  String get missingCardSubject;

  /// No description provided for @privacyPolicy.
  ///
  /// In it, this message translates to:
  /// **'Informativa sulla privacy'**
  String get privacyPolicy;

  /// No description provided for @aboutApp.
  ///
  /// In it, this message translates to:
  /// **'Informazioni su FacileCards'**
  String get aboutApp;

  /// No description provided for @noAppToOpen.
  ///
  /// In it, this message translates to:
  /// **'Non c\'è un\'app per aprire {url}'**
  String noAppToOpen(String url);

  /// No description provided for @themeLight.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In it, this message translates to:
  /// **'Come il telefono'**
  String get themeSystem;

  /// No description provided for @aboutTitle.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get aboutTitle;

  /// No description provided for @versionNumber.
  ///
  /// In it, this message translates to:
  /// **'Versione {version}'**
  String versionNumber(String version);

  /// No description provided for @developedBy.
  ///
  /// In it, this message translates to:
  /// **'Sviluppata da {name}'**
  String developedBy(String name);

  /// No description provided for @trademarkDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'FacileCards è un\'app indipendente e non è affiliata, sponsorizzata né approvata dalle aziende citate. I nomi e i marchi appartengono ai rispettivi proprietari.'**
  String get trademarkDisclaimer;

  /// No description provided for @website.
  ///
  /// In it, this message translates to:
  /// **'Sito di FacileCards'**
  String get website;

  /// No description provided for @cardCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 tessera} other{{count} tessere}}'**
  String cardCount(int count);

  /// No description provided for @countOfLimit.
  ///
  /// In it, this message translates to:
  /// **'{count} di {limit}'**
  String countOfLimit(int count, int limit);

  /// No description provided for @expiryTooltip.
  ///
  /// In it, this message translates to:
  /// **'Scadenze'**
  String get expiryTooltip;

  /// No description provided for @listEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna tessera. Tocca + e scegli il negozio.'**
  String get listEmpty;

  /// No description provided for @listNoMatch.
  ///
  /// In it, this message translates to:
  /// **'Nessuna tessera trovata.'**
  String get listNoMatch;

  /// No description provided for @favorites.
  ///
  /// In it, this message translates to:
  /// **'Preferite'**
  String get favorites;

  /// No description provided for @allCards.
  ///
  /// In it, this message translates to:
  /// **'Tutte le tessere'**
  String get allCards;

  /// No description provided for @viewAll.
  ///
  /// In it, this message translates to:
  /// **'Tutte'**
  String get viewAll;

  /// No description provided for @viewBySection.
  ///
  /// In it, this message translates to:
  /// **'Per sezione'**
  String get viewBySection;

  /// No description provided for @sortLastUsed.
  ///
  /// In it, this message translates to:
  /// **'Ultimo utilizzo'**
  String get sortLastUsed;

  /// No description provided for @sortName.
  ///
  /// In it, this message translates to:
  /// **'Nome A–Z'**
  String get sortName;

  /// No description provided for @menuSections.
  ///
  /// In it, this message translates to:
  /// **'Sezioni'**
  String get menuSections;

  /// No description provided for @menuData.
  ///
  /// In it, this message translates to:
  /// **'Dati'**
  String get menuData;

  /// No description provided for @searchCards.
  ///
  /// In it, this message translates to:
  /// **'Cerca tessere'**
  String get searchCards;

  /// No description provided for @addCard.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi una tessera'**
  String get addCard;

  /// No description provided for @expiryPanelFooter.
  ///
  /// In it, this message translates to:
  /// **'Avviso a {days} giorni dalla scadenza\nLe tessere restano utilizzabili.'**
  String expiryPanelFooter(int days);

  /// No description provided for @photoFront.
  ///
  /// In it, this message translates to:
  /// **'Foto del fronte'**
  String get photoFront;

  /// No description provided for @photoBack.
  ///
  /// In it, this message translates to:
  /// **'Foto del retro'**
  String get photoBack;

  /// No description provided for @moveToSection.
  ///
  /// In it, this message translates to:
  /// **'Sposta nella sezione'**
  String get moveToSection;

  /// No description provided for @addPhoto.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi foto'**
  String get addPhoto;

  /// No description provided for @photoCount.
  ///
  /// In it, this message translates to:
  /// **'{count} foto'**
  String photoCount(int count);

  /// No description provided for @deleteCardQuestion.
  ///
  /// In it, this message translates to:
  /// **'Eliminare «{name}»?'**
  String deleteCardQuestion(String name);

  /// No description provided for @trashRecoverable.
  ///
  /// In it, this message translates to:
  /// **'Nel cestino resta recuperabile per {days} giorni.'**
  String trashRecoverable(int days);

  /// No description provided for @deleteForever.
  ///
  /// In it, this message translates to:
  /// **'Elimina definitivamente'**
  String get deleteForever;

  /// No description provided for @moveToTrash.
  ///
  /// In it, this message translates to:
  /// **'Sposta nel cestino'**
  String get moveToTrash;

  /// No description provided for @holder.
  ///
  /// In it, this message translates to:
  /// **'Intestatario'**
  String get holder;

  /// No description provided for @expiry.
  ///
  /// In it, this message translates to:
  /// **'Scadenza'**
  String get expiry;

  /// No description provided for @notes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get notes;

  /// No description provided for @favorite.
  ///
  /// In it, this message translates to:
  /// **'Preferita'**
  String get favorite;

  /// No description provided for @edit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get share;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @formatNotDrawable.
  ///
  /// In it, this message translates to:
  /// **'Formato non disegnabile: {format}'**
  String formatNotDrawable(String format);

  /// No description provided for @invalidCode.
  ///
  /// In it, this message translates to:
  /// **'Codice non valido: {error}'**
  String invalidCode(String error);

  /// No description provided for @move.
  ///
  /// In it, this message translates to:
  /// **'Sposta'**
  String get move;

  /// No description provided for @addedOn.
  ///
  /// In it, this message translates to:
  /// **'Inserita il {date}'**
  String addedOn(String date);

  /// No description provided for @genericTypeHint.
  ///
  /// In it, this message translates to:
  /// **'Codice e foto del fronte'**
  String get genericTypeHint;

  /// No description provided for @freeNameHint.
  ///
  /// In it, this message translates to:
  /// **'Nome a scelta'**
  String get freeNameHint;

  /// No description provided for @newCard.
  ///
  /// In it, this message translates to:
  /// **'Nuova tessera'**
  String get newCard;

  /// No description provided for @editCard.
  ///
  /// In it, this message translates to:
  /// **'Modifica tessera'**
  String get editCard;

  /// No description provided for @searchShop.
  ///
  /// In it, this message translates to:
  /// **'Cerca un negozio'**
  String get searchShop;

  /// No description provided for @shops.
  ///
  /// In it, this message translates to:
  /// **'Negozi'**
  String get shops;

  /// No description provided for @otherCards.
  ///
  /// In it, this message translates to:
  /// **'Altre tessere'**
  String get otherCards;

  /// No description provided for @replace.
  ///
  /// In it, this message translates to:
  /// **'Sostituisci'**
  String get replace;

  /// No description provided for @removePhoto.
  ///
  /// In it, this message translates to:
  /// **'Togli la foto'**
  String get removePhoto;

  /// No description provided for @anyCodeFormat.
  ///
  /// In it, this message translates to:
  /// **'Qualunque formato di codice'**
  String get anyCodeFormat;

  /// No description provided for @codeFormatIs.
  ///
  /// In it, this message translates to:
  /// **'Formato del codice: {format}'**
  String codeFormatIs(String format);

  /// No description provided for @remove.
  ///
  /// In it, this message translates to:
  /// **'Togli'**
  String get remove;

  /// No description provided for @section.
  ///
  /// In it, this message translates to:
  /// **'Sezione'**
  String get section;

  /// No description provided for @enterCardName.
  ///
  /// In it, this message translates to:
  /// **'Scrivi il nome della tessera.'**
  String get enterCardName;

  /// No description provided for @enterCode.
  ///
  /// In it, this message translates to:
  /// **'Inserisci o scansiona il codice.'**
  String get enterCode;

  /// No description provided for @genericNeedsFront.
  ///
  /// In it, this message translates to:
  /// **'Per la tessera generica serve la foto del fronte.'**
  String get genericNeedsFront;

  /// No description provided for @limitReached.
  ///
  /// In it, this message translates to:
  /// **'Hai raggiunto il limite di {limit} tessere.'**
  String limitReached(int limit);

  /// No description provided for @saving.
  ///
  /// In it, this message translates to:
  /// **'Salvataggio…'**
  String get saving;

  /// No description provided for @name.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @code.
  ///
  /// In it, this message translates to:
  /// **'Codice'**
  String get code;

  /// No description provided for @scan.
  ///
  /// In it, this message translates to:
  /// **'Scansiona'**
  String get scan;

  /// No description provided for @fromGallery.
  ///
  /// In it, this message translates to:
  /// **'Da galleria'**
  String get fromGallery;

  /// No description provided for @none.
  ///
  /// In it, this message translates to:
  /// **'Nessuna'**
  String get none;

  /// No description provided for @notesHint.
  ///
  /// In it, this message translates to:
  /// **'Facoltative'**
  String get notesHint;

  /// No description provided for @photosFrontRequired.
  ///
  /// In it, this message translates to:
  /// **'FOTO (IL FRONTE È OBBLIGATORIO)'**
  String get photosFrontRequired;

  /// No description provided for @photosOptional.
  ///
  /// In it, this message translates to:
  /// **'FOTO (FACOLTATIVE)'**
  String get photosOptional;

  /// No description provided for @addToFavorites.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi alle preferite'**
  String get addToFavorites;

  /// No description provided for @sideFront.
  ///
  /// In it, this message translates to:
  /// **'Fronte'**
  String get sideFront;

  /// No description provided for @sideBack.
  ///
  /// In it, this message translates to:
  /// **'Retro'**
  String get sideBack;

  /// No description provided for @takePhoto.
  ///
  /// In it, this message translates to:
  /// **'Scatta una foto'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In it, this message translates to:
  /// **'Scegli dalla galleria'**
  String get chooseFromGallery;

  /// No description provided for @cameraDeniedUseGallery.
  ///
  /// In it, this message translates to:
  /// **'La fotocamera non è consentita: puoi scegliere la foto dalla galleria.'**
  String get cameraDeniedUseGallery;

  /// No description provided for @photoFailed.
  ///
  /// In it, this message translates to:
  /// **'Non sono riuscito a prendere la foto.'**
  String get photoFailed;

  /// No description provided for @notAnImage.
  ///
  /// In it, this message translates to:
  /// **'Il file scelto non è un\'immagine.'**
  String get notAnImage;

  /// No description provided for @frontPhotoRequired.
  ///
  /// In it, this message translates to:
  /// **'Per la tessera generica la foto del fronte è obbligatoria: puoi sostituirla.'**
  String get frontPhotoRequired;

  /// No description provided for @deleteFrontPhotoQuestion.
  ///
  /// In it, this message translates to:
  /// **'Eliminare la foto del fronte?'**
  String get deleteFrontPhotoQuestion;

  /// No description provided for @deleteBackPhotoQuestion.
  ///
  /// In it, this message translates to:
  /// **'Eliminare la foto del retro?'**
  String get deleteBackPhotoQuestion;

  /// No description provided for @deletePhotoExplain.
  ///
  /// In it, this message translates to:
  /// **'La foto viene rimossa da questa tessera.\nIl codice resta com\'è.'**
  String get deletePhotoExplain;

  /// No description provided for @deletePhoto.
  ///
  /// In it, this message translates to:
  /// **'Elimina foto'**
  String get deletePhoto;

  /// No description provided for @noFrontPhoto.
  ///
  /// In it, this message translates to:
  /// **'Nessuna foto del fronte'**
  String get noFrontPhoto;

  /// No description provided for @noBackPhoto.
  ///
  /// In it, this message translates to:
  /// **'Nessuna foto del retro'**
  String get noBackPhoto;

  /// No description provided for @swipeToBack.
  ///
  /// In it, this message translates to:
  /// **'Scorri per vedere il retro'**
  String get swipeToBack;

  /// No description provided for @swipeToFront.
  ///
  /// In it, this message translates to:
  /// **'Scorri per tornare al fronte'**
  String get swipeToFront;

  /// No description provided for @swipeToBackZoom.
  ///
  /// In it, this message translates to:
  /// **'Scorri per vedere il retro · pizzica per ingrandire\nTocca la foto per chiudere'**
  String get swipeToBackZoom;

  /// No description provided for @swipeToFrontZoom.
  ///
  /// In it, this message translates to:
  /// **'Scorri per tornare al fronte · pizzica per ingrandire\nTocca la foto per chiudere'**
  String get swipeToFrontZoom;

  /// No description provided for @noCodeFound.
  ///
  /// In it, this message translates to:
  /// **'Nessun codice trovato'**
  String get noCodeFound;

  /// No description provided for @noCodeFoundDetail.
  ///
  /// In it, this message translates to:
  /// **'Scegli una foto in cui il codice si veda bene.'**
  String get noCodeFoundDetail;

  /// No description provided for @photoReadFailed.
  ///
  /// In it, this message translates to:
  /// **'Non sono riuscito a leggere la foto'**
  String get photoReadFailed;

  /// No description provided for @tryAnotherImage.
  ///
  /// In it, this message translates to:
  /// **'Prova con un\'altra immagine.'**
  String get tryAnotherImage;

  /// No description provided for @typeGeneric.
  ///
  /// In it, this message translates to:
  /// **'Tessera generica'**
  String get typeGeneric;

  /// No description provided for @typeLibrary.
  ///
  /// In it, this message translates to:
  /// **'Biblioteca'**
  String get typeLibrary;

  /// No description provided for @typeGym.
  ///
  /// In it, this message translates to:
  /// **'Palestra'**
  String get typeGym;

  /// No description provided for @categoryLoyalty.
  ///
  /// In it, this message translates to:
  /// **'Tessera fedeltà'**
  String get categoryLoyalty;

  /// No description provided for @categoryOther.
  ///
  /// In it, this message translates to:
  /// **'Tessera'**
  String get categoryOther;

  /// No description provided for @formatUnknown.
  ///
  /// In it, this message translates to:
  /// **'Formato non riconosciuto'**
  String get formatUnknown;

  /// No description provided for @formatUnknownDetail.
  ///
  /// In it, this message translates to:
  /// **'Prova a inquadrare di nuovo il codice.'**
  String get formatUnknownDetail;

  /// No description provided for @thisType.
  ///
  /// In it, this message translates to:
  /// **'questa tipologia'**
  String get thisType;

  /// No description provided for @codeNotOfType.
  ///
  /// In it, this message translates to:
  /// **'Questo codice non sembra di {name}'**
  String codeNotOfType(String name);

  /// No description provided for @codeNotOfTypeDetail.
  ///
  /// In it, this message translates to:
  /// **'Controlla la tipologia o usa Tessera generica.\nLetto: {read} · atteso: {expected}'**
  String codeNotOfTypeDetail(String read, String expected);

  /// No description provided for @scanFrame.
  ///
  /// In it, this message translates to:
  /// **'Inquadra il codice della tessera'**
  String get scanFrame;

  /// No description provided for @scanAuto.
  ///
  /// In it, this message translates to:
  /// **'Si legge da solo: non serve toccare nulla.'**
  String get scanAuto;

  /// No description provided for @torch.
  ///
  /// In it, this message translates to:
  /// **'Torcia'**
  String get torch;

  /// No description provided for @enterCodeManually.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il codice a mano'**
  String get enterCodeManually;

  /// No description provided for @cameraNeeded.
  ///
  /// In it, this message translates to:
  /// **'Serve la fotocamera'**
  String get cameraNeeded;

  /// No description provided for @cameraUnavailable.
  ///
  /// In it, this message translates to:
  /// **'La fotocamera non è disponibile'**
  String get cameraUnavailable;

  /// No description provided for @cameraNeededDetail.
  ///
  /// In it, this message translates to:
  /// **'Per leggere il codice di una tessera FacileCards usa la fotocamera. Le immagini restano sul telefono.'**
  String get cameraNeededDetail;

  /// No description provided for @cameraUnavailableDetail.
  ///
  /// In it, this message translates to:
  /// **'Puoi leggere il codice da una foto della galleria o scriverlo a mano.'**
  String get cameraUnavailableDetail;

  /// No description provided for @openSettings.
  ///
  /// In it, this message translates to:
  /// **'Apri impostazioni'**
  String get openSettings;

  /// No description provided for @readFromGalleryPhoto.
  ///
  /// In it, this message translates to:
  /// **'Leggi da una foto della galleria'**
  String get readFromGalleryPhoto;

  /// No description provided for @scanTitle.
  ///
  /// In it, this message translates to:
  /// **'Scansiona il codice'**
  String get scanTitle;

  /// No description provided for @newSection.
  ///
  /// In it, this message translates to:
  /// **'Nuova sezione'**
  String get newSection;

  /// No description provided for @renameSection.
  ///
  /// In it, this message translates to:
  /// **'Rinomina sezione'**
  String get renameSection;

  /// No description provided for @sectionNameTaken.
  ///
  /// In it, this message translates to:
  /// **'Scrivi un nome che non sia già usato da un\'altra sezione.'**
  String get sectionNameTaken;

  /// No description provided for @deleteQuestion.
  ///
  /// In it, this message translates to:
  /// **'Eliminare «{name}»?'**
  String deleteQuestion(String name);

  /// No description provided for @sectionEmpty.
  ///
  /// In it, this message translates to:
  /// **'La sezione è vuota.'**
  String get sectionEmpty;

  /// No description provided for @notDeletable.
  ///
  /// In it, this message translates to:
  /// **'{count} · non eliminabile'**
  String notDeletable(String count);

  /// No description provided for @emptySection.
  ///
  /// In it, this message translates to:
  /// **'Vuota'**
  String get emptySection;

  /// No description provided for @rename.
  ///
  /// In it, this message translates to:
  /// **'Rinomina'**
  String get rename;

  /// No description provided for @deleteSection.
  ///
  /// In it, this message translates to:
  /// **'Elimina sezione'**
  String get deleteSection;

  /// No description provided for @sectionContains.
  ///
  /// In it, this message translates to:
  /// **'La sezione contiene {count}. Cosa ne facciamo?'**
  String sectionContains(String count);

  /// No description provided for @moveCardsToOtherSection.
  ///
  /// In it, this message translates to:
  /// **'Sposta le tessere in un\'altra sezione'**
  String get moveCardsToOtherSection;

  /// No description provided for @sectionIs.
  ///
  /// In it, this message translates to:
  /// **'Sezione: {name}'**
  String sectionIs(String name);

  /// No description provided for @changeSection.
  ///
  /// In it, this message translates to:
  /// **'Cambia sezione'**
  String get changeSection;

  /// No description provided for @deleteCardsToo.
  ///
  /// In it, this message translates to:
  /// **'Elimina anche le tessere'**
  String get deleteCardsToo;

  /// No description provided for @staysInTrash.
  ///
  /// In it, this message translates to:
  /// **'Restano {days} giorni nel cestino.'**
  String staysInTrash(int days);

  /// No description provided for @resultIn.
  ///
  /// In it, this message translates to:
  /// **'Risultato: {count} in {section}'**
  String resultIn(String count, String section);

  /// No description provided for @resultInTrash.
  ///
  /// In it, this message translates to:
  /// **'Risultato: {count} nel cestino'**
  String resultInTrash(String count);

  /// No description provided for @sectionNameHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Famiglia'**
  String get sectionNameHint;

  /// No description provided for @dataTitle.
  ///
  /// In it, this message translates to:
  /// **'Dati'**
  String get dataTitle;

  /// No description provided for @archive.
  ///
  /// In it, this message translates to:
  /// **'Archivio'**
  String get archive;

  /// No description provided for @exportAll.
  ///
  /// In it, this message translates to:
  /// **'Esporta tutto'**
  String get exportAll;

  /// No description provided for @exportAllSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva una copia di tutte le tessere'**
  String get exportAllSubtitle;

  /// No description provided for @importFromFile.
  ///
  /// In it, this message translates to:
  /// **'Importa da file'**
  String get importFromFile;

  /// No description provided for @importFromFileSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Una copia completa, una sezione o una tessera'**
  String get importFromFileSubtitle;

  /// No description provided for @deletedCards.
  ///
  /// In it, this message translates to:
  /// **'Tessere eliminate'**
  String get deletedCards;

  /// No description provided for @trash.
  ///
  /// In it, this message translates to:
  /// **'Cestino'**
  String get trash;

  /// No description provided for @trashSubtitle.
  ///
  /// In it, this message translates to:
  /// **'{count} · eliminate dopo {days} giorni'**
  String trashSubtitle(String count, int days);

  /// No description provided for @noBackupYet.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora fatto una copia.'**
  String get noBackupYet;

  /// No description provided for @lastCopyToday.
  ///
  /// In it, this message translates to:
  /// **'Ultima copia: oggi.'**
  String get lastCopyToday;

  /// No description provided for @lastCopyYesterday.
  ///
  /// In it, this message translates to:
  /// **'Ultima copia: ieri.'**
  String get lastCopyYesterday;

  /// No description provided for @lastCopyDaysAgo.
  ///
  /// In it, this message translates to:
  /// **'Ultima copia: {days} giorni fa.'**
  String lastCopyDaysAgo(int days);

  /// No description provided for @onlyOnThisPhone.
  ///
  /// In it, this message translates to:
  /// **'Le tue tessere esistono solo su questo telefono.\n{when}'**
  String onlyOnThisPhone(String when);

  /// No description provided for @noRoomLimit.
  ///
  /// In it, this message translates to:
  /// **'Non c\'è posto: hai raggiunto il limite di {limit} tessere.'**
  String noRoomLimit(int limit);

  /// No description provided for @deleteForeverQuestion.
  ///
  /// In it, this message translates to:
  /// **'Eliminare «{name}» per sempre?'**
  String deleteForeverQuestion(String name);

  /// No description provided for @cannotRecover.
  ///
  /// In it, this message translates to:
  /// **'Non si potrà più recuperare.'**
  String get cannotRecover;

  /// No description provided for @trashExplain.
  ///
  /// In it, this message translates to:
  /// **'Le tessere eliminate restano qui {days} giorni. Tocca una tessera per recuperarla.'**
  String trashExplain(int days);

  /// No description provided for @trashEmpty.
  ///
  /// In it, this message translates to:
  /// **'Il cestino è vuoto.'**
  String get trashEmpty;

  /// No description provided for @wasIn.
  ///
  /// In it, this message translates to:
  /// **'{when} · era in {section}'**
  String wasIn(String when, String section);

  /// No description provided for @deleteForeverTooltip.
  ///
  /// In it, this message translates to:
  /// **'Elimina per sempre'**
  String get deleteForeverTooltip;

  /// No description provided for @restoreInto.
  ///
  /// In it, this message translates to:
  /// **'Recupera «{name}» in…'**
  String restoreInto(String name);

  /// No description provided for @afterRestore.
  ///
  /// In it, this message translates to:
  /// **'Dopo il recupero: {count} di {limit} tessere'**
  String afterRestore(int count, int limit);

  /// No description provided for @restore.
  ///
  /// In it, this message translates to:
  /// **'Recupera'**
  String get restore;

  /// No description provided for @sectionWillBeRecreated.
  ///
  /// In it, this message translates to:
  /// **'Sezione eliminata: verrà ricreata'**
  String get sectionWillBeRecreated;

  /// No description provided for @transferNotFacileCards.
  ///
  /// In it, this message translates to:
  /// **'Non è un file di FacileCards.'**
  String get transferNotFacileCards;

  /// No description provided for @transferNotFacileCardsOrDamaged.
  ///
  /// In it, this message translates to:
  /// **'Non è un file di FacileCards, o è rovinato.'**
  String get transferNotFacileCardsOrDamaged;

  /// No description provided for @transferBadVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione del file non valida.'**
  String get transferBadVersion;

  /// No description provided for @transferNewerVersion.
  ///
  /// In it, this message translates to:
  /// **'Il file è stato creato da una versione più recente di FacileCards: aggiorna l\'app.'**
  String get transferNewerVersion;

  /// No description provided for @transferBadHeader.
  ///
  /// In it, this message translates to:
  /// **'Intestazione del file non valida.'**
  String get transferBadHeader;

  /// No description provided for @transferTooBig.
  ///
  /// In it, this message translates to:
  /// **'Il file è troppo grande.'**
  String get transferTooBig;

  /// No description provided for @transferIncomplete.
  ///
  /// In it, this message translates to:
  /// **'Il file è incompleto.'**
  String get transferIncomplete;

  /// No description provided for @transferContentDamaged.
  ///
  /// In it, this message translates to:
  /// **'Il contenuto del file è rovinato.'**
  String get transferContentDamaged;

  /// No description provided for @transferDataDamaged.
  ///
  /// In it, this message translates to:
  /// **'I dati del file sono rovinati.'**
  String get transferDataDamaged;

  /// No description provided for @transferBadData.
  ///
  /// In it, this message translates to:
  /// **'Dati del file non validi.'**
  String get transferBadData;

  /// No description provided for @transferTooManyCards.
  ///
  /// In it, this message translates to:
  /// **'Il file contiene troppe tessere.'**
  String get transferTooManyCards;

  /// No description provided for @transferBadSection.
  ///
  /// In it, this message translates to:
  /// **'Sezione non valida.'**
  String get transferBadSection;

  /// No description provided for @transferRepeatedSection.
  ///
  /// In it, this message translates to:
  /// **'Sezione ripetuta nel file.'**
  String get transferRepeatedSection;

  /// No description provided for @transferBadCard.
  ///
  /// In it, this message translates to:
  /// **'Tessera non valida.'**
  String get transferBadCard;

  /// No description provided for @transferRepeatedCard.
  ///
  /// In it, this message translates to:
  /// **'Tessera ripetuta nel file.'**
  String get transferRepeatedCard;

  /// No description provided for @transferCardWithoutSection.
  ///
  /// In it, this message translates to:
  /// **'Una tessera cita una sezione che non c\'è.'**
  String get transferCardWithoutSection;

  /// No description provided for @transferBadPhoto.
  ///
  /// In it, this message translates to:
  /// **'Foto non valida.'**
  String get transferBadPhoto;

  /// No description provided for @transferPhotoTooBig.
  ///
  /// In it, this message translates to:
  /// **'Una foto è troppo grande.'**
  String get transferPhotoTooBig;

  /// No description provided for @transferBadId.
  ///
  /// In it, this message translates to:
  /// **'Identificativo non valido nel file.'**
  String get transferBadId;

  /// No description provided for @transferBadValue.
  ///
  /// In it, this message translates to:
  /// **'Dato non valido nel file.'**
  String get transferBadValue;

  /// No description provided for @transferMissingValue.
  ///
  /// In it, this message translates to:
  /// **'Dato mancante nel file.'**
  String get transferMissingValue;

  /// No description provided for @transferValueTooLong.
  ///
  /// In it, this message translates to:
  /// **'Dato troppo lungo nel file.'**
  String get transferValueTooLong;

  /// No description provided for @transferBadDate.
  ///
  /// In it, this message translates to:
  /// **'Data non valida nel file.'**
  String get transferBadDate;

  /// No description provided for @transferProtectedDamaged.
  ///
  /// In it, this message translates to:
  /// **'Il file protetto è rovinato.'**
  String get transferProtectedDamaged;

  /// No description provided for @transferSectionNameTaken.
  ///
  /// In it, this message translates to:
  /// **'Scegli un nome che non sia già usato da un\'altra sezione.'**
  String get transferSectionNameTaken;

  /// No description provided for @transferLimitExceeded.
  ///
  /// In it, this message translates to:
  /// **'Con questa importazione saresti a {count} tessere: il limite è {limit}.'**
  String transferLimitExceeded(int count, int limit);

  /// No description provided for @passwordTooShort.
  ///
  /// In it, this message translates to:
  /// **'Almeno {min} caratteri.'**
  String passwordTooShort(int min);

  /// No description provided for @passwordsDiffer.
  ///
  /// In it, this message translates to:
  /// **'Le due password non sono uguali.'**
  String get passwordsDiffer;

  /// No description provided for @aboutSize.
  ///
  /// In it, this message translates to:
  /// **'circa {size}'**
  String aboutSize(String size);

  /// No description provided for @shareSection.
  ///
  /// In it, this message translates to:
  /// **'Condividi sezione'**
  String get shareSection;

  /// No description provided for @shareCard.
  ///
  /// In it, this message translates to:
  /// **'Condividi tessera'**
  String get shareCard;

  /// No description provided for @shareMessageCard.
  ///
  /// In it, this message translates to:
  /// **'Ti invio la tessera «{name}».\nPer aprirla serve FacileCards:\n{url}'**
  String shareMessageCard(String name, String url);

  /// No description provided for @shareMessageSection.
  ///
  /// In it, this message translates to:
  /// **'Ti invio le tessere della sezione «{name}».\nPer aprirle serve FacileCards:\n{url}'**
  String shareMessageSection(String name, String url);

  /// No description provided for @copySaved.
  ///
  /// In it, this message translates to:
  /// **'Copia salvata.'**
  String get copySaved;

  /// No description provided for @copySaveFailed.
  ///
  /// In it, this message translates to:
  /// **'Non sono riuscito a salvare la copia. Riprova.'**
  String get copySaveFailed;

  /// No description provided for @saveCopyTitle.
  ///
  /// In it, this message translates to:
  /// **'Salva la copia delle tessere'**
  String get saveCopyTitle;

  /// No description provided for @backupShareText.
  ///
  /// In it, this message translates to:
  /// **'Copia di tutte le mie tessere di FacileCards. Si apre con l\'app FacileCards, da \"Importa da file\".'**
  String get backupShareText;

  /// No description provided for @copyPrepareFailed.
  ///
  /// In it, this message translates to:
  /// **'Non sono riuscito a preparare la copia. Riprova.'**
  String get copyPrepareFailed;

  /// No description provided for @stepOf.
  ///
  /// In it, this message translates to:
  /// **'Passo {step} di {total}'**
  String stepOf(int step, int total);

  /// No description provided for @allYourCards.
  ///
  /// In it, this message translates to:
  /// **'Tutte le tue tessere'**
  String get allYourCards;

  /// No description provided for @sectionCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 sezione} other{{count} sezioni}}'**
  String sectionCount(int count);

  /// No description provided for @aboutToBackup.
  ///
  /// In it, this message translates to:
  /// **'Stai per creare una copia di tutte le tue tessere'**
  String get aboutToBackup;

  /// No description provided for @aboutToShareCard.
  ///
  /// In it, this message translates to:
  /// **'Stai per consegnare questa tessera ad altre persone'**
  String get aboutToShareCard;

  /// No description provided for @aboutToShareCards.
  ///
  /// In it, this message translates to:
  /// **'Stai per consegnare queste tessere ad altre persone'**
  String get aboutToShareCards;

  /// No description provided for @backupPoint1.
  ///
  /// In it, this message translates to:
  /// **'Il file contiene tutto'**
  String get backupPoint1;

  /// No description provided for @backupPoint1Detail.
  ///
  /// In it, this message translates to:
  /// **'Codici, intestatari, note e foto.'**
  String get backupPoint1Detail;

  /// No description provided for @backupPoint2.
  ///
  /// In it, this message translates to:
  /// **'Chi lo apre può usare le tessere'**
  String get backupPoint2;

  /// No description provided for @validAtCheckout.
  ///
  /// In it, this message translates to:
  /// **'Alla cassa valgono come le tue.'**
  String get validAtCheckout;

  /// No description provided for @backupPoint3.
  ///
  /// In it, this message translates to:
  /// **'Conservalo in un posto sicuro'**
  String get backupPoint3;

  /// No description provided for @backupPoint3Detail.
  ///
  /// In it, this message translates to:
  /// **'Un archivio personale, non una chat.'**
  String get backupPoint3Detail;

  /// No description provided for @backupPoint4.
  ///
  /// In it, this message translates to:
  /// **'Puoi proteggerlo con una password'**
  String get backupPoint4;

  /// No description provided for @backupPoint4Detail.
  ///
  /// In it, this message translates to:
  /// **'Al prossimo passaggio, se vuoi.'**
  String get backupPoint4Detail;

  /// No description provided for @sharePoint1Card.
  ///
  /// In it, this message translates to:
  /// **'Chi riceve il file può usare la tessera'**
  String get sharePoint1Card;

  /// No description provided for @sharePoint1Cards.
  ///
  /// In it, this message translates to:
  /// **'Chi riceve il file può usare le tessere'**
  String get sharePoint1Cards;

  /// No description provided for @sharePoint2Card.
  ///
  /// In it, this message translates to:
  /// **'Vede tutto ciò che contiene'**
  String get sharePoint2Card;

  /// No description provided for @sharePoint2Cards.
  ///
  /// In it, this message translates to:
  /// **'Vede tutto ciò che contengono'**
  String get sharePoint2Cards;

  /// No description provided for @sharePoint2Detail.
  ///
  /// In it, this message translates to:
  /// **'Codici, intestatario, note e foto.'**
  String get sharePoint2Detail;

  /// No description provided for @sharePoint3.
  ///
  /// In it, this message translates to:
  /// **'Può inoltrarlo a chiunque'**
  String get sharePoint3;

  /// No description provided for @sharePoint3Detail.
  ///
  /// In it, this message translates to:
  /// **'FacileCards non può impedirlo.'**
  String get sharePoint3Detail;

  /// No description provided for @sharePoint4.
  ///
  /// In it, this message translates to:
  /// **'Non puoi ritirarlo'**
  String get sharePoint4;

  /// No description provided for @sharePoint4Detail.
  ///
  /// In it, this message translates to:
  /// **'Una volta inviato, il file non è più tuo.'**
  String get sharePoint4Detail;

  /// No description provided for @largeFileWarning.
  ///
  /// In it, this message translates to:
  /// **'Il file è grande ({size}), soprattutto per le foto: alcune app potrebbero non riuscire a inviarlo.'**
  String largeFileWarning(String size);

  /// No description provided for @understoodBackup.
  ///
  /// In it, this message translates to:
  /// **'Ho capito: sto esportando {cards} in un unico file.'**
  String understoodBackup(String cards);

  /// No description provided for @understoodCard.
  ///
  /// In it, this message translates to:
  /// **'Ho capito: sto condividendo la tessera «{name}» con le persone a cui invierò il file.'**
  String understoodCard(String name);

  /// No description provided for @understoodSection.
  ///
  /// In it, this message translates to:
  /// **'Ho capito: sto condividendo {cards} della sezione «{name}» con le persone a cui invierò il file.'**
  String understoodSection(String cards, String name);

  /// No description provided for @messageWithFile.
  ///
  /// In it, this message translates to:
  /// **'Messaggio che accompagna il file'**
  String get messageWithFile;

  /// No description provided for @passwordForgetWarning.
  ///
  /// In it, this message translates to:
  /// **'Se la dimentichi non potrai riaprire il file.\nNessuno può recuperarla, nemmeno noi.'**
  String get passwordForgetWarning;

  /// No description provided for @sharePanelHint.
  ///
  /// In it, this message translates to:
  /// **'Si aprirà il pannello di condivisione del telefono: scegli tu l\'app e il destinatario.'**
  String get sharePanelHint;

  /// No description provided for @hide.
  ///
  /// In it, this message translates to:
  /// **'Nascondi'**
  String get hide;

  /// No description provided for @show.
  ///
  /// In it, this message translates to:
  /// **'Mostra'**
  String get show;

  /// No description provided for @protectWithPassword.
  ///
  /// In it, this message translates to:
  /// **'Proteggi con password'**
  String get protectWithPassword;

  /// No description provided for @passwordOptional.
  ///
  /// In it, this message translates to:
  /// **'Facoltativa.'**
  String get passwordOptional;

  /// No description provided for @passwordOptionalShare.
  ///
  /// In it, this message translates to:
  /// **'Facoltativa: chi apre il file dovrà inserirla.'**
  String get passwordOptionalShare;

  /// No description provided for @password.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @repeatPassword.
  ///
  /// In it, this message translates to:
  /// **'Ripeti la password'**
  String get repeatPassword;

  /// No description provided for @passwordsOk.
  ///
  /// In it, this message translates to:
  /// **'Password uguali · almeno {min} caratteri'**
  String passwordsOk(int min);

  /// No description provided for @passwordRule.
  ///
  /// In it, this message translates to:
  /// **'Almeno {min} caratteri, scritta due volte.'**
  String passwordRule(int min);

  /// No description provided for @continueButton.
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get continueButton;

  /// No description provided for @saveOnPhone.
  ///
  /// In it, this message translates to:
  /// **'Salva sul telefono'**
  String get saveOnPhone;

  /// No description provided for @shareEllipsis.
  ///
  /// In it, this message translates to:
  /// **'Condividi…'**
  String get shareEllipsis;

  /// No description provided for @back.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get back;

  /// No description provided for @cannotImport.
  ///
  /// In it, this message translates to:
  /// **'Non si può importare'**
  String get cannotImport;

  /// No description provided for @fileReadFailedMaybeBig.
  ///
  /// In it, this message translates to:
  /// **'Non sono riuscito a leggere il file. Potrebbe essere troppo grande.'**
  String get fileReadFailedMaybeBig;

  /// No description provided for @fileReadFailed.
  ///
  /// In it, this message translates to:
  /// **'Non sono riuscito a leggere il file.'**
  String get fileReadFailed;

  /// No description provided for @fileContentUnexpected.
  ///
  /// In it, this message translates to:
  /// **'Il file è rovinato: il contenuto non è quello atteso.'**
  String get fileContentUnexpected;

  /// No description provided for @replaceAllInFile.
  ///
  /// In it, this message translates to:
  /// **'Le tue tessere attuali sono tutte nel file: restano, con i dati del file.'**
  String get replaceAllInFile;

  /// No description provided for @trashedAll.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{La tua tessera attuale finirà nel cestino e vi resterà per {days} giorni.} other{Le tue {count} tessere attuali finiranno nel cestino e vi resteranno per {days} giorni.}}'**
  String trashedAll(int count, Object days);

  /// No description provided for @trashedSome.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 tessera attuale finirà nel cestino e vi resterà per {days} giorni.} other{{count} tessere attuali finiranno nel cestino e vi resteranno per {days} giorni.}}'**
  String trashedSome(int count, Object days);

  /// No description provided for @othersStay.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{L\'altra è anche nel file e resta.} other{Le altre {count} sono anche nel file e restano.}}'**
  String othersStay(int count);

  /// No description provided for @replaceAllQuestion.
  ///
  /// In it, this message translates to:
  /// **'Sostituire tutte le tessere?'**
  String get replaceAllQuestion;

  /// No description provided for @aboutToReplace.
  ///
  /// In it, this message translates to:
  /// **'Stai per sostituire {cards} con {incoming}.'**
  String aboutToReplace(String cards, int incoming);

  /// No description provided for @trashNotCounted.
  ///
  /// In it, this message translates to:
  /// **'Le tessere del cestino non contano per il limite.'**
  String get trashNotCounted;

  /// No description provided for @replaceXWithY.
  ///
  /// In it, this message translates to:
  /// **'Sostituisci {current} con {incoming}'**
  String replaceXWithY(int current, int incoming);

  /// No description provided for @importedCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Importata 1 tessera.} other{Importate {count} tessere.}}'**
  String importedCount(int count);

  /// No description provided for @importFailedNothingChanged.
  ///
  /// In it, this message translates to:
  /// **'Importazione non riuscita: le tue tessere non sono cambiate.'**
  String get importFailedNothingChanged;

  /// No description provided for @wouldBeOverLimit.
  ///
  /// In it, this message translates to:
  /// **'Con questa scelta saresti a {count} tessere'**
  String wouldBeOverLimit(int count);

  /// No description provided for @freeLimitDetail.
  ///
  /// In it, this message translates to:
  /// **'Il limite della versione gratuita è {limit}.\nCon Pro non hai limiti.'**
  String freeLimitDetail(int limit);

  /// No description provided for @allAlreadyPresent.
  ///
  /// In it, this message translates to:
  /// **'Tutte le tessere del file sono già presenti'**
  String get allAlreadyPresent;

  /// No description provided for @nothingToAdd.
  ///
  /// In it, this message translates to:
  /// **'Non c\'è niente da aggiungere.'**
  String get nothingToAdd;

  /// No description provided for @addsNew.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Aggiunge 1 tessera nuova} other{Aggiunge {count} tessere nuove}}'**
  String addsNew(int count);

  /// No description provided for @alreadyPresent.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 già presente} other{{count} già presenti}}'**
  String alreadyPresent(int count);

  /// No description provided for @afterImport.
  ///
  /// In it, this message translates to:
  /// **'Dopo l\'importazione: {count} di {limit} tessere'**
  String afterImport(int count, int limit);

  /// No description provided for @replacesXWithY.
  ///
  /// In it, this message translates to:
  /// **'Sostituisce {cards} con {incoming}'**
  String replacesXWithY(String cards, int incoming);

  /// No description provided for @importAll.
  ///
  /// In it, this message translates to:
  /// **'Importa tutto'**
  String get importAll;

  /// No description provided for @archiveOfApp.
  ///
  /// In it, this message translates to:
  /// **'Archivio di FacileCards'**
  String get archiveOfApp;

  /// No description provided for @archiveOf.
  ///
  /// In it, this message translates to:
  /// **'Archivio di {owner}'**
  String archiveOf(String owner);

  /// No description provided for @createdOn.
  ///
  /// In it, this message translates to:
  /// **'Creato il {date}'**
  String createdOn(String date);

  /// No description provided for @howToImport.
  ///
  /// In it, this message translates to:
  /// **'Come importarle'**
  String get howToImport;

  /// No description provided for @mergeWithExisting.
  ///
  /// In it, this message translates to:
  /// **'Unisci alle tessere esistenti'**
  String get mergeWithExisting;

  /// No description provided for @mergeWithExistingDetail.
  ///
  /// In it, this message translates to:
  /// **'Aggiunge solo quelle che mancano. Consigliato.'**
  String get mergeWithExistingDetail;

  /// No description provided for @replaceAll.
  ///
  /// In it, this message translates to:
  /// **'Sostituisci tutto'**
  String get replaceAll;

  /// No description provided for @replaceAllDetail.
  ///
  /// In it, this message translates to:
  /// **'Le tessere attuali vanno nel cestino per {days} giorni.'**
  String replaceAllDetail(int days);

  /// No description provided for @androidBackupNote.
  ///
  /// In it, this message translates to:
  /// **'Se hai già ripristinato i dati con il backup di Android, le tessere già presenti non vengono duplicate.'**
  String get androidBackupNote;

  /// No description provided for @discoverPro.
  ///
  /// In it, this message translates to:
  /// **'Scopri Pro · 2,00 €'**
  String get discoverPro;

  /// No description provided for @importButton.
  ///
  /// In it, this message translates to:
  /// **'Importa'**
  String get importButton;

  /// No description provided for @importCards.
  ///
  /// In it, this message translates to:
  /// **'Importa {cards}'**
  String importCards(String cards);

  /// No description provided for @passwordProtectedFile.
  ///
  /// In it, this message translates to:
  /// **'File protetto da password'**
  String get passwordProtectedFile;

  /// No description provided for @enterFilePassword.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la password scelta da chi ha creato il file.'**
  String get enterFilePassword;

  /// No description provided for @wrongPassword.
  ///
  /// In it, this message translates to:
  /// **'Password errata. Controlla e riprova.'**
  String get wrongPassword;

  /// No description provided for @fileNotModified.
  ///
  /// In it, this message translates to:
  /// **'Il file non è stato modificato. Puoi riprovare.'**
  String get fileNotModified;

  /// No description provided for @opening.
  ///
  /// In it, this message translates to:
  /// **'Apertura…'**
  String get opening;

  /// No description provided for @openFile.
  ///
  /// In it, this message translates to:
  /// **'Apri il file'**
  String get openFile;

  /// No description provided for @sectionUpdated.
  ///
  /// In it, this message translates to:
  /// **'Sezione aggiornata.'**
  String get sectionUpdated;

  /// No description provided for @cardAlreadyInSection.
  ///
  /// In it, this message translates to:
  /// **'Questa tessera c\'è già nella sezione scelta'**
  String get cardAlreadyInSection;

  /// No description provided for @allAlreadyInSection.
  ///
  /// In it, this message translates to:
  /// **'Tutte le tessere ci sono già nella sezione scelta'**
  String get allAlreadyInSection;

  /// No description provided for @updatedCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 tessera aggiornata} other{{count} tessere aggiornate}}'**
  String updatedCount(int count);

  /// No description provided for @noLongerInFile.
  ///
  /// In it, this message translates to:
  /// **'{count} non più nel file: nel cestino per {days} giorni'**
  String noLongerInFile(int count, int days);

  /// No description provided for @skippedCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 già presente, non si aggiunge} other{{count} già presenti, non si aggiungono}}'**
  String skippedCount(int count);

  /// No description provided for @importCardTitle.
  ///
  /// In it, this message translates to:
  /// **'Importa tessera'**
  String get importCardTitle;

  /// No description provided for @importSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Importa sezione'**
  String get importSectionTitle;

  /// No description provided for @cardReceivedOn.
  ///
  /// In it, this message translates to:
  /// **'Tessera ricevuta il {date}'**
  String cardReceivedOn(String date);

  /// No description provided for @cardsCreatedOn.
  ///
  /// In it, this message translates to:
  /// **'{cards} · creato il {date}'**
  String cardsCreatedOn(String cards, String date);

  /// No description provided for @alreadyReceivedOn.
  ///
  /// In it, this message translates to:
  /// **'Già ricevuta il {date}'**
  String alreadyReceivedOn(String date);

  /// No description provided for @whichSection.
  ///
  /// In it, this message translates to:
  /// **'In quale sezione'**
  String get whichSection;

  /// No description provided for @whereToPut.
  ///
  /// In it, this message translates to:
  /// **'Dove metterle'**
  String get whereToPut;

  /// No description provided for @newSectionDetail.
  ///
  /// In it, this message translates to:
  /// **'Con un nome non ancora usato'**
  String get newSectionDetail;

  /// No description provided for @nameNotUsedYet.
  ///
  /// In it, this message translates to:
  /// **'Nome (non ancora usato)'**
  String get nameNotUsedYet;

  /// No description provided for @nameAlreadyUsed.
  ///
  /// In it, this message translates to:
  /// **'Questo nome è già usato da un\'altra sezione.'**
  String get nameAlreadyUsed;

  /// No description provided for @mergeIntoSection.
  ///
  /// In it, this message translates to:
  /// **'Unisci a una sezione esistente'**
  String get mergeIntoSection;

  /// No description provided for @mergeIntoSectionDetail.
  ///
  /// In it, this message translates to:
  /// **'Aggiunge solo le tessere nuove'**
  String get mergeIntoSectionDetail;

  /// No description provided for @replaceSection.
  ///
  /// In it, this message translates to:
  /// **'Sostituisci «{name}»'**
  String replaceSection(String name);

  /// No description provided for @replaceSectionDetail.
  ///
  /// In it, this message translates to:
  /// **'Rimpiazza la copia ricevuta prima'**
  String get replaceSectionDetail;

  /// No description provided for @importedCardYours.
  ///
  /// In it, this message translates to:
  /// **'La tessera importata diventa tua: puoi modificarla, spostarla o eliminarla.'**
  String get importedCardYours;

  /// No description provided for @importedCardsYours.
  ///
  /// In it, this message translates to:
  /// **'Le tessere importate diventano tue: puoi modificarle, spostarle o eliminarle.'**
  String get importedCardsYours;

  /// No description provided for @importTheCard.
  ///
  /// In it, this message translates to:
  /// **'Importa la tessera'**
  String get importTheCard;

  /// No description provided for @androidBackupTooBig.
  ///
  /// In it, this message translates to:
  /// **'Le foto occupano {size}: il backup automatico di Android salva al massimo 25 MB e potrebbe non salvare più le tue tessere. Usa «Esporta tutto».'**
  String androidBackupTooBig(String size);

  /// No description provided for @unitMB.
  ///
  /// In it, this message translates to:
  /// **'{n} MB'**
  String unitMB(String n);

  /// No description provided for @unitKB.
  ///
  /// In it, this message translates to:
  /// **'{n} KB'**
  String unitKB(String n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
