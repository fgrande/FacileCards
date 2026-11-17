import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:mobile_scanner/mobile_scanner.dart';

/// Un codice letto: valore e formato.
class ScannedCode {
  const ScannedCode(this.value, this.format);
  final String value;
  final BarcodeFormat format;
}

/// Il codice letto è accettabile? Se la tipologia non indica un formato
/// ([expected] vuoto) vale qualunque formato; altrimenti deve coincidere.
bool formatAccepted(String? expected, BarcodeFormat read) =>
    expected == null || expected == formatToText(read);

/// Esito del controllo di un codice letto: accettato, oppure rifiutato con
/// un messaggio da mostrare (titolo e dettaglio).
class ScanCheck {
  const ScanCheck.accepted(ScannedCode this.code)
      : title = null,
        detail = null;
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
}) {
  if (value == null || value.isEmpty) return null;
  if (format == BarcodeFormat.unknown) {
    return const ScanCheck.rejected(
        'Formato non riconosciuto', 'Prova a inquadrare di nuovo il codice.');
  }
  if (!formatAccepted(expectedFormat, format)) {
    final name = typeName ?? 'questa tipologia';
    return ScanCheck.rejected(
      'Questo codice non sembra di $name',
      'Controlla la tipologia o usa Tessera Generica.\n'
          'Letto: ${formatLabel(format)} · atteso: '
          '${formatLabel(formatFromText(expectedFormat!))}',
    );
  }
  return ScanCheck.accepted(ScannedCode(value, format));
}

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
    // TODO: sostituire con il formato itf14 quando si controllano i formati reali.
    // ignore: deprecated_member_use
    case BarcodeFormat.itf:
      return bw.Barcode.itf();
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
      return f.name;
  }
}
