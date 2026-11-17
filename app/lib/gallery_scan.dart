import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'barcode_support.dart';

/// Legge il codice da una foto della galleria (videate 8 e 24). Non serve il
/// permesso della fotocamera. Restituisce null se non si è scelta nessuna foto.
/// Vince il primo codice accettato; altrimenti si mostra il primo rifiuto.
Future<ScanCheck?> readCodeFromGallery({
  String? expectedFormat,
  String? typeName,
}) async {
  try {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final capture = await MobileScannerPlatform.instance.analyzeImage(file.path);
    ScanCheck? firstRejection;
    for (final b in capture?.barcodes ?? const <Barcode>[]) {
      final check = checkScanned(b.rawValue, b.format,
          expectedFormat: expectedFormat, typeName: typeName);
      if (check == null) continue;
      if (check.isAccepted) return check;
      firstRejection ??= check;
    }
    return firstRejection ??
        const ScanCheck.rejected('Nessun codice trovato',
            'Scegli una foto in cui il codice si veda bene.');
  } catch (_) {
    return const ScanCheck.rejected(
        'Non sono riuscito a leggere la foto', 'Prova con un\'altra immagine.');
  }
}
