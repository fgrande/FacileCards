import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../format_utils.dart';
import '../theme.dart';
import '../ui.dart';

/// Videata 13: il cestino. Le tessere restano 30 giorni e si possono
/// recuperare in una sezione a scelta.
class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key, required this.database});

  final db.AppDatabase database;

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _recover(db.Card card) async {
    final d = widget.database;
    final visible = await d.visibleSections();
    final counts = await d.sectionCounts();
    final total = await d.activeCardCount();
    final original = await (d.select(d.sections)
          ..where((s) => s.id.equals(card.sectionId)))
        .getSingleOrNull();

    // La sezione d'origine, se era stata eliminata, viene ricreata; ma se il
    // suo nome è stato riusato, la tessera va nella sezione che lo porta.
    final options = <_Option>[];
    String? preselected;
    if (original != null && original.hidden) {
      final sameName = visible
          .where((s) => s.name.toLowerCase() == original.name.toLowerCase())
          .toList();
      if (sameName.isEmpty) {
        options.add(_Option(original, 0, recreated: true));
        preselected = original.id;
      } else {
        preselected = sameName.first.id;
      }
    } else if (original != null) {
      preselected = original.id;
    }
    for (final s in visible) {
      options.add(_Option(s, counts[s.id] ?? 0));
    }
    preselected ??= visible.first.id;
    if (!mounted) return;

    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _RecoverSheet(
        cardName: card.name,
        options: options,
        selected: preselected!,
        activeTotal: total,
      ),
    );
    if (chosen == null) return;
    final ok = await d.recoverCard(card.id, chosen);
    if (!ok) {
      _message('Non c\'è posto: hai raggiunto il limite di ${db.AppDatabase.freeCardLimit} tessere.');
    }
  }

  Future<void> _deleteForever(db.Card card) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminare «${card.name}» per sempre?'),
        content: const Text('Non si potrà più recuperare.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok == true) await widget.database.deleteCardForever(card.id);
  }

  late final _types = widget.database.select(widget.database.cardTypes).get();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cestino')),
      body: StreamBuilder<List<db.Card>>(
        stream: widget.database.watchTrash(),
        builder: (context, snap) {
          final cards = snap.data ?? const <db.Card>[];
          return FutureBuilder(
            future: Future.wait([
              widget.database.select(widget.database.sections).get(),
              _types,
            ]),
            builder: (context, refs) {
              final names = {
                for (final s in (refs.data?[0] as List<db.Section>? ?? const []))
                  s.id: s.name,
              };
              final types = {
                for (final t in (refs.data?[1] as List<db.CardType>? ?? const []))
                  t.id: t,
              };
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Text(
                        'Le tessere eliminate restano qui ${db.AppDatabase.trashDays} giorni. '
                        'Tocca una tessera per recuperarla.',
                        style: TextStyle(color: c.muted, fontSize: 13.5)),
                  ),
                  if (cards.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Il cestino è vuoto.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.muted)),
                    )
                  else
                    TileGroup(
                      children: [
                        for (final card in cards)
                          ListTile(
                            contentPadding:
                                const EdgeInsets.fromLTRB(16, 4, 4, 4),
                            leading: types[card.typeId] == null
                                ? const IconTile(Icons.credit_card)
                                : TypeLogo(
                                    type: types[card.typeId]!, name: card.name),
                            title: Text(card.name),
                            subtitle: Text(
                              '${deletedLabel(card.deletedAt ?? now, now)} · era in ${names[card.sectionId] ?? ''}',
                            ),
                            onTap: () => _recover(card),
                            trailing: IconButton(
                              tooltip: 'Elimina per sempre',
                              icon: const Icon(Icons.delete_forever_outlined),
                              onPressed: () => _deleteForever(card),
                            ),
                          ),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Option {
  const _Option(this.section, this.count, {this.recreated = false});

  final db.Section section;
  final int count;
  final bool recreated;
}

/// Videata 13: in quale sezione recuperare la tessera.
class _RecoverSheet extends StatefulWidget {
  const _RecoverSheet({
    required this.cardName,
    required this.options,
    required this.selected,
    required this.activeTotal,
  });

  final String cardName;
  final List<_Option> options;
  final String selected;
  final int activeTotal;

  @override
  State<_RecoverSheet> createState() => _RecoverSheetState();
}

class _RecoverSheetState extends State<_RecoverSheet> {
  late String _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final after = widget.activeTotal + 1;
    final fits = after <= db.AppDatabase.freeCardLimit;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Text('Recupera «${widget.cardName}» in…',
                  style: TextStyle(
                      color: c.text, fontSize: 20, fontWeight: FontWeight.w500)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final o in widget.options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _option(c, o),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: fits ? c.successBg : c.warnBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(fits ? Icons.check : Icons.warning_amber_rounded,
                      color: fits ? c.success : c.warn, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fits
                          ? 'Dopo il recupero: $after di ${db.AppDatabase.freeCardLimit} tessere'
                          : 'Hai raggiunto il limite di ${db.AppDatabase.freeCardLimit} tessere',
                      style: TextStyle(
                          color: fits ? c.success : c.warn, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_selected),
              child: const Text('Recupera'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(AppColors c, _Option o) {
    final selected = _selected == o.section.id;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selected = o.section.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? c.primary : c.border, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? c.primary : c.muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.section.name,
                      style: TextStyle(color: c.text, fontSize: 16)),
                  Text(
                    o.recreated
                        ? 'Sezione eliminata: verrà ricreata'
                        : (o.count == 1 ? '1 tessera' : '${o.count} tessere'),
                    style: TextStyle(color: c.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
