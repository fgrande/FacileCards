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

  test('formato diverso da quello della tipologia: rifiutato (decisione 82)', () {
    final check = checkScanned('123', BarcodeFormat.qrCode,
        expectedFormat: 'ean13', typeName: 'Carrefour');
    expect(check!.isAccepted, isFalse);
    expect(check.title, 'Questo codice non sembra di Carrefour');
    expect(check.detail, contains('atteso: EAN-13'));
  });

  test('formato uguale a quello della tipologia: accettato', () {
    final check = checkScanned('8001234567890', BarcodeFormat.ean13,
        expectedFormat: 'ean13', typeName: 'Carrefour');
    expect(check!.isAccepted, isTrue);
  });
}
