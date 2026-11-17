import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:drift/drift.dart' show Value;
import 'package:material_ui/material_ui.dart';

import '../barcode_support.dart';
import '../data/database.dart' as db;
import '../format_utils.dart';
import '../photos.dart';
import 'new_card_type_screen.dart' show TypeLogo;
import 'photo_picker.dart';
import 'photo_viewer_screen.dart';

/// Videata 5: la tessera con il codice grande su fondo bianco e i dettagli.
/// Aprendola si aggiorna la data di ultimo utilizzo.
class CardScreen extends StatefulWidget {
  const CardScreen({
    super.key,
    required this.database,
    required this.card,
    required this.type,
    required this.sectionName,
  });

  final db.AppDatabase database;
  final db.Card card;
  final db.CardType? type;
  final String sectionName;

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  late bool _favorite = widget.card.favorite;
  late String _sectionName = widget.sectionName;
  late final _photos = widget.database.watchCardPhotos(widget.card.id);
  PhotoStore? _store;

  Future<void> _update(db.CardsCompanion values) {
    final d = widget.database;
    return (d.update(d.cards)..where((c) => c.id.equals(widget.card.id)))
        .write(values);
  }

  @override
  void initState() {
    super.initState();
    _update(db.CardsCompanion(lastUsedAt: Value(DateTime.now())));
    PhotoStore.instance.then((s) {
      if (mounted) setState(() => _store = s);
    });
  }

  bool get _frontRequired => widget.type?.isGeneric ?? false;

  Future<void> _openPhotos(String side) async {
    final store = _store;
    if (store == null) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PhotoViewerScreen(
        database: widget.database,
        store: store,
        card: widget.card,
        frontRequired: _frontRequired,
        initialSide: side,
      ),
    ));
  }

  /// Videata 28: senza foto del fronte si aggiunge quella, poi si passa al
  /// visualizzatore per il retro (decisione 101).
  Future<void> _addPhoto(Map<String, String> photos) async {
    final store = _store;
    if (store == null) return;
    final bytes = await pickCardPhoto(context, title: 'Foto del fronte');
    if (bytes == null || !mounted) return;
    final name = await store.write(widget.card.id, PhotoSide.front, bytes);
    if (name == null) return;
    final old =
        await widget.database.setCardPhoto(widget.card.id, PhotoSide.front, name);
    if (old != null) await store.delete(old);
    if (mounted) {
      await _openPhotos(
          photos.containsKey(PhotoSide.back) ? PhotoSide.front : PhotoSide.back);
    }
  }

  /// "Sposta": cambia la sezione della tessera.
  Future<void> _move() async {
    final sections = await widget.database.visibleSections();
    if (!mounted) return;
    final chosen = await showDialog<db.Section>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sposta nella sezione'),
        children: [
          for (final s in sections)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(s),
              child: Text(s.name,
                  style: TextStyle(
                      fontWeight:
                          s.name == _sectionName ? FontWeight.w700 : null)),
            ),
        ],
      ),
    );
    if (chosen == null || chosen.name == _sectionName) return;
    await widget.database.moveCard(widget.card.id, chosen.id);
    if (mounted) setState(() => _sectionName = chosen.name);
  }

  /// Miniatura della foto del fronte con il numero di foto, oppure
  /// il pulsante "Aggiungi foto" (videate 5 e 28).
  Widget _photoTile() => StreamBuilder<Map<String, String>>(
        stream: _photos,
        builder: (context, snap) {
          final photos = snap.data ?? const <String, String>{};
          final front = photos[PhotoSide.front];
          final store = _store;
          final scheme = Theme.of(context).colorScheme;
          if (front == null || store == null) {
            return OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(64)),
              onPressed: store == null ? null : () => _addPhoto(photos),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Aggiungi foto'),
            );
          }
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openPhotos(PhotoSide.front),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(store.file(front), fit: BoxFit.cover),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.inverseSurface.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          photos.length == 1 ? '1 foto' : '${photos.length} foto',
                          style: TextStyle(
                              color: scheme.onInverseSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  Future<void> _toggleFavorite() async {
    setState(() => _favorite = !_favorite);
    await _update(db.CardsCompanion(favorite: Value(_favorite)));
  }

  /// Videata 18: cestino o eliminazione definitiva.
  Future<void> _delete() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminare «${widget.card.name}»?'),
        content: const Text('Nel cestino resta recuperabile per 30 giorni.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('forever'),
            child: const Text('Elimina definitivamente'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('trash'),
            child: const Text('Sposta nel cestino'),
          ),
        ],
      ),
    );
    if (choice == null) return;
    final d = widget.database;
    if (choice == 'trash') {
      await d.moveCardToTrash(widget.card.id);
    } else {
      await d.deleteCardForever(widget.card.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    final format = formatFromText(c.codeFormat);
    final barcode = drawableBarcode(format);
    final holder = c.holder;
    final notes = c.notes;
    final expires = c.expiresOn;
    final type = widget.type;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (type != null) ...[
              SizedBox(width: 36, height: 36, child: TypeLogo(type: type)),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Preferita',
            icon: Icon(_favorite ? Icons.star : Icons.star_border),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            tooltip: 'Elimina',
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: barcode == null
                ? Text('Formato non disegnabile: ${c.codeFormat}')
                : bw.BarcodeWidget(
                    barcode: barcode,
                    data: c.code,
                    width: double.infinity,
                    height: isSquareFormat(format) ? 260 : 140,
                    drawText: true,
                    errorBuilder: (context, error) =>
                        Text('Codice non valido: $error'),
                  ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(formatLabel(format))),
          const SizedBox(height: 16),
          if (holder != null) _info('Intestatario', holder),
          _info('Sezione', _sectionName),
          if (expires != null) _info('Scadenza', longDate(expires)),
          if (notes != null) _info('Note', notes),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _photoTile()),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(64)),
                  onPressed: _move,
                  child: const Text('Sposta'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Inserita il ${longDate(c.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
