import 'package:material_ui/material_ui.dart';

import '../card_request.dart';
import '../gallery_scan.dart';
import '../l10n/l10n.dart';
import '../system_settings.dart';
import '../theme.dart';
import 'scan_screen.dart';

/// Videata 48: richiesta di una tessera mancante (decisioni 36 e 120).
/// Si apre dalle Impostazioni e da "Nuova tessera" quando la ricerca non
/// trova niente ([initialShop] è il nome cercato).
class CardRequestScreen extends StatefulWidget {
  const CardRequestScreen({super.key, this.initialShop = ''});

  final String initialShop;

  @override
  State<CardRequestScreen> createState() => _CardRequestScreenState();
}

class _CardRequestScreenState extends State<CardRequestScreen> {
  late final _shop = TextEditingController(text: widget.initialShop.trim());

  /// Formato del codice letto: il codice stesso non si tiene.
  ReadFormat? _format;

  @override
  void dispose() {
    _shop.dispose();
    super.dispose();
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _scan() async {
    final outcome = await Navigator.of(context).push<ScanOutcome>(
      MaterialPageRoute(builder: (_) => const ScanScreen(allowManual: false)),
    );
    final code = outcome?.code;
    if (code == null || !mounted) return;
    setState(() => _format = ReadFormat.of(code));
  }

  Future<void> _fromGallery() async {
    final check = await readCodeFromGallery();
    if (check == null || !mounted) return;
    if (!check.isAccepted) return _message('${check.title}\n${check.detail}');
    setState(() => _format = ReadFormat.of(check.code!));
  }

  Future<void> _send() async {
    final version = await appVersion();
    final url = cardRequestMailto(
      shop: _shop.text,
      format: _format,
      version: version,
    );
    if (!await openUrl(url) && mounted) _message(context.t.requestNoMailApp);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final muted = TextStyle(color: c.muted, fontSize: 14, height: 1.35);
    final format = _format;
    return Scaffold(
      appBar: AppBar(title: Text(context.t.requestTitle)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.t.requestMailHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted, fontSize: 12.5),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: _shop,
                builder: (context, value, _) => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: value.text.trim().isEmpty ? null : _send,
                    child: Text(context.t.requestWriteMail),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          Text(context.t.requestIntro, style: muted),
          const SizedBox(height: 14),
          TextField(
            controller: _shop,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: context.t.requestShopName),
          ),
          const SizedBox(height: 22),
          Text(
            context.t.requestCodeHeader.toUpperCase(),
            style: TextStyle(
              color: c.muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(context.t.requestCodeExplain, style: muted),
          const SizedBox(height: 10),
          // In evidenza (richiesta di Fabio): il codice non esce dal telefono.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.dangerBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, color: c.danger, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.t.requestCodeNotSent,
                    style: TextStyle(
                      color: c.danger,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _scan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(context.t.scan),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _fromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(context.t.fromGallery),
                ),
              ),
            ],
          ),
          if (format != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.infoBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: c.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t.requestFormatRead(
                            format.label,
                            format.length,
                          ),
                          style: TextStyle(
                            color: c.infoText,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.t.requestCodeStays,
                          style: TextStyle(
                            color: c.infoText.withValues(alpha: 0.8),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(context.t.requestPhotoHint, style: muted),
        ],
      ),
    );
  }
}
