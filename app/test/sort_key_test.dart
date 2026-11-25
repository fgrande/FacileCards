import 'package:facilecards/data/sort_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ordine alfabetico senza maiuscole né accenti', () {
    final names = [
      'ACI',
      'Abbonamento Musei',
      'Été',
      'Esselunga',
      'zeta',
      'Idexè',
      'idea',
    ];
    names.sort(compareNames);
    expect(names, [
      'Abbonamento Musei',
      'ACI',
      'Esselunga',
      'Été',
      'idea',
      'Idexè',
      'zeta',
    ]);
  });

  test('a parità di chiave l\'ordine è stabile', () {
    expect(compareNames('Coop', 'coop'), isNot(0));
    expect(sortKey('Prénatal'), 'prenatal');
  });
}
