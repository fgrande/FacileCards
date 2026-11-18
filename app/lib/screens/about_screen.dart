import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../links.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../ui.dart';

/// Videata 21: informazioni sull'app, con l'avvertenza sui marchi
/// (decisione 99).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    if (!await openUrl(url) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.noAppToOpen(url))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.t.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 48),
          const Center(child: AppMark(height: 80)),
          const SizedBox(height: 16),
          Text('FacileCards',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: c.text, fontSize: 24, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          FutureBuilder<String>(
            future: appVersion(),
            builder: (context, snap) => Text(
              snap.hasData ? context.t.versionNumber(snap.data!) : '',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          Text(context.t.developedBy('Fabio Grande'),
              textAlign: TextAlign.center,
              style: TextStyle(color: c.text, fontSize: 15)),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Panel(
              padding: const EdgeInsets.all(18),
              child: Text(
                context.t.trademarkDisclaimer,
                style: TextStyle(color: c.text, fontSize: 14.5, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TileGroup(
            indent: 16,
            children: [
              ListTile(
                title: Text(context.t.privacyPolicy),
                trailing: const Chevron(),
                onTap: () => _open(context, privacyUrl),
              ),
              ListTile(
                title: Text(context.t.website),
                subtitle: const Text(siteLabel),
                trailing: const Chevron(),
                onTap: () => _open(context, siteUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
