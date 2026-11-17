import 'package:material_ui/material_ui.dart';

import '../data/catalog.dart';
import '../data/database.dart' as db;
import '../ui.dart';
import 'new_card_data_screen.dart';
import 'search_field.dart';

/// Videata 7: scelta della tipologia, con ricerca.
class NewCardTypeScreen extends StatefulWidget {
  const NewCardTypeScreen({super.key, required this.database});

  final db.AppDatabase database;

  @override
  State<NewCardTypeScreen> createState() => _NewCardTypeScreenState();
}

class _NewCardTypeScreenState extends State<NewCardTypeScreen> {
  late final Future<List<db.CardType>> _types = widget.database
      .activeCardTypes();
  String _query = '';

  Future<void> _open(db.CardType type) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            NewCardDataScreen(database: widget.database, type: type),
      ),
    );
    if (saved == true && mounted) Navigator.of(context).pop(true);
  }

  Widget _tile(db.CardType t) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    leading: TypeLogo(type: t, size: 44),
    title: Text(t.name),
    subtitle: hasFixedName(t)
        ? null
        : Text(t.isGeneric ? 'Codice e foto del fronte' : 'Nome a scelta'),
    trailing: const Chevron(),
    onTap: () => _open(t),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova tessera')),
      body: FutureBuilder<List<db.CardType>>(
        future: _types,
        builder: (context, snap) {
          final all = snap.data ?? const <db.CardType>[];
          final q = _query.trim().toLowerCase();
          final shown = all
              .where((t) => t.name.toLowerCase().contains(q))
              .toList();
          final shops = shown.where(hasFixedName).toList();
          final others = shown
              .where((t) => !hasFixedName(t) && !t.isGeneric)
              .toList();
          final generic = shown.where((t) => t.isGeneric).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: SearchField(
                  hint: 'Cerca un negozio',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (shops.isNotEmpty) ...[
                const GroupHeader('Negozi'),
                TileGroup(indent: 74, children: shops.map(_tile).toList()),
              ],
              if (others.isNotEmpty || generic.isNotEmpty) ...[
                const GroupHeader('Altre tessere'),
                TileGroup(
                  indent: 74,
                  children: [...others, ...generic].map(_tile).toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
