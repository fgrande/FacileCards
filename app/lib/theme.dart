import 'package:material_ui/material_ui.dart';

/// Colori dei disegni (docs/02-videate.md, "Tema scuro"), chiari e scuri.
/// Si leggono con `AppColors.of(context)`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.border,
    required this.divider,
    required this.text,
    required this.muted,
    required this.primary,
    required this.infoBg,
    required this.infoText,
    required this.warn,
    required this.warnBg,
    required this.danger,
    required this.dangerBg,
    required this.segment,
    required this.star,
    required this.success,
    required this.successBg,
  });

  final Color background;
  final Color surface;
  final Color border;
  final Color divider;
  final Color text;
  final Color muted;
  final Color primary;
  final Color infoBg;
  final Color infoText;
  final Color warn;
  final Color warnBg;
  final Color danger;
  final Color dangerBg;
  final Color segment; // fondo del selettore "Tutte / Per sezione"
  final Color star;
  final Color success;
  final Color successBg;

  static const light = AppColors(
    background: Color(0xFFF4F6FB),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFD5DBE7),
    divider: Color(0xFFEDF0F5),
    text: Color(0xFF161B26),
    muted: Color(0xFF5F6B80),
    primary: Color(0xFF1F5FD6),
    infoBg: Color(0xFFDCE7FF),
    infoText: Color(0xFF0B2A66),
    warn: Color(0xFFB26A00),
    warnBg: Color(0xFFFFF3D6),
    danger: Color(0xFFC62828),
    dangerBg: Color(0xFFFDE7E9),
    segment: Color(0xFFE6EAF2),
    star: Color(0xFFF2A516),
    success: Color(0xFF1E6B3A),
    successBg: Color(0xFFE6F3EA),
  );

  static const dark = AppColors(
    background: Color(0xFF0F131A),
    surface: Color(0xFF1A2029),
    border: Color(0xFF323A48),
    divider: Color(0xFF262D38),
    text: Color(0xFFE8ECF3),
    muted: Color(0xFF9AA5B8),
    primary: Color(0xFF4C87F2),
    infoBg: Color(0xFF1B2B4B),
    infoText: Color(0xFFCFE0FF),
    warn: Color(0xFFF0B24A),
    warnBg: Color(0xFF3A2C0C),
    danger: Color(0xFFE5534B),
    dangerBg: Color(0xFF3D1A1D),
    segment: Color(0xFF232A35),
    star: Color(0xFFF2B33D),
    success: Color(0xFF7FD19B),
    successBg: Color(0xFF15301F),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

/// Tema dell'app, chiaro o scuro, costruito sui colori dei disegni.
ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: brightness,
      ).copyWith(
        primary: c.primary,
        onPrimary: Colors.white,
        surface: c.background,
        onSurface: c.text,
        onSurfaceVariant: c.muted,
        surfaceContainerLowest: c.surface,
        surfaceContainerLow: c.surface,
        surfaceContainer: c.surface,
        surfaceContainerHigh: c.surface,
        surfaceContainerHighest: c.segment,
        outline: c.border,
        outlineVariant: c.border,
        error: c.danger,
      );
  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c.border),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    extensions: [c],
    scaffoldBackgroundColor: c.background,
    dividerTheme: DividerThemeData(color: c.divider, space: 1, thickness: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.text,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: c.text,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: c.primary, width: 1.6),
      ),
      labelStyle: TextStyle(color: c.muted),
      hintStyle: TextStyle(color: c.muted),
      helperStyle: TextStyle(color: c.muted),
      prefixIconColor: c.muted,
      suffixIconColor: c.muted,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 50),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 50),
        backgroundColor: c.surface,
        foregroundColor: c.primary,
        side: BorderSide(color: c.border),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.primary,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: c.muted,
      titleTextStyle: TextStyle(
        color: c.text,
        fontSize: 16.5,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(color: c.muted, fontSize: 13.5),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    badgeTheme: BadgeThemeData(backgroundColor: c.danger),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}
