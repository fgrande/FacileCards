// Bozza salvata prima di aprire la fotocamera o la galleria.
//
// Mentre si scatta la foto FacileCards resta in pausa e, se il telefono ha
// poca memoria, Android la chiude; al ritorno l'app ripartirebbe
// dall'elenco perdendo i dati scritti e la foto. Per questo, prima di
// lasciare l'app, si salva una bozza di quello che c'è sulla pagina; se
// l'app riparte, l'elenco la trova e riapre la pagina com'era, con la foto
// appena scattata recuperata da image_picker (retrieveLostData).
//
// La bozza sta nello spazio privato dell'app (fuori dal backup di Android) e
// si cancella appena la scelta della foto torna normalmente.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Che cosa si stava facendo quando si è aperta la fotocamera.
abstract final class DraftKind {
  /// Pagina della nuova tessera o della modifica (videata 8).
  static const form = 'form';

  /// Foto aggiunta o sostituita dalla scheda della tessera (videate 25–28):
  /// la foto va direttamente sulla tessera.
  static const cardPhoto = 'cardPhoto';
}

/// Bozza per una foto scelta dalla scheda della tessera: al ritorno va
/// direttamente sulla tessera [cardId].
PhotoDraft cardPhotoDraft(String cardId, String side) =>
    PhotoDraft(kind: DraftKind.cardPhoto, side: side, data: {'cardId': cardId});

class PhotoDraft {
  PhotoDraft({
    required this.kind,
    required this.side,
    this.data = const {},
    this.photos = const {},
  });

  /// [DraftKind].
  final String kind;

  /// Lato della foto che si stava scegliendo (fronte o retro).
  final String side;

  /// Dati della pagina (testi, scelte), come JSON semplice.
  final Map<String, dynamic> data;

  /// Foto già scelte sulla pagina e non ancora salvate (lato → immagine).
  final Map<String, Uint8List> photos;

  /// Solo per le prove: cartella da usare al posto di quella dell'app.
  static Directory? testDirectory;

  static Future<Directory> _dir() async {
    final test = testDirectory;
    if (test != null) return Directory(p.join(test.path, 'draft'));
    final base = await getApplicationSupportDirectory();
    return Directory(p.join(base.path, 'draft'));
  }

  /// Salva la bozza, sostituendo quella che c'era.
  Future<void> save() async {
    final dir = await _dir();
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    for (final e in photos.entries) {
      await File(p.join(dir.path, '${e.key}.img')).writeAsBytes(e.value);
    }
    // Il file principale per ultimo: se c'è, la bozza è completa.
    await File(p.join(dir.path, 'draft.json')).writeAsString(
      jsonEncode({
        'kind': kind,
        'side': side,
        'data': data,
        'photos': photos.keys.toList(),
        'savedAt': DateTime.now().toIso8601String(),
      }),
      flush: true,
    );
  }

  /// La bozza salvata, o null se non c'è (o è illeggibile).
  static Future<PhotoDraft?> load() async {
    try {
      final dir = await _dir();
      final main = File(p.join(dir.path, 'draft.json'));
      if (!await main.exists()) return null;
      final json =
          jsonDecode(await main.readAsString()) as Map<String, dynamic>;
      // Una bozza vecchia (l'app si era chiusa per altri motivi) non si
      // ripropone: dopo un'ora non è più la foto che si stava scattando.
      final savedAt = DateTime.tryParse(json['savedAt'] as String? ?? '');
      if (savedAt == null ||
          DateTime.now().difference(savedAt) > const Duration(hours: 1)) {
        await clear();
        return null;
      }
      final photos = <String, Uint8List>{};
      for (final side in (json['photos'] as List).cast<String>()) {
        final f = File(p.join(dir.path, '$side.img'));
        if (await f.exists()) photos[side] = await f.readAsBytes();
      }
      return PhotoDraft(
        kind: json['kind'] as String,
        side: json['side'] as String,
        data: (json['data'] as Map).cast<String, dynamic>(),
        photos: photos,
      );
    } catch (_) {
      return null;
    }
  }

  /// Cancella la bozza.
  static Future<void> clear() async {
    try {
      final dir = await _dir();
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {
      // Niente di grave: al prossimo avvio si riprova.
    }
  }
}
