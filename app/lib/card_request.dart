// Richiesta di una tessera mancante (decisione 36, videata 48).
//
// La richiesta parte come email dall'app di posta dell'utente: FacileCards
// prepara solo il testo. Se l'utente legge il codice della tessera, nella
// richiesta vanno il formato e il numero di caratteri, mai il codice
// (decisione 120): per questo qui si conserva solo [ReadFormat], ricavato
// dal codice letto e poi scartato.

import 'package:mobile_scanner/mobile_scanner.dart';

import 'barcode_support.dart';
import 'l10n/l10n.dart';
import 'links.dart';

/// Formato di un codice letto, senza il codice.
class ReadFormat {
  const ReadFormat(this.format, this.length);

  /// Solo formato e lunghezza: il valore del codice non si tiene.
  factory ReadFormat.of(ScannedCode code) =>
      ReadFormat(code.format, code.value.length);

  final BarcodeFormat format;
  final int length;

  /// Nome per le persone ("EAN-13").
  String get label => formatLabel(format);

  /// Nome usato nel catalogo ("ean13").
  String get id => formatToText(format);
}

/// Oggetto dell'email.
String cardRequestSubject(String shop) => tr.requestMailSubject(shop.trim());

/// Testo dell'email, nella lingua dell'app.
String cardRequestBody({
  required String shop,
  required ReadFormat? format,
  required String version,
}) {
  final f = format == null
      ? tr.requestFormatNotRead
      : tr.requestFormatValue(format.label, format.id, format.length);
  return tr.requestMailBody(shop.trim(), f, tr.localeName, version);
}

/// Indirizzo `mailto:` con oggetto e testo (spazi come %20, non "+", che
/// alcune app di posta mostrerebbero così com'è).
String cardRequestMailto({
  required String shop,
  required ReadFormat? format,
  required String version,
}) {
  final subject = Uri.encodeComponent(cardRequestSubject(shop));
  final body = Uri.encodeComponent(
    cardRequestBody(shop: shop, format: format, version: version),
  );
  return 'mailto:$contactEmail?subject=$subject&body=$body';
}
