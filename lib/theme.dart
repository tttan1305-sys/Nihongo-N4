import 'package:flutter/material.dart';

/// Bảng màu chung của ứng dụng: nền xanh đêm, thẻ tối viền neon.
abstract final class AppColors {
  static const primary = Color(0xFF4D8DFF);
  static const primaryDark = Color(0xFF2A5BE0);
  static const primarySoft = Color(0xFF1A2E66);
  static const purple = Color(0xFFA67CFF);
  static const purpleSoft = Color(0xFF2A1F55);
  static const green = Color(0xFF2FD39A);
  static const greenSoft = Color(0xFF0F3B39);
  static const pink = Color(0xFFFF6FA5);
  static const pinkSoft = Color(0xFF3F1B44);
  static const orange = Color(0xFFFFA94D);
  static const orangeSoft = Color(0xFF3A2A2A);
  static const red = Color(0xFFFF5F6D);
  static const redSoft = Color(0xFF431D33);
  static const background = Color(0xFF0B1430);
  static const surface = Color(0xFF14224A);
  static const surfaceHigh = Color(0xFF1B2C5C);
  static const text = Color(0xFFF2F5FF);
  static const muted = Color(0xFF8C9BC4);
  static const border = Color(0xFF2A3B6E);

  /// Màu xoay vòng cho số thứ tự trong danh sách.
  static const cycle = [primary, pink, green, orange, purple];
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    surfaceContainerHighest: AppColors.surfaceHigh,
    outline: AppColors.border,
  );
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: Brightness.dark,
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.text,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0E1A3C),
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primarySoft,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.muted,
        ),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.primary,
      dividerColor: AppColors.border,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.primarySoft,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
    popupMenuTheme: const PopupMenuThemeData(color: AppColors.surfaceHigh),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: TextStyle(color: AppColors.text),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.muted,
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.surfaceHigh,
      ),
    ),
  );
}
