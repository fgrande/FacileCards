import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../links.dart';
import '../system_settings.dart';
import '../theme.dart';
import '../ui.dart';

/// Videata 46 (decisione 118): l'app per pagare da aprire dalla tessera.
/// Restituisce il pacchetto scelto, '' per "Nessuna", null se si torna
/// indietro senza scegliere.
class PayAppScreen extends StatefulWidget {
  const PayAppScreen({super.key, required this.current});

  /// Pacchetto scelto ora ('' o null: nessuna).
  final String? current;

  @override
  State<PayAppScreen> createState() => _PayAppScreenState();
}

class _PayAppScreenState extends State<PayAppScreen> {
  List<PayApp>? _apps;

  @override
  void initState() {
    super.initState();
    findPayApps().then((apps) {
      if (mounted) setState(() => _apps = apps);
    });
  }

  Widget _radio(AppColors c, bool selected) => Icon(
    selected ? Icons.radio_button_checked : Icons.radio_button_off,
    color: selected ? c.primary : c.muted,
  );

  Widget _row(
    AppColors c, {
    required Widget leading,
    required String title,
    String? subtitle,
    required String value,
  }) => ListTile(
    contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
    leading: leading,
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle),
    trailing: _radio(c, (widget.current ?? '') == value),
    onTap: () => Navigator.of(context).pop(value),
  );

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final apps = _apps;
    return Scaffold(
      appBar: AppBar(title: Text(context.t.payApp)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Text(
              context.t.payAppIntro,
              style: TextStyle(color: c.muted, fontSize: 14),
            ),
          ),
          TileGroup(
            indent: 74,
            children: [
              _row(
                c,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: c.border),
                  ),
                  child: Icon(Icons.close, color: c.muted),
                ),
                title: context.t.payAppNone,
                subtitle: context.t.payAppNoneSub,
                value: '',
              ),
            ],
          ),
          GroupHeader(context.t.payAppsFound),
          if (apps == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (apps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.t.payAppsNoneFound,
                style: TextStyle(color: c.text, fontSize: 15),
              ),
            )
          else
            TileGroup(
              indent: 74,
              children: [
                for (final a in apps)
                  _row(
                    c,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.memory(a.icon, width: 44, height: 44),
                    ),
                    title: a.label,
                    value: a.package,
                  ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // La richiesta via mail compare quando c'è l'indirizzo
                // (decisione 36).
                if (contactEmail != null)
                  InkWell(
                    onTap: () => openUrl(
                      'mailto:$contactEmail?subject=${Uri.encodeComponent(context.t.payAppMissingSubject)}',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        context.t.payAppMissing,
                        style: TextStyle(
                          color: c.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Text(
                  context.t.payAppsExplain,
                  style: TextStyle(color: c.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
