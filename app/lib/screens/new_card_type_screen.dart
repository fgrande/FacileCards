import 'package:material_ui/material_ui.dart';

import '../data/catalog.dart';
import '../data/database.dart' as db;
import '../l10n/l10n.dart';
import '../theme.dart';
import '../ui.dart';
import 'card_request_screen.dart';
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
    title: Text(typeName(t)),
    subtitle: hasFixedName(t)
        ? null
        : Text(
            t.isGeneric ? context.t.genericTypeHint : context.t.freeNameHint,
          ),
    trailing: const Chevron(),
    onTap: () => _open(t),
  );

  Widget _requestLink(String query, {required bool found}) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CardRequestScreen(initialShop: query),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Text.rich(
          TextSpan(
            text:
                '${query.isEmpty || found ? context.t.notFoundShop : context.t.notFoundQuery(query)} ',
            style: TextStyle(color: c.muted, fontSize: 14),
            children: [
              TextSpan(
                text: context.t.notFoundAsk,
                style: TextStyle(color: c.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.newCard)),
      body: FutureBuilder<List<db.CardType>>(
        future: _types,
        builder: (context, snap) {
          final all = snap.data ?? const <db.CardType>[];
          final q = _query.trim().toLowerCase();
          final shown = all
              .where((t) => typeName(t).toLowerCase().contains(q))
              .toList();
          final shops = shown.where(isShop).toList();
          final others = shown
              .where((t) => !isShop(t) && !t.isGeneric)
              .toList();
          final generic = shown.where((t) => t.isGeneric).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: SearchField(
                  hint: context.t.searchShop,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (shops.isNotEmpty) ...[
                GroupHeader(context.t.shops),
                TileGroup(indent: 74, children: shops.map(_tile).toList()),
              ],
              // Decisione 120: sempre in fondo ai negozi (chi scorre e non
              // trova il suo può chiederlo); il nome cercato si cita solo se
              // non ha trovato niente, ma si propone comunque nella richiesta.
              _requestLink(_query.trim(), found: shops.isNotEmpty),
              if (others.isNotEmpty || generic.isNotEmpty) ...[
                GroupHeader(context.t.otherCards),
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
