import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../photo_edit.dart';
import '../theme.dart';

/// Apre il ritocco della foto (videata 49) e restituisce la foto sistemata,
/// o null se si annulla.
Future<Uint8List?> editCardPhoto(BuildContext context, Uint8List bytes) =>
    Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => PhotoEditScreen(bytes: bytes)),
    );

/// Videata 49: ritocco della foto della tessera (decisione 121). Il riquadro
/// di ritaglio sta fermo sullo schermo: si allarga o stringe dagli angoli e
/// si sposta trascinandolo dall'interno. La foto sotto si ingrandisce con due
/// dita e si sposta con un dito fuori dal riquadro, senza mai lasciarlo
/// scoperto. Si ruota di un quarto di giro a sinistra o a destra; "Formato
/// tessera" porta il riquadro alle proporzioni di una carta di credito,
/// orizzontale. Senza plugin: i calcoli sono in photo_edit.dart.
class PhotoEditScreen extends StatefulWidget {
  const PhotoEditScreen({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<PhotoEditScreen> createState() => _PhotoEditScreenState();
}

/// Cosa sta muovendo il dito.
enum _Drag { corner, frame, image }

class _PhotoEditScreenState extends State<PhotoEditScreen> {
  // Colori fissi come nel visualizzatore delle foto (videata 25).
  static const _background = Color(0xFF0B0F16);
  static const _bar = Color(0xFF151A22);

  /// Ingrandimento massimo della foto.
  static const _maxZoom = 8.0;

  EditablePhoto? _photo;
  int _turns = 0;

  /// Area di lavoro, foto mostrata e riquadro, in coordinate dello schermo.
  /// Si calcolano alla prima disposizione (e se l'area cambia).
  Size? _area;
  Rect _image = Rect.zero;
  Rect _frame = Rect.zero;

  /// Formato tessera attivo.
  bool _cardShape = false;
  bool _busy = false;

  // Gesto in corso.
  _Drag? _drag;
  int _corner = 0;
  Rect _startImage = Rect.zero;
  Offset _startFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final photo = await compute(prepareEditablePhoto, widget.bytes);
    if (!mounted) return;
    // Non è un'immagine: la si passa così com'è, il salvataggio la scarta.
    if (photo == null) return Navigator.of(context).pop(widget.bytes);
    setState(() => _photo = photo);
  }

  /// Larghezza/altezza della foto come si vede, cioè già ruotata.
  double get _aspect {
    final p = _photo!;
    return _turns.isOdd ? p.height / p.width : p.width / p.height;
  }

  /// Zona dove possono stare gli angoli: ai lati più spazio, perché non
  /// cadano nella zona del gesto "indietro" di Android.
  Rect get _work {
    final a = _area!;
    return Rect.fromLTRB(48, 20, a.width - 48, a.height - 20);
  }

  /// Foto intera nella zona di lavoro, senza ingrandimento.
  Rect get _fit {
    final w = _work;
    final (fw, fh) = w.width / w.height > _aspect
        ? (w.height * _aspect, w.height)
        : (w.width, w.width / _aspect);
    return Rect.fromCenter(center: w.center, width: fw, height: fh);
  }

  /// Dove può stare il riquadro: sulla foto e dentro la zona di lavoro.
  Rect get _bounds => _image.intersect(_work);

  double get _zoom => _image.width / _fit.width;

  CropBox get _crop => CropBox.of(_frame, _image);

  /// Rimette la foto intera e il riquadro su [crop] (frazioni della foto).
  void _layout(CropBox crop) {
    _image = _fit;
    _frame = crop.on(_image);
    if (_cardShape) {
      _frame = largestWithRatio(_bounds, cardRatio, _frame.center);
    }
  }

  void _rotate({required bool clockwise}) => setState(() {
    final crop = _crop.turned(clockwise: clockwise);
    _turns = (_turns + (clockwise ? 1 : 3)) % 4;
    _layout(crop);
  });

  void _toggleCardShape() => setState(() {
    _cardShape = !_cardShape;
    if (_cardShape) {
      // Sempre orizzontale, il più grande possibile intorno al riquadro.
      _frame = largestWithRatio(_bounds, cardRatio, _frame.center);
    }
  });

  void _reset() => setState(() {
    _turns = 0;
    _cardShape = false;
    _layout(CropBox.full);
  });

  Future<void> _done() async {
    final photo = _photo!;
    final crop = _crop;
    if (_turns == 0 && crop.isFull) {
      return Navigator.of(context).pop(photo.bytes);
    }
    setState(() => _busy = true);
    final out = await compute(
      applyPhotoEdit,
      PhotoEdit(photo.bytes, quarterTurns: _turns, crop: crop),
    );
    if (mounted) Navigator.of(context).pop(out ?? widget.bytes);
  }

  // Gesti: un dito su un angolo lo sposta, dentro il riquadro sposta il
  // riquadro, fuori sposta la foto; due dita ingrandiscono la foto.

  void _scaleStart(ScaleStartDetails d) {
    _startImage = _image;
    _startFocal = d.localFocalPoint;
    if (d.pointerCount > 1) {
      _drag = _Drag.image;
      return;
    }
    final p = d.localFocalPoint;
    final corners = [
      _frame.topLeft,
      _frame.topRight,
      _frame.bottomRight,
      _frame.bottomLeft,
    ];
    // L'angolo più vicino al dito, se è a portata.
    var best = 36.0;
    int? corner;
    for (var i = 0; i < 4; i++) {
      final dist = (corners[i] - p).distance;
      if (dist < best) {
        best = dist;
        corner = i;
      }
    }
    if (corner != null) {
      _drag = _Drag.corner;
      _corner = corner;
      return;
    }
    _drag = _frame.contains(p) ? _Drag.frame : _Drag.image;
  }

  void _scaleUpdate(ScaleUpdateDetails d) {
    if (_busy) return;
    setState(() {
      switch (_drag) {
        case _Drag.corner:
          _frame = dragCorner(
            _frame,
            _corner,
            d.focalPointDelta,
            _bounds,
            ratio: _cardShape ? cardRatio : null,
          );
        case _Drag.frame:
          _frame = dragFrame(_frame, d.focalPointDelta, _bounds);
        case _Drag.image:
          _moveImage(d);
        case null:
          break;
      }
    });
  }

  /// Ingrandisce intorno al punto tra le dita e sposta la foto; la foto
  /// copre sempre il riquadro (se rimpicciolendo non basta, il riquadro si
  /// stringe sulla foto).
  void _moveImage(ScaleUpdateDetails d) {
    final fit = _fit;
    final startZoom = _startImage.width / fit.width;
    final zoom = (startZoom * d.scale).clamp(1.0, _maxZoom);
    final k = zoom / startZoom;
    final f = d.localFocalPoint;
    final moved = Rect.fromLTWH(
      f.dx - (_startFocal.dx - _startImage.left) * k,
      f.dy - (_startFocal.dy - _startImage.top) * k,
      fit.width * zoom,
      fit.height * zoom,
    );
    _image = keepCovering(moved, _frame);
    if (!_image.contains(_frame.topLeft) ||
        !_image.contains(_frame.bottomRight - const Offset(0.01, 0.01))) {
      _frame = _frame.intersect(_image);
      if (_cardShape) {
        _frame = largestWithRatio(_frame, cardRatio, _frame.center);
      }
    }
  }

  Widget _editor(EditablePhoto photo) => LayoutBuilder(
    builder: (context, constraints) {
      final area = constraints.biggest;
      if (_area != area) {
        // Prima volta, o area cambiata: foto intera, riquadro conservato.
        final crop = _area == null ? CropBox.full : _crop;
        _area = area;
        _layout(crop);
      }
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: _scaleStart,
        onScaleUpdate: _scaleUpdate,
        onScaleEnd: (_) => _drag = null,
        child: Stack(
          children: [
            Positioned.fromRect(
              rect: _image,
              child: RotatedBox(
                quarterTurns: _turns,
                child: Image.memory(
                  photo.bytes,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: _zoom > 1.5
                      ? FilterQuality.medium
                      : FilterQuality.low,
                ),
              ),
            ),
            CustomPaint(size: area, painter: _CropPainter(_frame)),
          ],
        ),
      );
    },
  );

  Widget _tool({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    final color = selected ? const Color(0xFF8AB4FF) : Colors.white;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _busy ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? const Color(0x2E8AB4FF) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(color: color, fontSize: 12, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;
    return Theme(
      data: buildTheme(Brightness.dark),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(context.t.photoEditTitle),
          ),
          body: Column(
            children: [
              Expanded(
                child: photo == null
                    ? const Center(child: CircularProgressIndicator())
                    : ClipRect(child: _editor(photo)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  context.t.photoEditHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              if (_busy) const LinearProgressIndicator(),
              Container(
                color: _bar,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tool(
                            icon: Icons.rotate_left,
                            label: context.t.rotateLeft,
                            onTap: () => _rotate(clockwise: false),
                          ),
                          _tool(
                            icon: Icons.rotate_right,
                            label: context.t.rotateRight,
                            onTap: () => _rotate(clockwise: true),
                          ),
                          _tool(
                            icon: Icons.credit_card,
                            label: context.t.cardShape,
                            selected: _cardShape,
                            onTap: _toggleCardShape,
                          ),
                          _tool(
                            icon: Icons.restart_alt,
                            label: context.t.resetEdit,
                            onTap: _reset,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _busy
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: Text(context.t.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _busy || photo == null ? null : _done,
                              child: Text(context.t.usePhoto),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fuori dal riquadro la foto si scurisce; il riquadro ha un bordo bianco,
/// le linee dei terzi e gli angoli marcati.
class _CropPainter extends CustomPainter {
  _CropPainter(this.box);

  final Rect box;

  @override
  void paint(Canvas canvas, Size size) {
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(box);
    canvas.drawPath(outside, Paint()..color = const Color(0x99000000));
    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(box, line);
    final thirds = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final x = box.left + box.width * i / 3;
      final y = box.top + box.height * i / 3;
      canvas.drawLine(Offset(x, box.top), Offset(x, box.bottom), thirds);
      canvas.drawLine(Offset(box.left, y), Offset(box.right, y), thirds);
    }
    final corner = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const l = 22.0;
    for (final (p, sx, sy) in [
      (box.topLeft, 1.0, 1.0),
      (box.topRight, -1.0, 1.0),
      (box.bottomRight, -1.0, -1.0),
      (box.bottomLeft, 1.0, -1.0),
    ]) {
      canvas.drawLine(p, p + Offset(sx * l, 0), corner);
      canvas.drawLine(p, p + Offset(0, sy * l), corner);
    }
  }

  @override
  bool shouldRepaint(_CropPainter old) => old.box != box;
}
