import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../expiry.dart';
import '../format_utils.dart';
import '../theme.dart';
import '../ui.dart';

/// Videata 4: riquadro delle scadenze che scende dall'alto toccando la
/// campanella. Restituisce la tessera toccata, oppure null se si chiude.
Future<db.Card?> showExpiryPanel(
  BuildContext context, {
  required List<db.Card> cards,
  required Map<String, db.CardType> types,
  required ExpirySettings settings,
}) {
  return showGeneralDialog<db.Card>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Chiudi',
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, _, _) => SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          child: _ExpiryPanel(cards: cards, types: types, settings: settings),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, -0.05), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
    ),
  );
}

class _ExpiryPanel extends StatelessWidget {
  const _ExpiryPanel({
    required this.cards,
    required this.types,
    required this.settings,
  });

  final List<db.Card> cards;
  final Map<String, db.CardType> types;
  final ExpirySettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final now = DateTime.now();
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Scadenze', style: theme.textTheme.titleLarge),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Chiudi'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: cards.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, i) {
                  final c = cards[i];
                  final type = types[c.typeId];
                  final expired = daysUntil(c.expiresOn!, now) < 0;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    leading: type == null
                        ? const Icon(Icons.credit_card)
                        : TypeLogo(type: type, name: c.name, size: 44),
                    title: Text(c.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(expiryDetail(c.expiresOn!, now)),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _Badge(
                            text: expiryBadge(c.expiresOn!, now),
                            expired: expired,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.of(context).pop(c),
                  );
                },
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Text(
                'Avviso a ${settings.days} giorni dalla scadenza\n'
                'Le tessere restano utilizzabili.',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Etichetta colorata: rossa se scaduta, ambra se in scadenza.
class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.expired});

  final String text;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final (bg, fg) = expired ? (c.dangerBg, c.danger) : (c.warnBg, c.warn);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w500)),
    );
  }
}
