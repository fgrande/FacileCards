import 'package:facilecards/barcode_support.dart';
import 'package:facilecards/card_request.dart';
import 'package:facilecards/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  const secret = '8012345678901';

  tearDown(() => setAppLanguage('it'));

  test('dal codice letto si tengono solo formato e lunghezza', () {
    final f = ReadFormat.of(const ScannedCode(secret, BarcodeFormat.ean13));
    expect(f.label, 'EAN-13');
    expect(f.id, 'ean13');
    expect(f.length, 13);
  });

  test('l\'email non contiene mai il codice (decisione 120)', () {
    final f = ReadFormat.of(const ScannedCode(secret, BarcodeFormat.ean13));
    for (final lang in ['it', 'en', 'fr']) {
      setAppLanguage(lang);
      final body = cardRequestBody(
        shop: ' Esselunga ',
        format: f,
        version: '1.0.0',
      );
      final url = cardRequestMailto(
        shop: 'Esselunga',
        format: f,
        version: '1.0.0',
      );
      expect(body, isNot(contains(secret)), reason: lang);
      expect(url, isNot(contains(secret)), reason: lang);
      expect(body, contains('Esselunga'));
      expect(body, contains('EAN-13 (ean13)'));
      expect(body, contains('13'));
      expect(body, contains(lang));
    }
  });

  test('senza lettura il formato risulta non letto', () {
    final body = cardRequestBody(shop: 'Pippo', format: null, version: '1.0.0');
    expect(body, contains('Formato del codice: non letto'));
  });

  test('mailto con indirizzo, oggetto e spazi codificati', () {
    final url = cardRequestMailto(
      shop: 'Bottega Verde',
      format: null,
      version: '1.0.0',
    );
    expect(url, startsWith('mailto:tessere@facilecards.eu?subject='));
    expect(url, contains('Bottega%20Verde'));
    expect(url, isNot(contains('+')));
  });
}
