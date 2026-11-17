import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../barcode_support.dart';
import '../gallery_scan.dart';
import '../system_settings.dart';

/// Esito della schermata di scansione: un codice letto, oppure la scelta
/// di scrivere il codice a mano.
class ScanOutcome {
  const ScanOutcome.code(this.code) : manual = false;
  const ScanOutcome.manual()
      : code = null,
        manual = true;

  final ScannedCode? code;
  final bool manual;
}

/// Videate 22, 23, 24: scansione con la fotocamera. Il primo codice
/// riconosciuto vince; si può scrivere il codice a mano. La lettura da
/// galleria sta nella videata 8 e, se la fotocamera manca, nella 24.
/// Il permesso della fotocamera si chiede qui, al primo tocco di "Scansiona".
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, this.typeName, this.expectedFormat});

  /// Nome della tipologia scelta e formato atteso (se la tipologia lo indica).
  final String? typeName;
  final String? expectedFormat;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = MobileScannerController();
  bool _done = false;
  bool _torch = false;
  String? _bannerTitle;
  String? _bannerDetail;
  Timer? _bannerTimer;

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _showBanner(String title, String detail) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerTitle = title;
      _bannerDetail = detail;
    });
    _bannerTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _bannerTitle = null;
          _bannerDetail = null;
        });
      }
    });
  }

  /// Controlla il codice letto; se va bene chiude la schermata.
  /// Restituisce false se l'ha rifiutato.
  bool _accept(Barcode b) {
    final check = checkScanned(b.rawValue, b.format,
        expectedFormat: widget.expectedFormat, typeName: widget.typeName);
    if (check == null) return false;
    if (!check.isAccepted) {
      _showBanner(check.title!, check.detail!);
      return false;
    }
    _done = true;
    Navigator.of(context).pop(ScanOutcome.code(check.code!));
    return true;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final b in capture.barcodes) {
      if (_accept(b)) return;
    }
  }

  /// Solo dalla videata 24: con la fotocamera attiva la galleria si sceglie
  /// già nella videata 8 (decisione 110).
  Future<void> _fromGallery() async {
    final check = await readCodeFromGallery(
        expectedFormat: widget.expectedFormat, typeName: widget.typeName);
    if (check == null || !mounted) return;
    if (check.isAccepted) {
      _done = true;
      Navigator.of(context).pop(ScanOutcome.code(check.code!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${check.title}\n${check.detail}')));
    }
  }

  void _manual() => Navigator.of(context).pop(const ScanOutcome.manual());

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (mounted) setState(() => _torch = !_torch);
  }

  Widget _overlay(BuildContext context, BoxConstraints constraints) {
    final label = widget.typeName == null
        ? null
        : (widget.expectedFormat == null
            ? widget.typeName
            : '${widget.typeName} · ${formatLabel(formatFromText(widget.expectedFormat!))}');
    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          if (_bannerTitle != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_bannerTitle!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  if (_bannerDetail != null)
                    Text(_bannerDetail!,
                        style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Inquadra il codice della tessera',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Si legge da solo: non serve toccare nulla.',
                    style: TextStyle(color: Colors.white70)),
                if (label != null) ...[
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(color: Colors.white70)),
                ],
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _toggleTorch,
                  icon: Icon(_torch ? Icons.flashlight_off : Icons.flashlight_on),
                  label: const Text('Torcia'),
                ),
                TextButton(
                  onPressed: _manual,
                  child: const Text('Inserisci il codice a mano'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Videata 24: fotocamera non disponibile (di solito permesso negato).
  Widget _error(BuildContext context, MobileScannerException error) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              denied ? 'Serve la fotocamera' : 'La fotocamera non è disponibile',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              denied
                  ? 'Per leggere il codice di una tessera FacileCards usa la fotocamera. Le immagini restano sul telefono.'
                  : 'Puoi leggere il codice da una foto della galleria o scriverlo a mano.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (denied)
              FilledButton(
                onPressed: openAppSettings,
                child: const Text('Apri impostazioni'),
              ),
            TextButton(
              onPressed: _manual,
              child: const Text('Inserisci il codice a mano'),
            ),
            TextButton(
              onPressed: _fromGallery,
              child: const Text('Leggi da una foto della galleria'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scansiona il codice'),
        backgroundColor: Colors.transparent,
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
        errorBuilder: _error,
        overlayBuilder: _overlay,
      ),
    );
  }
}
