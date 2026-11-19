import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../theme.dart';
import '../ui.dart';

/// Videata 40 (decisione 105): prima della finestra di Google, perché ci
/// sono gli annunci e cosa cambia se non si acconsente. Si vede una volta.
class AdsIntroScreen extends StatelessWidget {
  const AdsIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                  children: [
                    const Center(child: AppMark(height: 76)),
                    const SizedBox(height: 28),
                    Text(
                      context.t.adsIntroTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.t.adsIntroSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.muted, fontSize: 15),
                    ),
                    const SizedBox(height: 28),
                    _AdSample(colors: c),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.infoBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        context.t.adsIntroNote,
                        style: TextStyle(
                          color: c.infoText,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.t.continueButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un banner d'esempio, disegnato (come nella videata 40).
class _AdSample extends StatelessWidget {
  const _AdSample({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: c.border,
        borderRadius: BorderRadius.circular(h / 2),
      ),
    );
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.segment,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t.adLabel,
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                bar(150, 8),
                const SizedBox(height: 4),
                bar(96, 6),
              ],
            ),
          ),
          bar(66, 24),
        ],
      ),
    );
  }
}
