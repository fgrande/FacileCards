import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../theme.dart';

/// Scelta della lingua (configurazione iniziale e Impostazioni, videate 1 e
/// 14): bandiera, nome nella lingua stessa e spunta su quella attuale.
/// Restituisce la lingua toccata, o null se si chiude senza scegliere.
Future<String?> showLanguagePicker(BuildContext context, String current) =>
    showDialog<String>(
      context: context,
      builder: (context) {
        final c = AppColors.of(context);
        return SimpleDialog(
          title: Text(context.t.language),
          children: [
            for (final l in supportedLanguages)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(l),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      languageFlags[l] ?? '',
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        languageNames[l]!,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: l == current
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (l == current) Icon(Icons.check, color: c.primary),
                  ],
                ),
              ),
          ],
        );
      },
    );
