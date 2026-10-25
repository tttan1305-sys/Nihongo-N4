import 'package:flutter/material.dart';

/// Ba phong cách giao diện người dùng chọn trong Cài đặt.
enum AppSkin { neon, mechanical, anime }

/// Bảng màu của một phong cách ở một chế độ Sáng/Tối.
class SkinPalette {
  final AppSkin skin;
  final Brightness brightness;
  final Color primary, primaryDark, primarySoft, onPrimary, primaryText;
  final Color purple, purpleSoft, green, greenSoft, pink, pinkSoft;
  final Color orange, orangeSoft, red, redSoft;
  final Color background, surface, surfaceHigh, text, muted, border;
  final Color pattern, shadow, rivet;
  final Color screen, screenInk, screenDim;
  final Color navBackground, navForeground, navMuted;
  final Color mascot, face, blush;
  final List<Color> cycle, tints;

  const SkinPalette({
    required this.skin,
    required this.brightness,
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.onPrimary,
    required this.primaryText,
    required this.purple,
    required this.purpleSoft,
    required this.green,
    required this.greenSoft,
    required this.pink,
    required this.pinkSoft,
    required this.orange,
    required this.orangeSoft,
    required this.red,
    required this.redSoft,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.text,
    required this.muted,
    required this.border,
    required this.pattern,
    required this.shadow,
    required this.rivet,
    required this.screen,
    required this.screenInk,
    required this.screenDim,
    required this.navBackground,
    required this.navForeground,
    required this.navMuted,
    required this.mascot,
    required this.face,
    required this.blush,
    required this.cycle,
    required this.tints,
  });

  bool get isDark => brightness == Brightness.dark;

  /// Bảng màu đang dùng; main.dart gán lại mỗi khi người dùng đổi.
  static SkinPalette current = neon;

  static SkinPalette of(AppSkin skin, Brightness b) => switch (skin) {
    AppSkin.neon => neon,
    AppSkin.mechanical =>
      b == Brightness.dark ? mechanicalDark : mechanicalLight,
    AppSkin.anime => b == Brightness.dark ? animeDark : animeLight,
  };

  /// Giao diện tối neon hiện có (giữ nguyên màu của theme.dart cũ).
  static const neon = SkinPalette(
    skin: AppSkin.neon,
    brightness: Brightness.dark,
    primary: Color(0xFF4D8DFF),
    primaryDark: Color(0xFF2A5BE0),
    primarySoft: Color(0xFF1A2E66),
    onPrimary: Color(0xFFFFFFFF),
    primaryText: Color(0xFF4D8DFF),
    purple: Color(0xFFA67CFF),
    purpleSoft: Color(0xFF2A1F55),
    green: Color(0xFF2FD39A),
    greenSoft: Color(0xFF0F3B39),
    pink: Color(0xFFFF6FA5),
    pinkSoft: Color(0xFF3F1B44),
    orange: Color(0xFFFFA94D),
    orangeSoft: Color(0xFF3A2A2A),
    red: Color(0xFFFF5F6D),
    redSoft: Color(0xFF431D33),
    background: Color(0xFF0B1430),
    surface: Color(0xFF14224A),
    surfaceHigh: Color(0xFF1B2C5C),
    text: Color(0xFFF2F5FF),
    muted: Color(0xFF8C9BC4),
    border: Color(0xFF2A3B6E),
    pattern: Color(0x00000000),
    shadow: Color(0xFF4D8DFF),
    rivet: Color(0x00000000),
    screen: Color(0xFF0E1A3C),
    screenInk: Color(0xFFF2F5FF),
    screenDim: Color(0xFF8C9BC4),
    navBackground: Color(0xFF0E1A3C),
    navForeground: Color(0xFF4D8DFF),
    navMuted: Color(0xFF8C9BC4),
    mascot: Color(0xFFFFFFFF),
    face: Color(0xFF0B1430),
    blush: Color(0xFFFF6FA5),
    cycle: [
      Color(0xFF4D8DFF),
      Color(0xFFFF6FA5),
      Color(0xFF2FD39A),
      Color(0xFFFFA94D),
      Color(0xFFA67CFF),
    ],
    tints: [
      Color(0xFF1A2E66),
      Color(0xFF3F1B44),
      Color(0xFF0F3B39),
      Color(0xFF3A2A2A),
      Color(0xFF2A1F55),
      Color(0xFF1B2C5C),
    ],
  );

  static const mechanicalLight = SkinPalette(
    skin: AppSkin.mechanical,
    brightness: Brightness.light,
    primary: Color(0xFFF26A1B),
    primaryDark: Color(0xFFA84408),
    primarySoft: Color(0xFFCDD2D8),
    onPrimary: Color(0xFF14171A),
    primaryText: Color(0xFFA84408),
    purple: Color(0xFF3D5A80),
    purpleSoft: Color(0xFFDCE3EC),
    green: Color(0xFF1C7A45),
    greenSoft: Color(0xFFDCEFE3),
    pink: Color(0xFFB8336F),
    pinkSoft: Color(0xFFF3DCE6),
    orange: Color(0xFFA85C00),
    orangeSoft: Color(0xFFF7E6CC),
    red: Color(0xFFB3261E),
    redSoft: Color(0xFFF6DEDB),
    background: Color(0xFFDCDFE3),
    surface: Color(0xFFF2F3F5),
    surfaceHigh: Color(0xFFE7E9EC),
    text: Color(0xFF14171A),
    muted: Color(0xFF4C5560),
    border: Color(0xFFB5BBC2),
    pattern: Color(0x0F14171A),
    shadow: Color(0x00000000),
    rivet: Color(0xFF9AA2AB),
    screen: Color(0xFF1A1F24),
    screenInk: Color(0xFFFFB27A),
    screenDim: Color(0xFF9A7A62),
    navBackground: Color(0xFF14171A),
    navForeground: Color(0xFFF26A1B),
    navMuted: Color(0xFF8E98A2),
    mascot: Color(0xFFFFFFFF),
    face: Color(0xFF14171A),
    blush: Color(0xFFF26A1B),
    cycle: [
      Color(0xFFA84408),
      Color(0xFF3D5A80),
      Color(0xFF1C7A45),
      Color(0xFFA85C00),
      Color(0xFFB8336F),
    ],
    tints: [
      Color(0xFFE7E9EC),
      Color(0xFFE7E9EC),
      Color(0xFFE7E9EC),
      Color(0xFFE7E9EC),
      Color(0xFFE7E9EC),
      Color(0xFFE7E9EC),
    ],
  );

  static const mechanicalDark = SkinPalette(
    skin: AppSkin.mechanical,
    brightness: Brightness.dark,
    primary: Color(0xFFFF7A2E),
    primaryDark: Color(0xFFD95F18),
    primarySoft: Color(0xFF262D35),
    onPrimary: Color(0xFF0B0E11),
    primaryText: Color(0xFFFF8D4D),
    purple: Color(0xFF8FB3D9),
    purpleSoft: Color(0xFF1B2633),
    green: Color(0xFF3DDC84),
    greenSoft: Color(0xFF12291D),
    pink: Color(0xFFFF74B3),
    pinkSoft: Color(0xFF331A28),
    orange: Color(0xFFFFB547),
    orangeSoft: Color(0xFF2E2412),
    red: Color(0xFFFF6B5E),
    redSoft: Color(0xFF2E1614),
    background: Color(0xFF0B0E11),
    surface: Color(0xFF151A1F),
    surfaceHigh: Color(0xFF1C2229),
    text: Color(0xFFE3E7EA),
    muted: Color(0xFF8E99A4),
    border: Color(0xFF2C343D),
    pattern: Color(0x0AFFFFFF),
    shadow: Color(0x00000000),
    rivet: Color(0xFF3A434D),
    screen: Color(0xFF050709),
    screenInk: Color(0xFFFFB27A),
    screenDim: Color(0xFF9A7A62),
    navBackground: Color(0xFF151A1F),
    navForeground: Color(0xFFFF7A2E),
    navMuted: Color(0xFF7F8A95),
    mascot: Color(0xFFE3E7EA),
    face: Color(0xFF0B0E11),
    blush: Color(0xFFFF7A2E),
    cycle: [
      Color(0xFFFF8D4D),
      Color(0xFF8FB3D9),
      Color(0xFF3DDC84),
      Color(0xFFFFB547),
      Color(0xFFFF74B3),
    ],
    tints: [
      Color(0xFF1C2229),
      Color(0xFF1C2229),
      Color(0xFF1C2229),
      Color(0xFF1C2229),
      Color(0xFF1C2229),
      Color(0xFF1C2229),
    ],
  );

  static const animeLight = SkinPalette(
    skin: AppSkin.anime,
    brightness: Brightness.light,
    primary: Color(0xFFD12F68),
    primaryDark: Color(0xFFA8204F),
    primarySoft: Color(0xFFFFE0EA),
    onPrimary: Color(0xFFFFFFFF),
    primaryText: Color(0xFFC2255C),
    purple: Color(0xFF2F66D0),
    purpleSoft: Color(0xFFE1ECFF),
    green: Color(0xFF126B4F),
    greenSoft: Color(0xFFDDF6EC),
    pink: Color(0xFFC2255C),
    pinkSoft: Color(0xFFFFE4EC),
    orange: Color(0xFFA85C00),
    orangeSoft: Color(0xFFFFF1C7),
    red: Color(0xFFC6303A),
    redSoft: Color(0xFFFFE0DE),
    background: Color(0xFFFFF3F6),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFFFE4EC),
    text: Color(0xFF2A1F3D),
    muted: Color(0xFF6A5E7E),
    border: Color(0xFF2A1F3D),
    pattern: Color(0x1AD12F68),
    shadow: Color(0xFF2A1F3D),
    rivet: Color(0x00000000),
    screen: Color(0xFFE1ECFF),
    screenInk: Color(0xFF2A1F3D),
    screenDim: Color(0xFF6A5E7E),
    navBackground: Color(0xFF2A1F3D),
    navForeground: Color(0xFFFFFFFF),
    navMuted: Color(0xFFC9BFDB),
    mascot: Color(0xFFFFFFFF),
    face: Color(0xFF2A1F3D),
    blush: Color(0xFFFF8FB5),
    cycle: [
      Color(0xFFC2255C),
      Color(0xFF2F66D0),
      Color(0xFF126B4F),
      Color(0xFFA85C00),
      Color(0xFF6E45D6),
    ],
    tints: [
      Color(0xFFFFE0EA),
      Color(0xFFE1ECFF),
      Color(0xFFFFF1C7),
      Color(0xFFDDF6EC),
      Color(0xFFEDE3FF),
      Color(0xFFFFE6D6),
    ],
  );

  static const animeDark = SkinPalette(
    skin: AppSkin.anime,
    brightness: Brightness.dark,
    primary: Color(0xFFFF7EAA),
    primaryDark: Color(0xFFE25A8C),
    primarySoft: Color(0xFF3A2347),
    onPrimary: Color(0xFF1B1430),
    primaryText: Color(0xFFFF93B8),
    purple: Color(0xFF8DB6FF),
    purpleSoft: Color(0xFF25305A),
    green: Color(0xFF5FE0B0),
    greenSoft: Color(0xFF1D3B3A),
    pink: Color(0xFFFF93B8),
    pinkSoft: Color(0xFF2E2452),
    orange: Color(0xFFFFD25E),
    orangeSoft: Color(0xFF3B3420),
    red: Color(0xFFFF7A7A),
    redSoft: Color(0xFF3D2230),
    background: Color(0xFF141027),
    surface: Color(0xFF211B3B),
    surfaceHigh: Color(0xFF2E2452),
    text: Color(0xFFF4EEFF),
    muted: Color(0xFFB6AAD8),
    border: Color(0xFF6D5FA8),
    pattern: Color(0x1AFF7EAA),
    shadow: Color(0xFFFF7EAA),
    rivet: Color(0x00000000),
    screen: Color(0xFF25305A),
    screenInk: Color(0xFFF4EEFF),
    screenDim: Color(0xFFB6AAD8),
    navBackground: Color(0xFFF4EEFF),
    navForeground: Color(0xFF1B1430),
    navMuted: Color(0xFF5A4F78),
    mascot: Color(0xFFF4EEFF),
    face: Color(0xFF1B1430),
    blush: Color(0xFFFF7EAA),
    cycle: [
      Color(0xFFFF93B8),
      Color(0xFF8DB6FF),
      Color(0xFF5FE0B0),
      Color(0xFFFFD25E),
      Color(0xFFB49BFF),
    ],
    tints: [
      Color(0xFF3A2347),
      Color(0xFF25305A),
      Color(0xFF3B3420),
      Color(0xFF1D3B3A),
      Color(0xFF2F2756),
      Color(0xFF3D2A26),
    ],
  );
}

/// Trang trí thẻ theo phong cách đang chọn.
BoxDecoration skinCardDecoration({Color? color, Color? borderColor}) {
  final p = SkinPalette.current;
  final c = color ?? p.surface;
  switch (p.skin) {
    case AppSkin.mechanical:
      return BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor ?? p.border),
      );
    case AppSkin.anime:
      return BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor ?? p.border, width: 2.5),
        boxShadow: [BoxShadow(color: p.shadow, offset: const Offset(4, 4))],
      );
    case AppSkin.neon:
      final glow = borderColor ?? p.primary;
      return BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: glow.withValues(alpha: borderColor == null ? 0.28 : 0.7),
        ),
        boxShadow: [
          BoxShadow(color: glow.withValues(alpha: 0.16), blurRadius: 18),
        ],
      );
  }
}

double skinCardRadius() => switch (SkinPalette.current.skin) {
  AppSkin.mechanical => 4,
  AppSkin.anime => 22,
  AppSkin.neon => 18,
};

/// Nền có họa tiết: lưới 20 px (Mechanical) hoặc chấm bi 16 px (Anime).
class SkinBackground extends StatelessWidget {
  final Widget child;
  const SkinBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = SkinPalette.current;
    if (p.skin == AppSkin.neon) return child;
    return CustomPaint(painter: _PatternPainter(p), child: child);
  }
}

class _PatternPainter extends CustomPainter {
  final SkinPalette p;
  _PatternPainter(this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = p.pattern;
    if (p.skin == AppSkin.mechanical) {
      paint.strokeWidth = 1;
      for (double x = 0; x <= size.width; x += 20) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
      for (double y = 0; y <= size.height; y += 20) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    } else {
      for (double y = 8; y < size.height; y += 16) {
        for (double x = 8; x < size.width; x += 16) {
          canvas.drawCircle(Offset(x, y), 1.6, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.p != p;
}

/// Dải sọc cảnh báo 45° (Mechanical): đầu thẻ Tiếp tục, đầu trang.
class HazardStripe extends StatelessWidget {
  final double height;
  const HazardStripe({super.key, this.height = 6});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(painter: _HazardPainter(SkinPalette.current.primary)),
  );
}

class _HazardPainter extends CustomPainter {
  final Color color;
  _HazardPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF14171A),
    );
    final paint = Paint()..color = color;
    const w = 8.0;
    final h = size.height;
    for (double x = -h; x < size.width + h; x += w * 2) {
      final path = Path()
        ..moveTo(x, h)
        ..lineTo(x + w, h)
        ..lineTo(x + w + h, 0)
        ..lineTo(x + h, 0)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_HazardPainter old) => old.color != color;
}

/// Bốn đinh tán ở góc thẻ (Mechanical). Đặt trong Stack, trên nội dung.
class Rivets extends StatelessWidget {
  const Rivets({super.key});

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: CustomPaint(painter: _RivetPainter(SkinPalette.current.rivet)),
    ),
  );
}

class _RivetPainter extends CustomPainter {
  final Color color;
  _RivetPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const d = 8.5;
    for (final o in [
      const Offset(d, d),
      Offset(size.width - d, d),
      Offset(d, size.height - d),
      Offset(size.width - d, size.height - d),
    ]) {
      canvas.drawCircle(o, 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(_RivetPainter old) => old.color != color;
}

/// Thanh tiến độ chia vạch rời (Mechanical).
class SegmentedProgress extends StatelessWidget {
  final double value;
  final int segments;
  final double height;

  const SegmentedProgress({
    super.key,
    required this.value,
    this.segments = 10,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final p = SkinPalette.current;
    final filled = (value.clamp(0.0, 1.0) * segments).round();
    return Row(
      children: [
        for (var i = 0; i < segments; i++) ...[
          if (i > 0) SizedBox(width: segments > 20 ? 2 : 3),
          Expanded(
            child: Container(
              height: height,
              color: i < filled ? p.primary : p.primarySoft,
            ),
          ),
        ],
      ],
    );
  }
}

/// Linh vật Kumo (Anime): đám mây mặt cười, vẽ theo khung 80×64.
class KumoMascot extends StatelessWidget {
  final double width;
  final bool wink;
  const KumoMascot({super.key, this.width = 44, this.wink = false});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Linh vật Kumo',
    child: SizedBox(
      width: width,
      height: width * 0.8,
      child: CustomPaint(painter: _KumoPainter(SkinPalette.current, wink)),
    ),
  );
}

class _KumoPainter extends CustomPainter {
  final SkinPalette p;
  final bool wink;
  _KumoPainter(this.p, this.wink);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 80, size.height / 64);
    // Vẽ viền mực trước rồi phủ thân lên, chỉ còn đường viền ngoài.
    final outline = Paint()
      ..color = p.face
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final body = Paint()..color = p.mascot;
    for (final paint in [outline, body]) {
      canvas.drawCircle(const Offset(24, 38), 17, paint);
      canvas.drawCircle(const Offset(42, 27), 20, paint);
      canvas.drawCircle(const Offset(59, 39), 15, paint);
      canvas.drawRRect(
        RRect.fromLTRBR(14, 36, 70, 56, const Radius.circular(10)),
        paint,
      );
    }
    final face = Paint()..color = p.face;
    final line = Paint()
      ..color = p.face
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(34, 38), width: 6, height: 8),
      face,
    );
    if (wink) {
      canvas.drawPath(
        Path()
          ..moveTo(47, 38)
          ..quadraticBezierTo(50, 35, 53, 38),
        line,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(50, 38), width: 6, height: 8),
        face,
      );
    }
    final blush = Paint()..color = p.blush;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(27, 46), width: 9, height: 5),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(57, 46), width: 9, height: 5),
      blush,
    );
    canvas.drawPath(
      Path()
        ..moveTo(38, 45)
        ..quadraticBezierTo(42, 49, 46, 45),
      line,
    );
  }

  @override
  bool shouldRepaint(_KumoPainter old) => old.p != p || old.wink != wink;
}
