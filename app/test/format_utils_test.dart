import 'package:facilecards/format_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 16, 22, 30);

  test('quando è stata usata', () {
    expect(usedLabel(null, now), 'mai usata');
    expect(usedLabel(DateTime(2026, 11, 16, 8), now), 'usata oggi');
    expect(usedLabel(DateTime(2026, 11, 15, 23), now), 'usata ieri');
    expect(usedLabel(DateTime(2026, 11, 13), now), '3 giorni fa');
    expect(usedLabel(DateTime(2026, 11, 9), now), 'una settimana fa');
    expect(usedLabel(DateTime(2026, 10, 25), now), '3 settimane fa');
    expect(usedLabel(DateTime(2026, 10, 10), now), 'un mese fa');
    expect(usedLabel(DateTime(2026, 6, 1), now), '5 mesi fa');
  });

  test('avviso di scadenza solo entro 30 giorni', () {
    expect(expiryLabel(null, now), isNull);
    expect(expiryLabel(DateTime(2027, 12, 31), now), isNull);
    expect(expiryLabel(DateTime(2026, 11, 15), now), 'Scaduta');
    expect(expiryLabel(DateTime(2026, 11, 16), now), 'Scade oggi');
    expect(expiryLabel(DateTime(2026, 11, 17), now), 'Scade domani');
    expect(expiryLabel(DateTime(2026, 11, 28), now), 'Scade tra 12 giorni');
  });

  test('data estesa', () {
    expect(longDate(DateTime(2027, 12, 31)), '31 dicembre 2027');
  });

  test('quando è stata eliminata', () {
    expect(deletedLabel(DateTime(2026, 11, 16, 8), now), 'Eliminata oggi');
    expect(deletedLabel(DateTime(2026, 11, 15), now), 'Eliminata ieri');
    expect(deletedLabel(DateTime(2026, 11, 13), now), 'Eliminata 3 giorni fa');
  });
}
