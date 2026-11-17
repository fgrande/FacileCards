import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../expiry.dart';
import '../format_utils.dart';
import 'card_screen.dart';
import 'expiry_panel.dart';
import 'new_card_type_screen.dart';
import 'sections_screen.dart';

enum _ViewMode { all, bySection }

enum _SortMode { lastUsed, name }

/// Videate 2 e 3: elenco delle tessere, tutte insieme o per sezione.
class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key, required this.database});

  final db.AppDatabase database;

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  Map<String, db.CardType> _types = {};
  Map<String, db.Section> _sections = {};
  _ViewMode _view = _ViewMode.all;
  _SortMode _sort = _SortMode.lastUsed;
  String _query = '';
  ExpirySettings _expiry = ExpirySettings.defaults;
  // Un solo ascolto per tutta la vita della schermata: ricrearlo a ogni
  // ricostruzione (per esempio a ogni lettera della ricerca) è inutile.
  late final _cards = widget.database.watchActiveCards();

  @override
  void initState() {
    super.initState();
    _loadRefs();
  }

  Future<void> _loadRefs() async {
    final d = widget.database;
    final types = await d.select(d.cardTypes).get();
    final sections = await d.select(d.sections).get();
    final expiry = await d.expirySettings();
    if (!mounted) return;
    setState(() {
      _expiry = expiry;
      _types = {for (final t in types) t.id: t};
      _sections = {for (final s in sections) s.id: s};
    });
  }

  Future<void> _add() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewCardTypeScreen(database: widget.database),
      ),
    );
    _loadRefs();
  }

  int _compare(db.Card a, db.Card b) {
    int byName() => a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (_sort == _SortMode.name) return byName();
    final la = a.lastUsedAt, lb = b.lastUsedAt;
    if (la == null && lb == null) return byName();
    if (la == null) return 1; // le mai usate vanno in fondo
    if (lb == null) return -1;
    final c = lb.compareTo(la);
    return c != 0 ? c : byName();
  }

  /// La ricerca guarda tutti i campi (decisione B2).
  bool _matches(db.Card c, String q) {
    if (q.isEmpty) return true;
    final fields = [
      c.name,
      c.code,
      c.notes ?? '',
      c.holder ?? '',
      _sections[c.sectionId]?.name ?? '',
      _types[c.typeId]?.name ?? '',
    ];
    return fields.any((f) => f.toLowerCase().contains(q));
  }

  Widget _header(String text, {String? trailing}) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.labelMedium),
        ),
        if (trailing != null)
          Text(trailing, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );

  Widget _row(db.Card c, DateTime now) {
    final type = _types[c.typeId];
    final section = _sections[c.sectionId]?.name ?? '';
    final warn = _expiry.enabled
        ? expiryLabel(c.expiresOn, now, days: _expiry.days)
        : null;
    final subtitle = warn != null
        ? Text(warn, style: TextStyle(color: Colors.amber.shade800))
        : Text(
            _view == _ViewMode.all
                ? '$section · ${usedLabel(c.lastUsedAt, now)}'
                : (type?.name ?? ''),
          );
    return ListTile(
      leading: type == null
          ? const Icon(Icons.credit_card)
          : TypeLogo(type: type),
      title: Text(c.name),
      subtitle: subtitle,
      trailing: warn != null
          ? Icon(Icons.notifications_active, color: Colors.amber.shade800)
          : null,
      onTap: () => _open(c),
    );
  }

  void _open(db.Card c) {
    final type = _types[c.typeId];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardScreen(
          database: widget.database,
          card: c,
          type: type,
          sectionName: _sections[c.sectionId]?.name ?? '',
        ),
      ),
    );
  }

  /// Campanella con il numero di tessere scadute o in scadenza (decisione 70);
  /// non compare se non c'è niente da segnalare.
  Widget _bell(List<db.Card> all) {
    final flagged = cardsToFlag(all, DateTime.now(), _expiry);
    if (flagged.isEmpty) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Scadenze',
      icon: Badge(
        label: Text('${flagged.length}'),
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () async {
        final chosen = await showExpiryPanel(
          context,
          cards: flagged,
          types: _types,
          settings: _expiry,
        );
        if (chosen != null && mounted) _open(chosen);
      },
    );
  }

  List<Widget> _content(List<db.Card> all) {
    final now = DateTime.now();
    final q = _query.trim().toLowerCase();
    final cards = all.where((c) => _matches(c, q)).toList()..sort(_compare);
    if (all.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Nessuna tessera. Premi "Aggiungi" e scegli il negozio.',
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }
    if (cards.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(32),
          child: Text('Nessuna tessera trovata.', textAlign: TextAlign.center),
        ),
      ];
    }
    final favorites = cards.where((c) => c.favorite).toList();
    final widgets = <Widget>[];
    if (favorites.isNotEmpty) {
      widgets.add(_header('PREFERITE'));
      widgets.addAll(favorites.map((c) => _row(c, now)));
    }
    if (_view == _ViewMode.all) {
      final rest = cards.where((c) => !c.favorite).toList();
      if (rest.isNotEmpty) {
        widgets.add(
          _header(
            'TUTTE LE TESSERE',
            trailing: '${all.length} di ${db.AppDatabase.freeCardLimit}',
          ),
        );
        widgets.addAll(rest.map((c) => _row(c, now)));
      }
    } else {
      // Sezione di partenza per prima, le altre in ordine alfabetico (decisione 85).
      final ids = cards.map((c) => c.sectionId).toSet().toList()
        ..sort((a, b) {
          final sa = _sections[a], sb = _sections[b];
          if (sa?.isDefault == true) return -1;
          if (sb?.isDefault == true) return 1;
          return (sa?.name ?? '').toLowerCase().compareTo(
            (sb?.name ?? '').toLowerCase(),
          );
        });
      for (final id in ids) {
        final inSection = cards.where((c) => c.sectionId == id).toList();
        final n = inSection.length;
        widgets.add(
          _header(
            (_sections[id]?.name ?? '').toUpperCase(),
            trailing: n == 1 ? '1 tessera' : '$n tessere',
          ),
        );
        widgets.addAll(inSection.map((c) => _row(c, now)));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<db.Card>>(
      stream: _cards,
      builder: (context, snap) {
        final all = snap.data ?? const <db.Card>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text('FacileCards'),
            actions: [
              _bell(all),
              IconButton(
                tooltip: 'Sezioni',
                icon: const Icon(Icons.folder_outlined),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SectionsScreen(database: widget.database),
                    ),
                  );
                  _loadRefs();
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Cerca tessere',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Tutte'),
                      selected: _view == _ViewMode.all,
                      onSelected: (_) => setState(() {
                        _view = _ViewMode.all;
                        _sort = _SortMode.lastUsed;
                      }),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Per sezione'),
                      selected: _view == _ViewMode.bySection,
                      onSelected: (_) => setState(() {
                        _view = _ViewMode.bySection;
                        _sort = _SortMode.name;
                      }),
                    ),
                    const Spacer(),
                    PopupMenuButton<_SortMode>(
                      onSelected: (m) => setState(() => _sort = m),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: _SortMode.lastUsed,
                          child: Text('Ultimo utilizzo'),
                        ),
                        PopupMenuItem(
                          value: _SortMode.name,
                          child: Text('Nome A–Z'),
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _sort == _SortMode.lastUsed
                              ? 'Ultimo utilizzo'
                              : 'Nome A–Z',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ..._content(all),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi'),
          ),
        );
      },
    );
  }
}
