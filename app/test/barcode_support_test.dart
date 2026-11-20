import 'package:facilecards/barcode_support.dart';
import 'package:facilecards/codice_fiscale.dart';
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

  test('UPC-A (EAN-13 che comincia con 0) si salva come EAN-13', () {
    // Codice di esempio, non di una tessera vera.
    final check = checkScanned(
      '012345678905',
      BarcodeFormat.upcA,
      expectedFormat: 'ean13',
      typeName: 'Acqua & Sapone',
    );
    expect(check!.isAccepted, isTrue);
    expect(check.code!.value, '0012345678905');
    expect(check.code!.format, BarcodeFormat.ean13);
  });

  test('formati senza cifra di controllo: serve una seconda lettura', () {
    expect(needsConfirmation(BarcodeFormat.code39), isTrue);
    expect(needsConfirmation(BarcodeFormat.codabar), isTrue);
    expect(needsConfirmation(BarcodeFormat.itf14), isTrue);
    expect(needsConfirmation(BarcodeFormat.ean13), isFalse);
    expect(needsConfirmation(BarcodeFormat.code128), isFalse);
    expect(needsConfirmation(BarcodeFormat.qrCode), isFalse);
  });

  // Codice fiscale d'esempio (Mario Rossi), non di una persona vera.
  test('codice fiscale: il carattere di controllo deve tornare', () {
    expect(isValidCodiceFiscale('RSSMRA85T10A562S'), isTrue);
    expect(isValidCodiceFiscale('rssmra85t10a562s'), isTrue);
    expect(isValidCodiceFiscale('RSSMRA85T10A562T'), isFalse); // controllo
    expect(isValidCodiceFiscale('RSSMRA85T10A563S'), isFalse); // una cifra
    expect(isValidCodiceFiscale('RSSMRA85T10A562'), isFalse); // corto
    // Omocodia: cifre sostituite da lettere, il controllo vale lo stesso.
    expect(isValidCodiceFiscale('RSSMRA85T10A56NH'), isTrue);
  });

  test('scansione del Codice Fiscale: una lettura storta si scarta', () {
    ScanCheck? read(String v) => checkScanned(
      v,
      BarcodeFormat.code39,
      expectedFormat: 'code39',
      typeName: 'Codice Fiscale',
      typeId: codiceFiscaleTypeId,
    );
    expect(read('RSSMRA85T10A562S')!.isAccepted, isTrue);
    expect(read('RSSMRA85T10A563S')!.isAccepted, isFalse);
    // Le altre tipologie non fanno questo controllo.
    expect(
      checkScanned(
        'ABC',
        BarcodeFormat.code39,
        expectedFormat: 'code39',
      )!.isAccepted,
      isTrue,
    );
  });
}
