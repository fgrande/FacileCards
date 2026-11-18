import 'package:facilecards/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lingua proposta: quella del telefono se offerta, se no l\'inglese', () {
    expect(proposedLanguage('it'), 'it');
    expect(proposedLanguage('fr'), 'fr');
    expect(proposedLanguage('en'), 'en');
    expect(proposedLanguage('de'), 'en');
    expect(proposedLanguage('ja'), 'en');
  });
}
