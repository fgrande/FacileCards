import 'package:facilecards/barcode_support.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  test('i formati comuni delle tessere si sanno disegnare', () {
    for (final f in [
      BarcodeFormat.ean13,
      BarcodeFormat.code128,
      BarcodeFormat.qrCode,
      BarcodeFormat.code39,
    ]) {
      expect(drawableBarcode(f), isNotNull, reason: f.name);
    }
  });

  test('un formato sconosciuto non si disegna', () {
    expect(drawableBarcode(BarcodeFormat.unknown), isNull);
  });

  test('il formato si salva come testo e si rilegge uguale', () {
    for (final f in BarcodeFormat.values) {
      expect(formatFromText(formatToText(f)), f);
    }
    expect(formatFromText('inesistente'), BarcodeFormat.unknown);
  });
}
