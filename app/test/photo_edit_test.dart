import 'package:facilecards/photo_edit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' show Offset, Rect;
import 'package:image/image.dart' as img;

/// Foto 4×2: metà sinistra rossa, metà destra blu.
img.Image _redBlue() {
  final i = img.Image(width: 4, height: 2);
  for (var y = 0; y < 2; y++) {
    for (var x = 0; x < 4; x++) {
      i.setPixelRgb(x, y, x < 2 ? 255 : 0, 0, x < 2 ? 0 : 255);
    }
  }
  return i;
}

bool _isRed(img.Pixel p) => p.r > 200 && p.b < 60;
bool _isBlue(img.Pixel p) => p.b > 200 && p.r < 60;

void main() {
  final png = img.encodePng(_redBlue());

  test('un quarto di giro a destra: il rosso (a sinistra) va in alto', () {
    final out = img.decodeImage(
      applyPhotoEdit(PhotoEdit(png, quarterTurns: 1))!,
    )!;
    expect((out.width, out.height), (2, 4));
    expect(_isRed(out.getPixel(1, 0)), isTrue);
    expect(_isBlue(out.getPixel(1, 3)), isTrue);
  });

  test('tre quarti (cioè a sinistra): il rosso va in basso', () {
    final out = img.decodeImage(
      applyPhotoEdit(PhotoEdit(png, quarterTurns: 3))!,
    )!;
    expect((out.width, out.height), (2, 4));
    expect(_isRed(out.getPixel(0, 3)), isTrue);
    expect(_isBlue(out.getPixel(0, 0)), isTrue);
  });

  test('ritaglio della metà destra', () {
    final big = img.copyResize(_redBlue(), width: 40, height: 20);
    final out = img.decodeImage(
      applyPhotoEdit(
        PhotoEdit(img.encodePng(big), crop: const CropBox(0.5, 0, 1, 1)),
      )!,
    )!;
    expect((out.width, out.height), (20, 20));
    expect(_isBlue(out.getPixel(10, 10)), isTrue);
  });

  test('il riquadro gira insieme alla foto', () {
    const box = CropBox(0.5, 0, 1, 1); // metà destra
    // A destra: la metà destra diventa quella in basso.
    expect(box.turned(clockwise: true), const CropBox(0, 0.5, 1, 1));
    // A sinistra: diventa quella in alto.
    expect(box.turned(clockwise: false), const CropBox(0, 0, 1, 0.5));
    // Un giro a destra e uno a sinistra: si torna al punto di partenza.
    const odd = CropBox(0.1, 0.2, 0.6, 0.9);
    final back = odd.turned(clockwise: true).turned(clockwise: false);
    expect(back.left, closeTo(0.1, 1e-9));
    expect(back.bottom, closeTo(0.9, 1e-9));
  });

  const bounds = Rect.fromLTWH(0, 0, 300, 400);

  test('formato tessera: orizzontale, il più grande possibile', () {
    final r = largestWithRatio(bounds, cardRatio, bounds.center);
    expect(r.width / r.height, closeTo(cardRatio, 1e-9));
    expect(r.width, closeTo(300, 1e-9));
    expect(r.width, greaterThan(r.height));
    // Centrato dove si chiede, ma dentro i limiti.
    final top = largestWithRatio(bounds, cardRatio, const Offset(150, 0));
    expect(top.top, 0);
  });

  test('il riquadro si sposta senza uscire', () {
    const f = Rect.fromLTWH(100, 100, 100, 100);
    expect(
      dragFrame(f, const Offset(30, -20), bounds),
      const Rect.fromLTWH(130, 80, 100, 100),
    );
    expect(
      dragFrame(f, const Offset(500, 500), bounds),
      const Rect.fromLTWH(200, 300, 100, 100),
    );
  });

  test('spostando un angolo il riquadro resta nei limiti', () {
    expect(dragCorner(bounds, 2, const Offset(50, 50), bounds), bounds);
    final small = dragCorner(bounds, 0, const Offset(60, 40), bounds);
    expect(small, const Rect.fromLTRB(60, 40, 300, 400));
    // Non si incrocia l'angolo opposto: resta il lato minimo.
    final tiny = dragCorner(bounds, 0, const Offset(900, 900), bounds);
    expect(tiny.width, minFrameSide);
    expect(tiny.right, 300);
  });

  test('spostando un angolo col formato tessera le proporzioni restano', () {
    final start = largestWithRatio(bounds, cardRatio, bounds.center);
    final box = dragCorner(
      start,
      2,
      const Offset(-80, -10),
      bounds,
      ratio: cardRatio,
    );
    expect(box.width / box.height, closeTo(cardRatio, 1e-9));
    expect(box.topLeft, start.topLeft);
    expect(box.width, lessThan(start.width));
  });

  test('la foto ingrandita copre sempre il riquadro', () {
    const frame = Rect.fromLTWH(100, 100, 100, 100);
    // Spostata troppo a destra: torna a coprire il lato sinistro.
    final img = keepCovering(const Rect.fromLTWH(150, 0, 400, 400), frame);
    expect(img.left, 100);
    // Più piccola del riquadro: centrata.
    final small = keepCovering(const Rect.fromLTWH(0, 0, 50, 400), frame);
    expect(small.left, 125);
  });

  test('dal riquadro sullo schermo alle frazioni della foto e ritorno', () {
    const image = Rect.fromLTWH(-100, 0, 400, 200);
    const frame = Rect.fromLTWH(0, 50, 200, 100);
    final c = CropBox.of(frame, image);
    expect(c, const CropBox(0.25, 0.25, 0.75, 0.75));
    expect(c.on(image), frame);
  });

  test('foto senza orientamento: si usa così com\'è', () {
    final p = prepareEditablePhoto(png)!;
    expect((p.width, p.height), (4, 2));
    expect(identical(p.bytes, png), isTrue);
  });
}
