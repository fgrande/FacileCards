import 'package:facilecards/ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('testo scuro solo sui colori chiari delle tipologie', () {
    // Gialli di Esselunga, Arcaplanet, Tigros: testo scuro.
    for (final c in [0xFFE6A300, 0xFFE0AB00, 0xFFE0A100]) {
      expect(onTypeColor(Color(c)), typeDarkText, reason: c.toRadixString(16));
    }
    // Rosso, blu, nero, arancione, grigio di riserva: testo bianco.
    for (final c in [
      0xFFE30613,
      0xFF1F4FB4,
      0xFF1A1A1A,
      0xFFF07D00,
      TypeLogo.fallbackColor,
    ]) {
      expect(onTypeColor(Color(c)), Colors.white, reason: c.toRadixString(16));
    }
  });
}
