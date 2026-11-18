import 'dart:convert';
import 'dart:io';

import 'package:facilecards/format_utils.dart';
import 'package:facilecards/l10n/l10n.dart';
import 'package:facilecards/transfer/archive_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  setUpAll(initializeDateFormatting);
  tearDown(() => setAppLanguage('it'));

  test('ogni lingua offerta ha tutti i testi dell\'italiano', () {
    final it = _keys(_arb('it'));
    for (final lang in supportedLanguages) {
      final other = _keys(_arb(lang));
      expect(it.difference(other), isEmpty, reason: 'mancano in $lang');
      expect(other.difference(it), isEmpty, reason: 'in più in $lang');
    }
  });

  test('l\'avvertenza sui marchi è quella della decisione 99', () {
    expect(_arb('en')['trademarkDisclaimer'],
        startsWith('FacileCards is an independent app'));
    expect(_arb('fr')['trademarkDisclaimer'],
        startsWith('FacileCards est une application indépendante'));
  });

  test('date e testi seguono la lingua scelta', () {
    final now = DateTime(2026, 11, 16, 12);
    setAppLanguage('en');
    expect(longDate(DateTime(2027, 12, 31)), '31 December 2027');
    expect(usedLabel(DateTime(2026, 11, 13), now), '3 days ago');
    expect(tr.cardCount(1), '1 card');
    expect(tr.cardCount(4), '4 cards');
    setAppLanguage('fr');
    expect(longDate(DateTime(2027, 12, 31)), '31 décembre 2027');
    expect(expiryLabel(DateTime(2026, 11, 28), now, days: 30),
        'Expire dans 12 jours');
    // In francese lo zero vuole il singolare: "0 carte", non "1 carte".
    expect(tr.cardCount(0), '0 carte');
    expect(tr.cardCount(1), '1 carte');
    expect(tr.cardCount(3), '3 cartes');
    setAppLanguage('it');
    expect(longDate(DateTime(2027, 12, 31)), '31 dicembre 2027');
    expect(tr.cardCount(0), '0 tessere');
  });

  test('i messaggi dei file si traducono quando si mostrano', () {
    const e = TransferException(TransferProblem.limitExceeded,
        count: 52, limit: 50);
    expect(e.message, contains('52 tessere'));
    setAppLanguage('en');
    expect(e.message, contains('52 cards'));
  });
}
