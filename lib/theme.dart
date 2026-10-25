import 'package:flutter/material.dart';

import 'skins.dart';
import 'widgets/content_scale.dart';

export 'skins.dart';

/// Màu dùng chung, đọc từ bảng màu đang chọn. Giữ tên cũ để các màn
/// không phải đổi chỗ gọi; chỉ gỡ `const` ở nơi dùng.
abstract final class AppColors {
  static SkinPalette get _p => SkinPalette.current;
  static Color get primary => _p.primary;
  static Color get primaryDark => _p.primaryDark;
  static Color get primarySoft => _p.primarySoft;
  static Color get onPrimary => _p.onPrimary;
  static Color get primaryText => _p.primaryText;
  static Color get purple => _p.purple;
  static Color get purpleSoft => _p.purpleSoft;
  static Color get green => _p.green;
  static Color get greenSoft => _p.greenSoft;
  static Color get pink => _p.pink;
  static Color get pinkSoft => _p.pinkSoft;
  static Color get orange => _p.orange;
  static Color get orangeSoft => _p.orangeSoft;
  static Color get red => _p.red;
  static Color get redSoft => _p.redSoft;
  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get surfaceHigh => _p.surfaceHigh;
  static Color get text => _p.text;
  static Color get muted => _p.muted;
  static Color get border => _p.border;
  static List<Color> get cycle => _p.cycle;
}

ThemeData buildAppTheme(SkinPalette p) {
  final r = switch (p.skin) {
    AppSkin.mechanical => 4.0,
    AppSkin.anime => 22.0,
    AppSkin.neon => 14.0,
  };
  final cardR = switch (p.skin) {
    AppSkin.mechanical => 4.0,
    AppSkin.anime => 22.0,
    AppSkin.neon => 18.0,
  };
  final side = BorderSide(
    color: p.border,
    width: p.skin == AppSkin.anime ? 2 : 1,
  );
  final font = switch (p.skin) {
    AppSkin.mechanical => 'ChakraPetch',
    AppSkin.anime => 'Nunito',
    AppSkin.neon => null,
  };
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
  final anime = p.skin == AppSkin.anime;
  final scheme = ColorScheme.fromSeed(
    seedColor: p.primary,
    brightness: p.brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    surface: p.surface,
    onSurface: p.text,
    surfaceContainerHighest: p.surfaceHigh,
    outline: p.border,
    error: p.red,
  );
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: p.brightness,
    fontFamily: font,
  );
  return base.copyWith(
    scaffoldBackgroundColor: p.background,
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.text,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: p.text,
        fontFamily: font,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardR),
        side: side,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: anime
            ? StadiumBorder(side: side)
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: p.skin == AppSkin.mechanical ? 1.2 : 0,
        ),
      ).copyWith(foregroundBuilder: _normalText),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom().copyWith(foregroundBuilder: _normalText),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: anime ? const StadiumBorder() : shape,
        side: side,
      ).copyWith(foregroundBuilder: _normalText),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.navBackground,
      surfaceTintColor: Colors.transparent,
      indicatorColor: anime
          ? p.primary
          : p.skin == AppSkin.mechanical
          ? Colors.transparent
          : p.primarySoft,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: p.skin == AppSkin.mechanical ? 0.8 : 0,
          color: s.contains(WidgetState.selected)
              ? p.navForeground
              : p.navMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? (anime ? p.onPrimary : p.navForeground)
              : p.navMuted,
        ),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: p.primaryText,
      unselectedLabelColor: p.muted,
      indicatorColor: p.primary,
      dividerColor: p.border,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      hintStyle: TextStyle(color: p.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r),
        borderSide: side,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r),
        borderSide: side,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.primary,
      linearTrackColor: p.primarySoft,
    ),
    dividerTheme: DividerThemeData(color: p.border),
    dialogTheme: DialogThemeData(backgroundColor: p.surface),
    popupMenuTheme: PopupMenuThemeData(color: p.surfaceHigh),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.surface),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.surfaceHigh,
      contentTextStyle: TextStyle(color: p.text),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: p.surface,
        foregroundColor: p.muted,
        selectedBackgroundColor: p.primary,
        selectedForegroundColor: p.onPrimary,
        side: side,
      ).copyWith(foregroundBuilder: _normalText),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.primary : p.surfaceHigh,
      ),
    ),
  );
}

/// Chữ trên nút giữ cỡ thường, kể cả khi nút nằm trong vùng nội dung bài học
/// đã phóng to.
Widget _normalText(
  BuildContext context,
  Set<WidgetState> states,
  Widget? child,
) => NormalTextScale(child: child ?? const SizedBox.shrink());
