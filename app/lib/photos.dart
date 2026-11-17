import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'data/database.dart';

/// Lati della tessera fotografabili.
abstract final class PhotoSide {
  static const front = 'front';
  static const back = 'back';
}

/// Limiti delle foto (decisione 6): circa 1600 px sul lato lungo e al massimo
/// 500 KB per immagine.
const maxPhotoSide = 1600;
const maxPhotoBytes = 500 * 1024;

/// Riduce una foto entro i limiti: la ridimensiona se serve e la salva in JPEG
/// abbassando la qualità finché non sta sotto i 500 KB. Restituisce null se i
/// byte non sono un'immagine.
Uint8List? shrinkPhoto(Uint8List bytes) {
  var image = img.decodeImage(bytes);
  if (image == null) return null;
  image = img.bakeOrientation(image);
  final longSide = image.width > image.height ? image.width : image.height;
  if (longSide > maxPhotoSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxPhotoSide)
        : img.copyResize(image, height: maxPhotoSide);
  }
  Uint8List out = img.encodeJpg(image, quality: 85);
  for (var quality = 75; out.length > maxPhotoBytes && quality >= 25; quality -= 10) {
    out = img.encodeJpg(image, quality: quality);
  }
  // Caso estremo: si rimpicciolisce ancora finché non sta nel limite.
  while (out.length > maxPhotoBytes && image!.width > 400) {
    image = img.copyResize(image, width: (image.width * 0.8).round());
    out = img.encodeJpg(image, quality: 60);
  }
  return out;
}

/// Foto della tessera nello spazio privato dell'app (cartella `photos`).
/// Nel database c'è solo il nome del file (tabella CardImages).
class PhotoStore {
  PhotoStore(this.directory);

  final Directory directory;

  static Future<PhotoStore>? _instance;

  /// Il magazzino dell'app, aperto una volta sola.
  static Future<PhotoStore> get instance => _instance ??= open();

  static Future<PhotoStore> open() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'photos'));
    await dir.create(recursive: true);
    return PhotoStore(dir);
  }

  File file(String fileName) => File(p.join(directory.path, fileName));

  /// Riduce la foto (in un isolate, per non bloccare l'interfaccia) e la
  /// scrive con un nome nuovo. Restituisce il nome del file, o null se non è
  /// un'immagine.
  Future<String?> write(String cardId, String side, Uint8List bytes) async {
    final small = await compute(shrinkPhoto, bytes);
    if (small == null) return null;
    // Nome nuovo a ogni sostituzione: l'immagine vecchia non resta in cache.
    final name = '${cardId}_${side}_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await file(name).writeAsBytes(small, flush: true);
    return name;
  }

  Future<void> delete(String fileName) async {
    final f = file(fileName);
    if (await f.exists()) await f.delete();
  }

  /// Cancella i file che il database non conosce più (per esempio le foto
  /// delle tessere svuotate dal cestino all'avvio).
  Future<void> removeOrphans(AppDatabase database) async {
    final known = (await database.select(database.cardImages).get())
        .map((i) => i.fileName)
        .toSet();
    await for (final entity in directory.list()) {
      if (entity is File && !known.contains(p.basename(entity.path))) {
        await entity.delete();
      }
    }
  }
}
