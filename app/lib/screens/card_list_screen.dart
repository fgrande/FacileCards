import 'package:material_ui/material_ui.dart';

import '../data/catalog.dart';
import '../data/database.dart' as db;
import '../expiry.dart';
import '../format_utils.dart';
import '../system_settings.dart';
import 'card_screen.dart';
import 'data_screen.dart';
import 'expiry_panel.dart';
import 'import_screen.dart';
import 'new_card_type_screen.dart';
import 'search_field.dart';
import 'sections_screen.dart';
import 'settings_screen.dart';
import '../theme.dart';
import '../ui.dart';

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
    // "Apri con FacileCards": il file si apre dopo che l'elenco è comparso,
    // così l'avvio resta rapido; con l'app già aperta arriva un avviso.
    listenIncomingFiles(_openIncoming);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openIncoming());
  }

  bool _incomingBusy = false;

  Future<void> _openIncoming() async {
    if (_incomingBusy || !mounted) return;
    _incomingBusy = true;
    try {
      if (await openIncomingFile(context, widget.database)) _loadRefs();
    } finally {
      _incomingBusy = false;
    }
  }

  Future<void> _loadRefs() async {
    final d = widget.database;
    final types = await d.select(d.cardTypes).get();
    final sections = await d.select(d.sections).get();
    final expiry = await d.expirySettings();
    final view = await d.setting(db.SettingKeys.listView);
    final sort = await d.setting(db.SettingKeys.listSort);
    if (!mounted) return;
    setState(() {
      _expiry = expiry;
      // Vista e ordinamento come li si era lasciati.
      if (view != null) {
        _view = view == 'bySection' ? _ViewMode.bySection : _ViewMode.all;
      }
      if (sort != null) {
        _sort = sort == 'name' ? _SortMode.name : _SortMode.lastUsed;
      }
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

  Widget _row(db.Card c, DateTime now, {bool inFavorites = false}) {
    final colors = AppColors.of(context);
    final type = _types[c.typeId];
    final section = _sections[c.sectionId]?.name ?? '';
    final warn = _expiry.enabled
        ? expiryLabel(c.expiresOn, now, days: _expiry.days)
        : null;
    final expired = warn == 'Scaduta';
    final subtitle = warn != null
        ? Text(
            warn,
            style: TextStyle(color: expired ? colors.danger : colors.warn),
          )
        : Text(
            _view == _ViewMode.all
                ? '$section · ${usedLabel(c.lastUsedAt, now)}'
                // Per sezione: le preferite dicono dove stanno, le altre che
                // tessera sono (la sezione è già nell'intestazione).
                : (inFavorites ? section : categoryLabel(type)),
          );
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minVerticalPadding: 6,
      leading: type == null
          ? const Icon(Icons.credit_card)
          : TypeLogo(type: type, name: c.name, warning: type.retired),
      title: Text(c.name),
      subtitle: subtitle,
      trailing: c.favorite
          ? Icon(Icons.star_rounded, color: colors.star, size: 28)
          : const Chevron(),
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
            'Nessuna tessera. Tocca + e scegli il negozio.',
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
      widgets.add(const GroupHeader('Preferite'));
      widgets.add(
        TileGroup(
          children: [
            for (final c in favorites) _row(c, now, inFavorites: true),
          ],
        ),
      );
    }
    if (_view == _ViewMode.all) {
      final rest = cards.where((c) => !c.favorite).toList();
      if (rest.isNotEmpty) {
        widgets.add(
          GroupHeader(
            'Tutte le tessere',
            trailing: '${all.length} di ${db.AppDatabase.freeCardLimit}',
          ),
        );
        widgets.add(TileGroup(children: [for (final c in rest) _row(c, now)]));
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
          GroupHeader(
            _sections[id]?.name ?? '',
            trailing: n == 1 ? '1 tessera' : '$n tessere',
          ),
        );
        widgets.add(
          TileGroup(children: [for (final c in inSection) _row(c, now)]),
        );
      }
    }
    return widgets;
  }

  Future<void> _openSections() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SectionsScreen(database: widget.database),
      ),
    );
    _loadRefs();
  }

  /// Decisione 114: copia, importazione e cestino.
  Future<void> _openData() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DataScreen(database: widget.database)),
    );
    _loadRefs();
  }

  void _setView(_ViewMode v) {
    setState(() {
      _view = v;
      _sort = v == _ViewMode.all ? _SortMode.lastUsed : _SortMode.name;
    });
    _rememberList();
  }

  void _setSort(_SortMode m) {
    setState(() => _sort = m);
    _rememberList();
  }

  Future<void> _rememberList() async {
    final d = widget.database;
    await d.setSetting(
      db.SettingKeys.listView,
      _view == _ViewMode.bySection ? 'bySection' : 'all',
    );
    await d.setSetting(
      db.SettingKeys.listSort,
      _sort == _SortMode.name ? 'name' : 'lastUsed',
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(database: widget.database),
      ),
    );
    _loadRefs(); // l'avviso scadenze può essere cambiato
  }

  /// Selettore a pillola "Tutte / Per sezione".
  Widget _viewSwitch(AppColors c) {
    Widget option(String label, _ViewMode mode) {
      final selected = _view == mode;
      return Expanded(
        child: GestureDetector(
          onTap: () => _setView(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.all(2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? c.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? c.primary : c.muted,
                fontSize: 14.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: c.segment,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          option('Tutte', _ViewMode.all),
          option('Per sezione', _ViewMode.bySection),
        ],
      ),
    );
  }

  /// Menu a pillola per l'ordinamento.
  Widget _sortButton(AppColors c) => PopupMenuButton<_SortMode>(
    onSelected: _setSort,
    itemBuilder: (_) => const [
      PopupMenuItem(value: _SortMode.lastUsed, child: Text('Ultimo utilizzo')),
      PopupMenuItem(value: _SortMode.name, child: Text('Nome A–Z')),
    ],
    child: Container(
      height: 36,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _sort == _SortMode.lastUsed ? 'Ultimo utilizzo' : 'Nome A–Z',
            style: TextStyle(color: c.text, fontSize: 14),
          ),
          const SizedBox(width: 4),
          Icon(Icons.expand_more, color: c.muted, size: 22),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return StreamBuilder<List<db.Card>>(
      stream: _cards,
      builder: (context, snap) {
        final all = snap.data ?? const <db.Card>[];
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: const Row(
              children: [
                AppMark(height: 30),
                SizedBox(width: 10),
                Text('FacileCards'),
              ],
            ),
            actions: [
              _bell(all),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (v) => switch (v) {
                  'sections' => _openSections(),
                  'data' => _openData(),
                  _ => _openSettings(),
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'sections', child: Text('Sezioni')),
                  PopupMenuItem(value: 'data', child: Text('Dati')),
                  PopupMenuItem(value: 'settings', child: Text('Impostazioni')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: SearchField(
                  hint: 'Cerca tessere',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Expanded(child: _viewSwitch(c)),
                    const SizedBox(width: 10),
                    _sortButton(c),
                  ],
                ),
              ),
              ..._content(all),
            ],
          ),
          floatingActionButton: SizedBox(
            width: 60,
            height: 60,
            child: FloatingActionButton(
              tooltip: 'Aggiungi una tessera',
              onPressed: _add,
              child: const Icon(Icons.add, size: 34),
            ),
          ),
        );
      },
    );
  }
}
