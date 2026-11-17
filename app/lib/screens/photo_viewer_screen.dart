import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../photos.dart';
import 'photo_picker.dart';

const _sides = [PhotoSide.front, PhotoSide.back];

/// Videate 25, 26, 27, 39: foto della tessera a tutto schermo. Si scorre tra
/// fronte e retro, si ingrandisce con due dita, un tocco chiude. La barra in
/// basso sostituisce o elimina la foto mostrata (decisione 101).
class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({
    super.key,
    required this.database,
    required this.store,
    required this.card,
    required this.frontRequired,
    this.initialSide = PhotoSide.front,
  });

  final db.AppDatabase database;
  final PhotoStore store;
  final db.Card card;

  /// Tessera generica: la foto del fronte è obbligatoria (decisione 72).
  final bool frontRequired;
  final String initialSide;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final _pages =
      PageController(initialPage: _sides.indexOf(widget.initialSide));
  late final _photos = widget.database.watchCardPhotos(widget.card.id);
  late int _page = _sides.indexOf(widget.initialSide);
  bool _busy = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  String get _side => _sides[_page];

  Future<void> _put(String side) async {
    final bytes = await pickCardPhoto(context,
        title: 'Foto del ${side == PhotoSide.front ? 'fronte' : 'retro'}');
    if (bytes == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final name = await widget.store.write(widget.card.id, side, bytes);
      if (name == null) {
        _message('Il file scelto non è un\'immagine.');
        return;
      }
      final old = await widget.database.setCardPhoto(widget.card.id, side, name);
      if (old != null) await widget.store.delete(old);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  /// Videata 39: conferma dentro il visualizzatore.
  Future<void> _delete(String side) async {
    if (side == PhotoSide.front && widget.frontRequired) {
      _message('Per la tessera generica la foto del fronte è obbligatoria: '
          'puoi sostituirla.');
      return;
    }
    final which = side == PhotoSide.front ? 'del fronte' : 'del retro';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        final error = Theme.of(context).colorScheme.error;
        return AlertDialog(
          title: Text('Eliminare la foto $which?'),
          content: const Text(
              'La foto viene rimossa da questa tessera.\nIl codice resta com\'è.'),
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowDirection: VerticalDirection.down,
          actionsOverflowButtonSpacing: 4,
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: error),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Elimina foto'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    final old = await widget.database.removeCardPhoto(widget.card.id, side);
    if (old != null) await widget.store.delete(old);
  }

  Widget _photoPage(String fileName) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          maxScale: 5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(widget.store.file(fileName)),
              ),
            ),
          ),
        ),
      );

  /// Videata 27: lato senza foto, con "Aggiungi foto".
  Widget _missingPage(String side) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 358 / 226,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_camera_outlined, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    side == PhotoSide.front
                        ? 'Nessuna foto del fronte'
                        : 'Nessuna foto del retro',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy ? null : () => _put(side),
                    child: const Text('Aggiungi foto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _dots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _sides.length; i++)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _page ? Colors.white : Colors.white38,
              ),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F6FEB),
          brightness: Brightness.dark,
        ),
      ),
      child: StreamBuilder<Map<String, String>>(
        stream: _photos,
        builder: (context, snap) {
          final photos = snap.data ?? const <String, String>{};
          final current = photos[_side];
          final hint = current == null
              ? (_page == 0 ? 'Scorri per vedere il retro' : 'Scorri per tornare al fronte')
              : (_page == 0
                  ? 'Scorri per vedere il retro · pizzica per ingrandire\nTocca la foto per chiudere'
                  : 'Scorri per tornare al fronte · pizzica per ingrandire\nTocca la foto per chiudere');
          return Scaffold(
            backgroundColor: const Color(0xFF0B0F16),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text('${widget.card.name} · ${sideLabel(_side)}'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      for (final side in _sides)
                        photos[side] == null
                            ? _missingPage(side)
                            : _photoPage(photos[side]!),
                    ],
                  ),
                ),
                _dots(),
                const SizedBox(height: 16),
                Text(hint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 24),
                if (_busy) const LinearProgressIndicator(),
                // Barra fissa: solo se il lato mostrato ha una foto.
                Container(
                  color: const Color(0xFF151A22),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: SafeArea(
                    top: false,
                    child: Opacity(
                      opacity: current == null ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: current == null || _busy,
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () => _put(_side),
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text('Sostituisci'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.tonalIcon(
                                style: FilledButton.styleFrom(
                                  foregroundColor: const Color(0xFFFF8A80),
                                ),
                                onPressed: () => _delete(_side),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Elimina foto'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
