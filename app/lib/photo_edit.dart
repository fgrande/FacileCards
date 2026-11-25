// Ritocco della foto della tessera (decisione 121, videata 49): rotazione a
// quarti di giro e ritaglio. Qui solo i calcoli, senza interfaccia: girano in
// un isolate con il pacchetto `image`, come la riduzione in photos.dart.
//
// Sullo schermo il riquadro di ritaglio sta fermo (in coordinate dello
// schermo) e la foto si ingrandisce e si sposta sotto di esso; il ritaglio
// vero si ricava alla fine con [CropBox.of].

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset, Rect;

import 'package:image/image.dart' as img;

/// Proporzioni di una tessera come una carta di credito (85,6 × 54 mm).
const cardRatio = 85.6 / 54;

/// Riquadro di ritaglio in frazioni (da 0 a 1) della foto già ruotata.
class CropBox {
  const CropBox(this.left, this.top, this.right, this.bottom);

  static const full = CropBox(0, 0, 1, 1);

  final double left, top, right, bottom;

  double get width => right - left;
  double get height => bottom - top;

  /// Tutta la foto (a meno di un millesimo: il riquadro si muove in pixel).
  bool get isFull =>
      left <= 0.001 && top <= 0.001 && right >= 0.999 && bottom >= 0.999;

  /// Il riquadro [frame], sullo schermo, come frazioni della foto mostrata
  /// in [image].
  factory CropBox.of(Rect frame, Rect image) => CropBox(
    ((frame.left - image.left) / image.width).clamp(0, 1),
    ((frame.top - image.top) / image.height).clamp(0, 1),
    ((frame.right - image.left) / image.width).clamp(0, 1),
    ((frame.bottom - image.top) / image.height).clamp(0, 1),
  );

  /// Il riquadro sullo schermo, con la foto mostrata in [image].
  Rect on(Rect image) => Rect.fromLTRB(
    image.left + left * image.width,
    image.top + top * image.height,
    image.left + right * image.width,
    image.top + bottom * image.height,
  );

  /// Lo stesso riquadro dopo un quarto di giro della foto: in senso orario
  /// con [clockwise], altrimenti antiorario.
  CropBox turned({required bool clockwise}) => clockwise
      ? CropBox(1 - bottom, left, 1 - top, right)
      : CropBox(top, 1 - right, bottom, 1 - left);

  @override
  bool operator ==(Object other) =>
      other is CropBox &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'CropBox($left, $top, $right, $bottom)';
}

/// Foto pronta da ritoccare: orientamento della fotocamera già applicato
/// (EXIF), così ciò che si vede è ciò che si ritaglia.
class EditablePhoto {
  const EditablePhoto(this.bytes, this.width, this.height);

  final Uint8List bytes;
  final int width, height;
}

/// Prepara la foto per il ritocco (in un isolate). Null se non è
/// un'immagine.
EditablePhoto? prepareEditablePhoto(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  final orientation = image.exif.imageIfd.orientation;
  if (orientation == null || orientation == 1) {
    return EditablePhoto(bytes, image.width, image.height);
  }
  final upright = img.bakeOrientation(image);
  return EditablePhoto(
    img.encodeJpg(upright, quality: 95),
    upright.width,
    upright.height,
  );
}

/// Ritocco da applicare: quarti di giro in senso orario (0–3) e ritaglio
/// sulla foto già ruotata.
class PhotoEdit {
  const PhotoEdit(
    this.bytes, {
    this.quarterTurns = 0,
    this.crop = CropBox.full,
  });

  final Uint8List bytes;
  final int quarterTurns;
  final CropBox crop;
}

/// Applica il ritocco (in un isolate). La foto si riduce poi ai limiti
/// dell'app con shrinkPhoto, al salvataggio.
Uint8List? applyPhotoEdit(PhotoEdit edit) {
  var image = img.decodeImage(edit.bytes);
  if (image == null) return null;
  image = img.bakeOrientation(image);
  final turns = edit.quarterTurns % 4;
  if (turns != 0) image = img.copyRotate(image, angle: turns * 90);
  final c = edit.crop;
  if (!c.isFull) {
    final x = (c.left * image.width).round().clamp(0, image.width - 1);
    final y = (c.top * image.height).round().clamp(0, image.height - 1);
    final r = (c.right * image.width).round().clamp(x + 1, image.width);
    final b = (c.bottom * image.height).round().clamp(y + 1, image.height);
    image = img.copyCrop(image, x: x, y: y, width: r - x, height: b - y);
  }
  return img.encodeJpg(image, quality: 92);
}

/// Lato più corto ammesso per il riquadro sullo schermo, in punti.
const minFrameSide = 48.0;

/// Il rettangolo più grande con proporzioni [ratio] (larghezza/altezza)
/// dentro [bounds], centrato su [center] per quanto possibile.
Rect largestWithRatio(Rect bounds, double ratio, Offset center) {
  final (w, h) = bounds.width / bounds.height > ratio
      ? (bounds.height * ratio, bounds.height)
      : (bounds.width, bounds.width / ratio);
  final left = (center.dx - w / 2).clamp(bounds.left, bounds.right - w);
  final top = (center.dy - h / 2).clamp(bounds.top, bounds.bottom - h);
  return Rect.fromLTWH(left, top, w, h);
}

/// Il riquadro spostato di [delta], senza uscire da [bounds].
Rect dragFrame(Rect frame, Offset delta, Rect bounds) {
  final dx = delta.dx.clamp(
    bounds.left - frame.left,
    bounds.right - frame.right,
  );
  final dy = delta.dy.clamp(
    bounds.top - frame.top,
    bounds.bottom - frame.bottom,
  );
  return frame.shift(Offset(dx, dy));
}

/// Sposta l'angolo [corner] (0 alto a sinistra, 1 alto a destra, 2 basso a
/// destra, 3 basso a sinistra) di [delta]. L'angolo opposto resta fermo, il
/// riquadro non esce da [bounds] e, con [ratio], mantiene le proporzioni.
Rect dragCorner(
  Rect frame,
  int corner,
  Offset delta,
  Rect bounds, {
  double? ratio,
}) {
  final rightSide = corner == 1 || corner == 2;
  final bottomSide = corner == 2 || corner == 3;
  final ax = rightSide ? frame.left : frame.right;
  final ay = bottomSide ? frame.top : frame.bottom;
  // Spazio disponibile dall'angolo fermo verso quello mosso.
  final maxW = rightSide ? bounds.right - ax : ax - bounds.left;
  final maxH = bottomSide ? bounds.bottom - ay : ay - bounds.top;
  var w = ((rightSide ? frame.right : frame.left) + delta.dx - ax).abs();
  var h = ((bottomSide ? frame.bottom : frame.top) + delta.dy - ay).abs();
  // Senza incrociare l'angolo opposto: si resta dalla stessa parte.
  final crossedX = rightSide
      ? frame.right + delta.dx < ax
      : frame.left + delta.dx > ax;
  final crossedY = bottomSide
      ? frame.bottom + delta.dy < ay
      : frame.top + delta.dy > ay;
  if (crossedX) w = 0;
  if (crossedY) h = 0;
  if (ratio == null) {
    w = w.clamp(math.min(minFrameSide, maxW), maxW);
    h = h.clamp(math.min(minFrameSide, maxH), maxH);
  } else {
    // Si segue il lato mosso di più, poi si sta nello spazio disponibile.
    final minH = math.max(minFrameSide, minFrameSide / ratio);
    final maxS = math.min(maxW / ratio, maxH);
    h = math.max(w / ratio, h).clamp(math.min(minH, maxS), maxS);
    w = h * ratio;
  }
  final x = rightSide ? ax + w : ax - w;
  final y = bottomSide ? ay + h : ay - h;
  return Rect.fromLTRB(
    math.min(ax, x),
    math.min(ay, y),
    math.max(ax, x),
    math.max(ay, y),
  );
}

/// Foto mostrata dopo uno zoom o uno spostamento: deve coprire il riquadro
/// [frame], se è abbastanza grande; altrimenti si centra su di esso.
Rect keepCovering(Rect image, Rect frame) {
  double axis(double start, double size, double fStart, double fEnd) =>
      size >= fEnd - fStart
      ? start.clamp(fEnd - size, fStart)
      : (fStart + fEnd - size) / 2;
  return Rect.fromLTWH(
    axis(image.left, image.width, frame.left, frame.right),
    axis(image.top, image.height, frame.top, frame.bottom),
    image.width,
    image.height,
  );
}
