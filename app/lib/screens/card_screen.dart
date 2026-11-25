import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:material_ui/material_ui.dart';

import '../barcode_support.dart';
import '../ads.dart';
import '../data/catalog.dart';
import '../data/database.dart' as db;
import '../format_utils.dart';
import '../l10n/l10n.dart';
import '../photo_draft.dart';
import '../photos.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../ui.dart';
import '../transfer/export.dart' show ExportTarget;
import 'export_screen.dart';
import 'new_card_data_screen.dart';
import 'photo_picker.dart';
import 'photo_viewer_screen.dart';

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
  // Si aggiorna dopo una modifica (matita).
  late db.Card _card = widget.card;
  late bool _favorite = _card.favorite;
  late String _sectionName = widget.sectionName;
  late final _photos = widget.database.watchCardPhotos(_card.id);
  PhotoStore? _store;

  Future<void> _update(db.CardsCompanion values) {
    final d = widget.database;
    return (d.update(
      d.cards,
    )..where((c) => c.id.equals(_card.id))).write(values);
  }

  @override
  void initState() {
    super.initState();
    _update(db.CardsCompanion(lastUsedAt: Value(DateTime.now())));
    PhotoStore.instance.then((s) {
      if (mounted) setState(() => _store = s);
    });
    _loadPayApp();
  }

  /// App per pagare da aprire dalla tessera (decisione 118); compare dopo
  /// il codice, senza ritardarlo, e solo se è ancora installata.
  PayApp? _payApp;

  Future<void> _loadPayApp() async {
    final package = await widget.database.setting(db.SettingKeys.payApp) ?? '';
    if (package.isEmpty) return;
    final app = await payAppInfo(package);
    if (mounted && app != null) setState(() => _payApp = app);
  }

  Future<void> _openPayApp(PayApp app) async {
    if (!await openApp(app.package) && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.payAppGone(app.label))));
    }
  }

  bool get _frontRequired => widget.type?.isGeneric ?? false;

  Future<void> _openPhotos(String side) async {
    final store = _store;
    if (store == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewerScreen(
          database: widget.database,
          store: store,
          card: _card,
          frontRequired: _frontRequired,
          initialSide: side,
        ),
      ),
    );
  }

  /// Videata 28: senza foto del fronte si aggiunge quella, poi si passa al
  /// visualizzatore per il retro (decisione 101).
  Future<void> _addPhoto(Map<String, String> photos) async {
    final store = _store;
    if (store == null) return;
    final bytes = await pickCardPhoto(
      context,
      title: context.t.photoFront,
      draft: cardPhotoDraft(_card.id, PhotoSide.front),
    );
    if (bytes == null || !mounted) return;
    final name = await store.write(_card.id, PhotoSide.front, bytes);
    if (name == null) return;
    final old = await widget.database.setCardPhoto(
      _card.id,
      PhotoSide.front,
      name,
    );
    if (old != null) await store.delete(old);
    if (mounted) {
      await _openPhotos(
        photos.containsKey(PhotoSide.back) ? PhotoSide.front : PhotoSide.back,
      );
    }
  }

  /// Matita: la pagina della nuova tessera, già compilata. Al ritorno la
  /// scheda rilegge la tessera.
  Future<void> _edit() async {
    final type = widget.type;
    if (type == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewCardDataScreen(
          database: widget.database,
          type: type,
          card: _card,
        ),
      ),
    );
    if (saved != true) return;
    final d = widget.database;
    final card = await d.cardById(_card.id);
    if (card == null || !mounted) return;
    final section = await (d.select(
      d.sections,
    )..where((s) => s.id.equals(card.sectionId))).getSingleOrNull();
    if (!mounted) return;
    setState(() {
      _card = card;
      _favorite = card.favorite;
      _sectionName = section?.name ?? _sectionName;
    });
  }

  /// "Sposta": cambia la sezione della tessera.
  Future<void> _move() async {
    final sections = await widget.database.visibleSections();
    if (!mounted) return;
    final chosen = await showDialog<db.Section>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.t.moveToSection),
        children: [
          for (final s in sections)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(s),
              child: Text(
                s.name,
                style: TextStyle(
                  fontWeight: s.name == _sectionName ? FontWeight.w700 : null,
                ),
              ),
            ),
        ],
      ),
    );
    if (chosen == null || chosen.name == _sectionName) return;
    await widget.database.moveCard(_card.id, chosen.id);
    if (mounted) {
      setState(() {
        _sectionName = chosen.name;
        _card = _card.copyWith(sectionId: chosen.id);
      });
    }
  }

  /// Miniatura della foto del fronte con il numero di foto, oppure
  /// il pulsante "Aggiungi foto" (videate 5 e 28).
  Widget _photoTile() => StreamBuilder<Map<String, String>>(
    stream: _photos,
    builder: (context, snap) {
      final photos = snap.data ?? const <String, String>{};
      final front = photos[PhotoSide.front];
      final store = _store;
      final scheme = Theme.of(context).colorScheme;
      if (front == null || store == null) {
        return OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(64),
            side: BorderSide(color: AppColors.of(context).primary),
          ),
          onPressed: store == null ? null : () => _addPhoto(photos),
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(context.t.addPhoto),
        );
      }
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openPhotos(PhotoSide.front),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(store.file(front), fit: BoxFit.cover),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.inverseSurface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      context.t.photoCount(photos.length),
                      style: TextStyle(
                        color: scheme.onInverseSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Future<void> _toggleFavorite() async {
    setState(() {
      _favorite = !_favorite;
      _card = _card.copyWith(favorite: _favorite);
    });
    await _update(db.CardsCompanion(favorite: Value(_favorite)));
  }

  /// Videata 18: cestino o eliminazione definitiva.
  Future<void> _delete() async {
    if (await confirmDeleteCard(context, widget.database, _card) && mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Riga dei dettagli: etichetta a sinistra, valore a destra.
  Widget _info(String label, String value) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: c.muted, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: c.text,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final c = _card;
    final format = formatFromText(c.codeFormat);
    final barcode = drawableBarcode(format);
    final holder = c.holder;
    final notes = c.notes;
    final expires = c.expiresOn;
    final type = widget.type;
    // L'intestazione ha il colore della tipologia, uguale nei due temi.
    final headerColor = Color(type?.color ?? TypeLogo.fallbackColor);
    // Testo e icone: bianchi, scuri sui colori chiari (gialli).
    final fg = onTypeColor(headerColor);
    final darkText = fg != Colors.white;
    final details = [
      if (holder != null) _info(context.t.holder, holder),
      if (expires != null) _info(context.t.expiry, longDate(expires)),
      if (notes != null) _info(context.t.notes, notes),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: headerColor,
        foregroundColor: fg,
        systemOverlayStyle: darkText
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        title: Text(c.name, overflow: TextOverflow.ellipsis),
        titleTextStyle: TextStyle(
          color: fg,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            tooltip: context.t.favorite,
            icon: Icon(
              _favorite ? Icons.star_rounded : Icons.star_outline_rounded,
              // Sul giallo la stella gialla non si vedrebbe: piena e scura.
              color: _favorite && !darkText ? const Color(0xFFFFD166) : fg,
              size: 28,
            ),
            onPressed: _toggleFavorite,
          ),
          if (widget.type != null)
            IconButton(
              tooltip: context.t.edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: _edit,
            ),
          IconButton(
            tooltip: context.t.share,
            icon: const Icon(Icons.share),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ExportScreen(
                  database: widget.database,
                  target: ExportTarget.card(_card.id),
                  name: _card.name,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: context.t.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fascia colorata dietro la parte alta del codice.
          Container(
            height: 300 + MediaQuery.paddingOf(context).top - 56,
            color: headerColor,
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + kToolbarHeight,
              16,
              24,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: fg.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        initialsOf(
                          type != null && hasFixedName(type)
                              ? type.name
                              : c.name,
                        ),
                        style: TextStyle(
                          color: fg,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fg,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [?holder, _sectionName].join(' · '),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fg.withValues(alpha: 0.88),
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_payApp case final app?) ...[
                      const SizedBox(width: 10),
                      _PayAppButton(app: app, onTap: () => _openPayApp(app)),
                    ],
                  ],
                ),
              ),
              // Il riquadro del codice resta bianco anche nel tema scuro:
              // gli scanner leggono male i codici su fondo scuro.
              Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD5DBE8)),
                ),
                child: Column(
                  children: [
                    if (barcode == null)
                      Text(
                        context.t.formatNotDrawable(c.codeFormat),
                        style: const TextStyle(color: Colors.black),
                      )
                    else
                      bw.BarcodeWidget(
                        barcode: barcode,
                        data: c.code,
                        width: double.infinity,
                        height: isSquareFormat(format) ? 240 : 180,
                        drawText: true,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                        ),
                        errorBuilder: (context, error) => Text(
                          context.t.invalidCode(error.toString()),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      formatLabel(format),
                      style: const TextStyle(
                        color: Color(0xFF5F6B80),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (details.isNotEmpty) ...[
                Panel(
                  child: Column(
                    children: [
                      for (var i = 0; i < details.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                        details[i],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(child: _photoTile()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(64),
                      ),
                      onPressed: _move,
                      child: Text(context.t.move),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                context.t.addedOn(longDate(c.createdAt)),
                style: TextStyle(color: colors.muted, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
      // Decisione 95: banner al piede, in uno spazio già riservato; il
      // codice è disegnato per primo e non si sposta.
      bottomNavigationBar: AdFooter(unitId: AdUnits.card),
    );
  }
}

/// Videata 18 (decisioni 20 e 75): cestino o eliminazione definitiva, sia
/// dalla barra della tessera sia trascinando la riga dell'elenco.
/// Restituisce true se la tessera è stata eliminata.
Future<bool> confirmDeleteCard(
  BuildContext context,
  db.AppDatabase database,
  db.Card card,
) async {
  final choice = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.t.deleteCardQuestion(card.name)),
      content: Text(context.t.trashRecoverable(db.AppDatabase.trashDays)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop('forever'),
          child: Text(context.t.deleteForever),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop('trash'),
          child: Text(context.t.moveToTrash),
        ),
      ],
    ),
  );
  if (choice == null) return false;
  if (choice == 'trash') {
    await database.moveCardToTrash(card.id);
  } else {
    await database.deleteCardForever(card.id);
  }
  return true;
}

/// Pulsante bianco nella fascia della tessera con icona e nome dell'app per
/// pagare (videata 5, decisione 118). Colori fissi: sta sul colore della
/// tipologia, come le altre scritte bianche della fascia.
class _PayAppButton extends StatelessWidget {
  const _PayAppButton({required this.app, required this.onTap});

  final PayApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const StadiumBorder(),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Tooltip(
        message: context.t.openPayApp(app.label),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(app.icon, width: 24, height: 24),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 96),
                child: Text(
                  app.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF161B26),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
