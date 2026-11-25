// Indirizzi pubblici dell'app (decisione 108). Il sito non è ancora
// pubblicato (decisione 109): finché non lo è, questi link non funzionano.
import 'l10n/l10n.dart';

const siteLabel = 'facilecards.eu';

/// Pagina del sito nella lingua dell'app (italiano: index.html).
String _page(String dir) {
  final l = tr.localeName;
  return 'https://facilecards.eu/$dir${l == 'it' ? '' : '$l.html'}';
}

/// Sito e informativa sulla privacy, nella lingua dell'app.
String get siteUrl => _page('');
String get privacyUrl => _page('privacy/');

/// Scheda dell'app su Google Play, nel messaggio che accompagna i file
/// condivisi (decisione 64). Funziona dalla pubblicazione in poi.
const storeUrl =
    'https://play.google.com/store/apps/details?id=eu.facilecards.app';

/// Indirizzo per chiedere una tessera o un'app per pagare mancante
/// (decisione 36), con l'inoltro della posta di Porkbun.
const contactEmail = 'tessere@facilecards.eu';
