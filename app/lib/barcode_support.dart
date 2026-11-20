import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:mobile_scanner/mobile_scanner.dart';

import 'codice_fiscale.dart';
import 'l10n/l10n.dart';

/// Un codice letto: valore e formato.
class ScannedCode {
  const ScannedCode(this.value, this.format);
  final String value;
  final BarcodeFormat format;
}

/// Il codice letto è accettabile? Se la tipologia non indica un formato
/// ([expected] vuoto) vale qualunque formato; altrimenti deve coincidere.
bool formatAccepted(String? expected, BarcodeFormat read) =>
    expected == null || _family(formatFromText(expected)) == _family(read);

/// I codici ITF (Interleaved 2 of 5) il lettore li chiama in modi diversi
/// secondo la versione e il telefono: per il controllo sono la stessa cosa.
bool isItf(BarcodeFormat f) =>
    // ignore: deprecated_member_use
    f == BarcodeFormat.itf ||
    f == BarcodeFormat.itf14 ||
    f == BarcodeFormat.itf2of5 ||
    f == BarcodeFormat.itf2of5WithChecksum;

Object _family(BarcodeFormat f) => isItf(f) ? 'itf' : f;

/// Esito del controllo di un codice letto: accettato, oppure rifiutato con
/// un messaggio da mostrare (titolo e dettaglio).
class ScanCheck {
  const ScanCheck.accepted(ScannedCode this.code) : title = null, detail = null;
  const ScanCheck.rejected(String this.title, String this.detail) : code = null;

  final ScannedCode? code;
  final String? title;
  final String? detail;

  bool get isAccepted => code != null;
}

/// Controlla un codice letto (dalla fotocamera o da un'immagine) rispetto al
/// formato atteso dalla tipologia (decisione 82). Restituisce null se non c'è
/// nessun valore da considerare.
ScanCheck? checkScanned(
  String? value,
  BarcodeFormat format, {
  String? expectedFormat,
  String? typeName,
  String? typeId,
}) {
  if (value == null || value.isEmpty) return null;
  // Un EAN-13 che comincia con 0 è anche un UPC-A, e il lettore a volte lo
  // chiama così (12 cifre, senza lo 0): lo si riporta a EAN-13, che è lo
  // stesso codice a barre (tessera Acqua & Sapone).
  if (format == BarcodeFormat.upcA && RegExp(r'^\d{12}$').hasMatch(value)) {
    value = '0$value';
    format = BarcodeFormat.ean13;
  }
  if (format == BarcodeFormat.unknown) {
    return ScanCheck.rejected(tr.formatUnknown, tr.formatUnknownDetail);
  }
  if (!formatAccepted(expectedFormat, format)) {
    return ScanCheck.rejected(
      tr.codeNotOfType(typeName ?? tr.thisType),
      tr.codeNotOfTypeDetail(
        formatLabel(format),
        formatLabel(formatFromText(expectedFormat!)),
      ),
    );
  }
  // Codice Fiscale: il carattere finale di controllo deve tornare, così una
  // lettura storta del Code 39 si scarta e si continua a leggere.
  if (typeId == codiceFiscaleTypeId && !isValidCodiceFiscale(value)) {
    return ScanCheck.rejected(tr.cfInvalid, tr.cfInvalidDetail);
  }
  return ScanCheck.accepted(ScannedCode(value, format));
}

/// Tipologia del catalogo il cui codice si controlla con [isValidCodiceFiscale].
const codiceFiscaleTypeId = 'codice-fiscale';

/// Formati senza cifra di controllo obbligatoria (Code 39, Codabar, ITF):
/// una lettura storta può dare un codice sbagliato ma valido. Dalla
/// fotocamera si accettano solo dopo due letture uguali di seguito.
bool needsConfirmation(BarcodeFormat f) =>
    f == BarcodeFormat.code39 || f == BarcodeFormat.codabar || isItf(f);

/// Il formato si salva nel database come testo (il nome del formato).
String formatToText(BarcodeFormat f) => f.name;

BarcodeFormat formatFromText(String text) {
  for (final f in BarcodeFormat.values) {
    if (f.name == text) return f;
  }
  return BarcodeFormat.unknown;
}

/// Converte il formato del lettore in quello del disegnatore del codice.
/// Restituisce null se il formato non si sa disegnare.
bw.Barcode? drawableBarcode(BarcodeFormat f) {
  // ITF di lunghezza libera: il lettore lo chiama "ITF-14" anche quando le
  // cifre non sono 14 (per esempio la tessera OVS).
  if (isItf(f)) return bw.Barcode.itf();
  switch (f) {
    case BarcodeFormat.ean13:
      return bw.Barcode.ean13();
    case BarcodeFormat.ean8:
      return bw.Barcode.ean8();
    case BarcodeFormat.upcA:
      return bw.Barcode.upcA();
    case BarcodeFormat.upcE:
      return bw.Barcode.upcE();
    case BarcodeFormat.code128:
      return bw.Barcode.code128();
    case BarcodeFormat.code39:
      return bw.Barcode.code39();
    case BarcodeFormat.code93:
      return bw.Barcode.code93();
    case BarcodeFormat.codabar:
      return bw.Barcode.codabar();
    case BarcodeFormat.qrCode:
      return bw.Barcode.qrCode();
    case BarcodeFormat.dataMatrix:
      return bw.Barcode.dataMatrix();
    case BarcodeFormat.pdf417:
      return bw.Barcode.pdf417();
    case BarcodeFormat.aztec:
      return bw.Barcode.aztec();
    default:
      return null;
  }
}

/// I codici quadrati si disegnano più alti.
bool isSquareFormat(BarcodeFormat f) =>
    f == BarcodeFormat.qrCode ||
    f == BarcodeFormat.dataMatrix ||
    f == BarcodeFormat.aztec;

/// Nome del formato come si mostra all'utente.
String formatLabel(BarcodeFormat f) {
  switch (f) {
    case BarcodeFormat.ean13:
      return 'EAN-13';
    case BarcodeFormat.ean8:
      return 'EAN-8';
    case BarcodeFormat.upcA:
      return 'UPC-A';
    case BarcodeFormat.upcE:
      return 'UPC-E';
    case BarcodeFormat.code128:
      return 'Code 128';
    case BarcodeFormat.code39:
      return 'Code 39';
    case BarcodeFormat.code93:
      return 'Code 93';
    case BarcodeFormat.qrCode:
      return 'QR';
    case BarcodeFormat.dataMatrix:
      return 'Data Matrix';
    case BarcodeFormat.pdf417:
      return 'PDF417';
    case BarcodeFormat.aztec:
      return 'Aztec';
    case BarcodeFormat.codabar:
      return 'Codabar';
    default:
      if (isItf(f)) return 'ITF';
      return f.name;
  }
}
