import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart' as db;
import '../photo_draft.dart';
import '../photos.dart';
import 'card_screen.dart';
import 'new_card_data_screen.dart';
import 'photo_edit_screen.dart';

/// All'avvio, dopo la prima schermata: se Android aveva chiuso l'app mentre
/// si scattava o sceglieva una foto, riapre la pagina com'era, con la foto
/// appena scattata (vedi photo_draft.dart). Restituisce true se ha riaperto
/// qualcosa.
Future<bool> restorePhotoDraft(BuildContext context, db.AppDatabase d) async {
  final draft = await PhotoDraft.load();
  if (draft == null) return false;
  await PhotoDraft.clear();
  var photo = await _lostPhoto();
  if (!context.mounted) return false;
  // Come dopo uno scatto normale: prima il ritocco (videata 49).
  if (photo != null) {
    photo = await editCardPhoto(context, photo);
    if (!context.mounted) return false;
  }
  switch (draft.kind) {
    case DraftKind.form:
      return _restoreForm(context, d, draft, photo);
    case DraftKind.cardPhoto:
      return _restoreCardPhoto(context, d, draft, photo);
  }
  return false;
}

/// La foto che image_picker aveva ricevuto mentre l'app era chiusa.
Future<Uint8List?> _lostPhoto() async {
  try {
    final lost = await ImagePicker().retrieveLostData();
    final file = lost.file;
    if (lost.isEmpty || file == null) return null;
    return await file.readAsBytes();
  } catch (_) {
    return null;
  }
}

Future<db.CardType?> _type(db.AppDatabase d, String? id) async => id == null
    ? null
    : (d.select(d.cardTypes)..where((t) => t.id.equals(id))).getSingleOrNull();

Future<bool> _restoreForm(
  BuildContext context,
  db.AppDatabase d,
  PhotoDraft draft,
  Uint8List? photo,
) async {
  final type = await _type(d, draft.data['typeId'] as String?);
  if (type == null) return false;
  final cardId = draft.data['cardId'] as String?;
  final card = cardId == null ? null : await d.cardById(cardId);
  // Modificando una tessera che nel frattempo non c'è più: niente da fare.
  if (cardId != null && card == null) return false;
  final restored = PhotoDraft(
    kind: draft.kind,
    side: draft.side,
    data: draft.data,
    photos: {...draft.photos, draft.side: ?photo},
  );
  if (!context.mounted) return false;
  await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => NewCardDataScreen(
        database: d,
        type: type,
        card: card,
        restore: restored,
      ),
    ),
  );
  return true;
}

Future<bool> _restoreCardPhoto(
  BuildContext context,
  db.AppDatabase d,
  PhotoDraft draft,
  Uint8List? photo,
) async {
  final cardId = draft.data['cardId'] as String?;
  final card = cardId == null ? null : await d.cardById(cardId);
  if (card == null) return false;
  if (photo != null) {
    final store = await PhotoStore.instance;
    final name = await store.write(card.id, draft.side, photo);
    if (name != null) {
      final old = await d.setCardPhoto(card.id, draft.side, name);
      if (old != null) await store.delete(old);
    }
  }
  final type = await _type(d, card.typeId);
  final section = await (d.select(
    d.sections,
  )..where((s) => s.id.equals(card.sectionId))).getSingleOrNull();
  if (!context.mounted) return false;
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
  return true;
}
