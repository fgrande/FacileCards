import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../photo_draft.dart';
import '../photos.dart';

/// Chiede da dove prendere la foto (fotocamera o galleria) e la restituisce.
/// Null se si annulla o se la fotocamera non è consentita (con un messaggio).
/// Con [draft], prima di lasciare l'app si salva la bozza della pagina: se
/// Android chiude FacileCards mentre si scatta, al ritorno la pagina si
/// riapre com'era (vedi photo_draft.dart).
Future<Uint8List?> pickCardPhoto(
  BuildContext context, {
  required String title,
  PhotoDraft? draft,
}) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(context.t.takePhoto),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(context.t.chooseFromGallery),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null) return null;
  await draft?.save();
  try {
    // Il telefono riduce già la foto; shrinkPhoto controlla poi i 500 KB.
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: maxPhotoSide.toDouble(),
      maxHeight: maxPhotoSide.toDouble(),
      imageQuality: 85,
    );
    return file == null ? null : await file.readAsBytes();
  } on PlatformException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'camera_access_denied'
                ? context.t.cameraDeniedUseGallery
                : context.t.photoFailed,
          ),
        ),
      );
    }
    return null;
  } finally {
    // Tornati normalmente: la bozza non serve più.
    if (draft != null) await PhotoDraft.clear();
  }
}

/// Nome del lato come si mostra all'utente.
String sideLabel(String side) =>
    side == PhotoSide.front ? tr.sideFront : tr.sideBack;
