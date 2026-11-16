import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:drift/drift.dart' show Value;
import 'package:material_ui/material_ui.dart';

import '../barcode_support.dart';
import '../data/database.dart' as db;
import '../format_utils.dart';
import 'new_card_type_screen.dart' show TypeLogo;

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

  Future<void> _update(db.CardsCompanion values) {
    final d = widget.database;
    return (d.update(d.cards)..where((c) => c.id.equals(widget.card.id)))
        .write(values);
  }

  @override
  void initState() {
    super.initState();
    _update(db.CardsCompanion(lastUsedAt: Value(DateTime.now())));
  }

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
          _info('Sezione', widget.sectionName),
          if (expires != null) _info('Scadenza', longDate(expires)),
          if (notes != null) _info('Note', notes),
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
