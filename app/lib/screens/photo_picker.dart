import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../photos.dart';

/// Chiede da dove prendere la foto (fotocamera o galleria) e la restituisce.
/// Null se si annulla o se la fotocamera non è consentita (con un messaggio).
Future<Uint8List?> pickCardPhoto(BuildContext context, {required String title}) async {
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
            title: const Text('Scatta una foto'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Scegli dalla galleria'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null) return null;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code == 'camera_access_denied'
            ? 'La fotocamera non è consentita: puoi scegliere la foto dalla galleria.'
            : 'Non sono riuscito a prendere la foto.'),
      ));
    }
    return null;
  }
}

/// Nome del lato come si mostra all'utente.
String sideLabel(String side) => side == PhotoSide.front ? 'Fronte' : 'Retro';
