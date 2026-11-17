import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Campo di ricerca a pillola (videate 2, 3, 7).
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: color, width: width),
        );
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: border(c.border),
        enabledBorder: border(c.border),
        focusedBorder: border(c.primary, 1.6),
      ),
      onChanged: onChanged,
    );
  }
}
