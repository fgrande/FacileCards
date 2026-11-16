import 'package:material_ui/material_ui.dart';

import '../data/catalog.dart';
import '../data/database.dart' as db;
import 'new_card_data_screen.dart';

/// Videata 7: scelta della tipologia, con ricerca.
class NewCardTypeScreen extends StatefulWidget {
  const NewCardTypeScreen({super.key, required this.database});

  final db.AppDatabase database;

  @override
  State<NewCardTypeScreen> createState() => _NewCardTypeScreenState();
}

class _NewCardTypeScreenState extends State<NewCardTypeScreen> {
  late final Future<List<db.CardType>> _types =
      widget.database.activeCardTypes();
  String _query = '';

  Future<void> _open(db.CardType type) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewCardDataScreen(database: widget.database, type: type),
      ),
    );
    if (saved == true && mounted) Navigator.of(context).pop(true);
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.labelMedium),
      );

  Widget _tile(db.CardType t) => ListTile(
        leading: TypeLogo(type: t),
        title: Text(t.name),
        subtitle: hasFixedName(t)
            ? null
            : Text(t.isGeneric ? 'Codice e foto del fronte' : 'Nome a scelta'),
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
          final shown =
              all.where((t) => t.name.toLowerCase().contains(q)).toList();
          final shops = shown.where(hasFixedName).toList();
          final others =
              shown.where((t) => !hasFixedName(t) && !t.isGeneric).toList();
          final generic = shown.where((t) => t.isGeneric).toList();
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Cerca un negozio',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (shops.isNotEmpty) _header('NEGOZI'),
              ...shops.map(_tile),
              if (others.isNotEmpty || generic.isNotEmpty)
                _header('ALTRE TESSERE'),
              ...others.map(_tile),
              ...generic.map(_tile),
            ],
          );
        },
      ),
    );
  }
}

/// Logo della tipologia: iniziali su colore.
class TypeLogo extends StatelessWidget {
  const TypeLogo({super.key, required this.type});

  final db.CardType type;

  String get _initials {
    final words = type.name
        .split(RegExp(r'[\s&]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length >= 2) return (words[0][0] + words[1][0]).toUpperCase();
    return words.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Color(type.color ?? 0xFF546E7A),
      child: Text(
        _initials,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
