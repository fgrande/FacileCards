// Lingua dell'app (analisi 5.8, decisione 35). I testi stanno nei file
// app_<lingua>.arb di questa cartella; Flutter ne ricava AppLocalizations.
//
// Nelle schermate si usa `context.t`; nel codice senza context (messaggi
// della logica, date) si usa [tr], che segue la lingua scelta.

import 'package:flutter/widgets.dart';

import '../data/database.dart' show supportedLanguages;
import 'app_localizations.dart';

export 'app_localizations.dart';
export '../data/database.dart' show supportedLanguages;

/// Nome di ogni lingua, scritto nella lingua stessa.
const languageNames = {'it': 'Italiano', 'en': 'English', 'fr': 'Français'};

/// Bandiera di ogni lingua (emoji, a colori su Android). Una lingua non è un
/// paese: per l'inglese si usa il Regno Unito (app pensata per l'Europa).
const languageFlags = {'it': '🇮🇹', 'en': '🇬🇧', 'fr': '🇫🇷'};

/// Bandiera e nome, per mostrare la lingua scelta ("🇮🇹 Italiano").
String languageLabel(String code) =>
    '${languageFlags[code] ?? ''} ${languageNames[code] ?? code}'.trim();

/// Lingua proposta: quella del telefono se è tra quelle offerte, altrimenti
/// l'inglese.
String proposedLanguage(String phoneLanguage) =>
    supportedLanguages.contains(phoneLanguage) ? phoneLanguage : 'en';

/// La lingua proposta per questo telefono.
String phoneLanguage() => proposedLanguage(
  WidgetsBinding.instance.platformDispatcher.locale.languageCode,
);

final appLocale = ValueNotifier<Locale>(const Locale('it'));
AppLocalizations _tr = lookupAppLocalizations(const Locale('it'));

/// Testi nella lingua dell'app, per il codice che non ha un context.
AppLocalizations get tr => _tr;

/// Cambia la lingua dell'app (subito, anche nelle schermate aperte).
void setAppLanguage(String? code) {
  final c = supportedLanguages.contains(code) ? code! : phoneLanguage();
  _tr = lookupAppLocalizations(Locale(c));
  appLocale.value = Locale(c);
}

/// Lingua per le date: l'inglese con giorno e mese all'europea.
String get dateLocale => _tr.localeName == 'en' ? 'en_GB' : _tr.localeName;

extension L10nContext on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
}
