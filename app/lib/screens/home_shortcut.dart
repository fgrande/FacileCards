import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../data/catalog.dart';
import '../data/database.dart' as db;
import '../format_utils.dart';
import '../l10n/l10n.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../ui.dart';
import 'card_screen.dart';
import 'trash_screen.dart';

// Scorciatoie in Home (decisioni 89 e 90, videate 16, 19, 20): un'icona sulla
// schermata Home che apre una tessera. Codice nativo in Shortcuts.kt; qui
// l'icona, l'aggiunta (con la sola conferma di Android) e l'apertura.

/// Icona della scorciatoia: il logo della tessera come nell'app (colore e
/// iniziali, testo scuro sui colori chiari), in PNG per un'icona adattiva di
/// Android (108 dp, di cui si vede il centro).
Future<Uint8List> shortcutIcon(db.CardType? type, String cardName) async {
  const side = 432.0; // 108 dp × 4
  const visible = side * 72 / 108; // parte sicura, sempre visibile
  final background = Color(type?.color ?? TypeLogo.fallbackColor);
  final initials = initialsOf(
    type != null && hasFixedName(type) ? typeName(type) : cardName,
  );
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(
      const Rect.fromLTWH(0, 0, side, side),
      Paint()..color = background,
    );
  final text = TextPainter(
    text: TextSpan(
      text: initials,
      style: TextStyle(
        color: onTypeColor(background),
        fontWeight: FontWeight.w600,
        fontSize: visible * (initials.length > 1 ? 0.36 : 0.40),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  text.paint(canvas, Offset((side - text.width) / 2, (side - text.height) / 2));
  final image = await recorder.endRecording().toImage(
    side.toInt(),
    side.toInt(),
  );
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  return png!.buffer.asUint8List();
}

/// "Aggiungi alla schermata Home" (decisione 89): compare subito la conferma
/// di Android; quando l'icona è aggiunta, l'avviso arriva a
/// [listenShortcuts] e l'elenco mostra il messaggio.
Future<void> addCardShortcut(
  BuildContext context,
  db.Card card,
  db.CardType? type,
) async {
  final icon = await shortcutIcon(type, card.name);
  final ok = await pinShortcut(card.id, card.name, icon);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.t.shortcutFailed)));
  }
}

/// Dopo una modifica: nome e icona aggiornati, se l'icona è sulla Home.
Future<void> refreshCardShortcut(db.Card card, db.CardType? type) async {
  if (!await canPinShortcut()) return;
  await updateShortcut(card.id, card.name, await shortcutIcon(type, card.name));
}

/// Apre la scheda della tessera, con tipologia e sezione.
Future<void> openCardScreen(
  BuildContext context,
  db.AppDatabase d,
  db.Card card,
) async {
  final type = await (d.select(
    d.cardTypes,
  )..where((t) => t.id.equals(card.typeId))).getSingleOrNull();
  final section = await (d.select(
    d.sections,
  )..where((s) => s.id.equals(card.sectionId))).getSingleOrNull();
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CardScreen(
        database: d,
        card: card,
        type: type,
        sectionName: section?.name ?? '',
      ),
    ),
  );
}

/// Tocco su una scorciatoia: si apre la tessera, oppure, se è nel cestino o
/// non c'è più, il pannello della videata 20. Si chiama dall'elenco, dopo la
/// prima schermata. Restituisce true se ha aperto qualcosa.
Future<bool> openShortcutCard(BuildContext context, db.AppDatabase d) async {
  final target = await takeShortcutCard();
  if (target == null || !context.mounted) return false;
  // Dall'elenco: le pagine aperte prima si chiudono.
  Navigator.of(context).popUntil((r) => r.isFirst);
  final card = await d.cardById(target.id);
  if (!context.mounted) return false;
  if (card != null && card.deletedAt == null) {
    await openCardScreen(context, d, card);
    return true;
  }
  final restore = await showDialog<bool>(
    context: context,
    builder: (_) =>
        _MissingCardDialog(card: card, name: card?.name ?? target.name),
  );
  if (!context.mounted || restore == null) return true;
  if (restore && card != null) {
    if (await recoverCardWithChoice(context, d, card) && context.mounted) {
      final back = await d.cardById(card.id);
      if (back != null && context.mounted) {
        await openCardScreen(context, d, back);
      }
    }
  } else if (!restore) {
    await disableShortcut(target.id, tr.shortcutGoneTitle);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t.shortcutDisabled),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }
  return true;
}

/// Videata 20 (decisione 90): tessera nel cestino (ripristino o
/// eliminazione della scorciatoia) o eliminata del tutto (solo
/// eliminazione). true = ripristina, false = elimina la scorciatoia.
class _MissingCardDialog extends StatelessWidget {
  const _MissingCardDialog({required this.card, required this.name});

  /// La tessera nel cestino, o null se non c'è più.
  final db.Card? card;
  final String name;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final deletedAt = card?.deletedAt;
    final inTrash = deletedAt != null;
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.star, shape: BoxShape.circle),
            child: const Text(
              '!',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              inTrash
                  ? context.t.shortcutInTrashTitle
                  : context.t.shortcutGoneTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Text(
        inTrash
            ? context.t.shortcutInTrashBody(
                name,
                deletedLabel(deletedAt, DateTime.now()).toLowerCase(),
              )
            : context.t.shortcutGoneBody(name),
        style: const TextStyle(height: 1.4),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: 10,
      actions: [
        if (inTrash)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.t.restoreCard),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: c.danger),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.t.deleteShortcut),
          ),
        ),
        if (!inTrash)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.t.close),
            ),
          ),
      ],
    );
  }
}
