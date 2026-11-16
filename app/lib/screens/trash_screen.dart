import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../format_utils.dart';

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

    final chosen = await showDialog<String>(
      context: context,
      builder: (_) => _RecoverDialog(
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Cestino')),
      body: StreamBuilder<List<db.Card>>(
        stream: widget.database.watchTrash(),
        builder: (context, snap) {
          final cards = snap.data ?? const <db.Card>[];
          return FutureBuilder<List<db.Section>>(
            future: widget.database.select(widget.database.sections).get(),
            builder: (context, secSnap) {
              final names = {
                for (final s in secSnap.data ?? const <db.Section>[]) s.id: s.name,
              };
              return ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Le tessere eliminate restano qui 30 giorni.'),
                  ),
                  if (cards.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Il cestino è vuoto.'),
                    ),
                  for (final c in cards)
                    ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: Text(c.name),
                      subtitle: Text(
                        '${deletedLabel(c.deletedAt ?? now, now)} · era in ${names[c.sectionId] ?? ''}',
                      ),
                      onTap: () => _recover(c),
                      trailing: IconButton(
                        tooltip: 'Elimina per sempre',
                        icon: const Icon(Icons.delete_forever_outlined),
                        onPressed: () => _deleteForever(c),
                      ),
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

class _RecoverDialog extends StatefulWidget {
  const _RecoverDialog({
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
  State<_RecoverDialog> createState() => _RecoverDialogState();
}

class _RecoverDialogState extends State<_RecoverDialog> {
  late String _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Recupera «${widget.cardName}» in…'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in widget.options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_selected == o.section.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                title: Text(o.section.name),
                subtitle: Text(o.recreated
                    ? 'Sezione eliminata: verrà ricreata'
                    : (o.count == 1 ? '1 tessera' : '${o.count} tessere')),
                onTap: () => setState(() => _selected = o.section.id),
              ),
            const SizedBox(height: 8),
            Text(
              'Dopo il recupero: ${widget.activeTotal + 1} di ${db.AppDatabase.freeCardLimit} tessere',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Recupera'),
        ),
      ],
    );
  }
}
