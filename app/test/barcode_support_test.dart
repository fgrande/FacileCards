import 'package:facilecards/barcode_support.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  test('codice vuoto: niente da considerare', () {
    expect(checkScanned(null, BarcodeFormat.ean13), isNull);
    expect(checkScanned('', BarcodeFormat.ean13), isNull);
  });

  test('tipologia senza formato: si accetta qualunque formato', () {
    final check = checkScanned('123', BarcodeFormat.qrCode);
    expect(check!.isAccepted, isTrue);
    expect(check.code!.value, '123');
    expect(check.code!.format, BarcodeFormat.qrCode);
  });

  test('formato sconosciuto: rifiutato', () {
    final check = checkScanned('123', BarcodeFormat.unknown);
    expect(check!.isAccepted, isFalse);
    expect(check.title, 'Formato non riconosciuto');
  });

  test(
    'formato diverso da quello della tipologia: rifiutato (decisione 82)',
    () {
      final check = checkScanned(
        '123',
        BarcodeFormat.qrCode,
        expectedFormat: 'ean13',
        typeName: 'Carrefour',
      );
      expect(check!.isAccepted, isFalse);
      expect(check.title, 'Questo codice non sembra di Carrefour');
      expect(check.detail, contains('atteso: EAN-13'));
    },
  );

  test('formato uguale a quello della tipologia: accettato', () {
    final check = checkScanned(
      '8001234567890',
      BarcodeFormat.ean13,
      expectedFormat: 'ean13',
      typeName: 'Carrefour',
    );
    expect(check!.isAccepted, isTrue);
  });

  test('ITF (tessera OVS): si disegna anche se le cifre non sono 14', () {
    for (final f in [BarcodeFormat.itf14, BarcodeFormat.itf2of5]) {
      expect(drawableBarcode(f), isNotNull);
      expect(formatLabel(f), 'ITF');
    }
    // Le varianti di ITF valgono come lo stesso formato atteso.
    expect(formatAccepted('itf14', BarcodeFormat.itf2of5), isTrue);
    expect(formatAccepted('itf14', BarcodeFormat.ean13), isFalse);
    // Il disegno accetta una lunghezza pari qualsiasi, non solo 14 cifre.
    expect(
      () =>
          drawableBarcode(BarcodeFormat.itf14)!
              .make('12345678', width: 300, height: 80)
              .toList(),
      returnsNormally,
    );
  });
}
