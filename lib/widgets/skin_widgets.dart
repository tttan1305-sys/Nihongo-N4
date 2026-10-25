import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../theme.dart';

/// Phông nhãn nhỏ: chữ mono in hoa (Mechanical) hoặc Nunito đậm (Anime).
TextStyle skinLabelStyle({Color? color, double size = 11}) {
  final p = SkinPalette.current;
  if (p.skin == AppSkin.mechanical) {
    return TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: size,
      letterSpacing: size * 0.12,
      color: color ?? p.muted,
      fontWeight: FontWeight.w600,
    );
  }
  return TextStyle(
    fontSize: size + 1,
    fontWeight: FontWeight.w800,
    color: color ?? p.muted,
  );
}

/// Lời chào theo giờ trong ngày.
String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 11) return 'Chào buổi sáng';
  if (h < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}

/// Công tắc Sáng/Tối nhanh ở đầu Trang chủ (Mechanical, Anime).
class SkinModeToggle extends StatelessWidget {
  final ProgressStore progress;

  const SkinModeToggle({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final p = SkinPalette.current;
    final dark = p.isDark;
    final anime = p.skin == AppSkin.anime;
    final width = anime ? 84.0 : 96.0;
    final knob = anime ? 34.0 : 44.0;
    final icon = Icon(
      dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      size: 18,
      color: anime ? const Color(0xFF2A1F3D) : p.onPrimary,
    );
    return Semantics(
      button: true,
      label: dark ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
      child: GestureDetector(
        key: const ValueKey('mode-toggle'),
        onTap: () => progress.setBrightness(dark ? 'light' : 'dark'),
        child: Container(
          width: width,
          height: 44,
          decoration: BoxDecoration(
            color: p.surfaceHigh,
            borderRadius: BorderRadius.circular(anime ? 22 : 4),
            border: Border.all(color: p.border, width: anime ? 2 : 1),
          ),
          child: Stack(
            children: [
              if (!anime)
                Row(
                  children: [
                    for (final t in ['SÁNG', 'TỐI'])
                      Expanded(
                        child: Center(
                          child: Text(t, style: skinLabelStyle(size: 9.5)),
                        ),
                      ),
                  ],
                )
              else
                Align(
                  alignment: dark
                      ? const Alignment(-0.55, 0)
                      : const Alignment(0.55, 0),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: p.muted,
                  ),
                ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: dark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: knob,
                  height: anime ? knob : 36,
                  decoration: BoxDecoration(
                    color: anime
                        ? (dark
                              ? const Color(0xFF8DB6FF)
                              : const Color(0xFFFFC93C))
                        : p.primary,
                    shape: anime ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: anime ? null : BorderRadius.circular(3),
                    border: anime
                        ? Border.all(color: const Color(0xFF2A1F3D), width: 2)
                        : null,
                  ),
                  child: icon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút biểu tượng vuông (Mechanical) hoặc tròn viền mực (Anime) ở đầu trang.
class SkinIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const SkinIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final p = SkinPalette.current;
    final anime = p.skin == AppSkin.anime;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        backgroundColor: p.surface,
        side: BorderSide(color: p.border, width: anime ? 2 : 1),
        shape: anime
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      icon: Icon(icon, color: p.text, size: 20),
    );
  }
}

/// Đồng hồ đo tròn của bảng điều khiển (Mechanical).
class GaugeDial extends StatelessWidget {
  final double value;
  final String label;
  final double size;

  const GaugeDial({
    super.key,
    required this.value,
    required this.label,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final p = SkinPalette.current;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(p, value.clamp(0.0, 1.0)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  text: '${(value * 100).round()}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  children: const [
                    TextSpan(text: '%', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: skinLabelStyle(size: 9.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final SkinPalette p;
  final double value;
  _GaugePainter(this.p, this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.width / 120;
    // Vạch chia quanh mép.
    final tick = Paint()
      ..color = p.border
      ..strokeWidth = 2.5 * s;
    for (var i = 0; i < 48; i++) {
      final a = i * 2 * math.pi / 48;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * 54 * s, c + d * 58 * s, tick);
    }
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 * s;
    final rect = Rect.fromCircle(center: c, radius: 44 * s);
    canvas.drawArc(rect, 0, 2 * math.pi, false, ring..color = p.primarySoft);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      ring..color = p.primary,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value || old.p != p;
}

/// Dòng số liệu "NHÃN / giá trị" có nét đứt phía dưới (Mechanical).
class GaugeStatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;
  final Color? color;

  const GaugeStatRow({
    super.key,
    required this.label,
    required this.value,
    this.last = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = SkinPalette.current;
    return Container(
      padding: EdgeInsets.only(bottom: last ? 0 : 8),
      margin: EdgeInsets.only(bottom: last ? 0 : 8),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: p.border)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: skinLabelStyle(size: 10)),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bong bóng thoại có đuôi bên trái (Anime).
class SpeechBubble extends StatelessWidget {
  final Widget child;
  final Color? color;

  const SpeechBubble({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    final p = SkinPalette.current;
    return CustomPaint(
      painter: _BubblePainter(p, color ?? p.surface),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 14, 16, 16),
        child: child,
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final SkinPalette p;
  final Color fill;
  _BubblePainter(this.p, this.fill);

  @override
  void paint(Canvas canvas, Size size) {
    const tail = 10.0;
    final body = RRect.fromLTRBR(
      tail,
      0,
      size.width - 4,
      size.height - 4,
      const Radius.circular(20),
    );
    final path = Path()
      ..addRRect(body)
      ..moveTo(tail + 1, 22)
      ..lineTo(0, 30)
      ..lineTo(tail + 1, 36)
      ..close();
    canvas.drawPath(path.shift(const Offset(4, 4)), Paint()..color = p.shadow);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = p.border,
    );
    // Viền đuôi, chừa chỗ nối vào thân.
    canvas.drawPath(
      Path()
        ..moveTo(tail + 1, 22)
        ..lineTo(0, 30)
        ..lineTo(tail + 1, 36),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = p.border,
    );
    canvas.drawLine(
      const Offset(tail + 1, 23.5),
      const Offset(tail + 1, 34.5),
      Paint()
        ..strokeWidth = 3
        ..color = fill,
    );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.fill != fill || old.p != p;
}

/// Thanh tiến độ viên thuốc viền mực, sọc chéo hai tông (Anime).
class StripedProgress extends StatelessWidget {
  final double value;
  final double height;

  const StripedProgress({super.key, required this.value, this.height = 16});

  @override
  Widget build(BuildContext context) {
    final p = SkinPalette.current;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(height),
        border: Border.all(color: p.border, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: CustomPaint(
              painter: _StripePainter(p.primary, p.primaryDark),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color a, b;
  _StripePainter(this.a, this.b);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = a);
    final paint = Paint()..color = b;
    final h = size.height;
    for (double x = -h; x < size.width + h; x += 16) {
      canvas.drawPath(
        Path()
          ..moveTo(x, h)
          ..lineTo(x + 6, h)
          ..lineTo(x + 6 + h, 0)
          ..lineTo(x + h, 0)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.a != a || old.b != b;
}

/// Ô vuông kẻ chữ thập nét đứt (田字格) có 4 góc ngắm (Mechanical), hoặc
/// vòng tia tốc độ kiểu manga (Anime), đặt chữ Kanji ở giữa.
class KanjiFrame extends StatelessWidget {
  final Widget child;
  final double size;

  const KanjiFrame({super.key, required this.child, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final p = SkinPalette.current;
    if (p.skin == AppSkin.neon) return child;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: p.skin == AppSkin.mechanical
            ? _GridFramePainter(p)
            : _SpeedLinesPainter(p),
        child: Center(child: child),
      ),
    );
  }
}

class _GridFramePainter extends CustomPainter {
  final SkinPalette p;
  _GridFramePainter(this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..color = p.surfaceHigh);
    canvas.drawRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = p.border,
    );
    final dash = Paint()
      ..color = p.border
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + 4, size.height / 2),
        dash,
      );
    }
    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + 4),
        dash,
      );
    }
    final corner = Paint()
      ..color = p.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const l = 14.0;
    final w = size.width, h = size.height;
    for (final c in [
      [Offset(0, l), Offset.zero, Offset(l, 0)],
      [Offset(w - l, 0), Offset(w, 0), Offset(w, l)],
      [Offset(0, h - l), Offset(0, h), Offset(l, h)],
      [Offset(w - l, h), Offset(w, h), Offset(w, h - l)],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(c[0].dx, c[0].dy)
          ..lineTo(c[1].dx, c[1].dy)
          ..lineTo(c[2].dx, c[2].dy),
        corner,
      );
    }
  }

  @override
  bool shouldRepaint(_GridFramePainter old) => old.p != p;
}

class _SpeedLinesPainter extends CustomPainter {
  final SkinPalette p;
  _SpeedLinesPainter(this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final paint = Paint()
      ..color = p.primary.withValues(alpha: 0.35)
      ..strokeCap = StrokeCap.round;
    final rng = math.Random(7);
    for (var i = 0; i < 40; i++) {
      final a = i * 2 * math.pi / 40 + rng.nextDouble() * 0.08;
      final d = Offset(math.cos(a), math.sin(a));
      paint.strokeWidth = 1.5 + rng.nextDouble() * 2;
      canvas.drawLine(
        c + d * r * (0.62 + rng.nextDouble() * 0.12),
        c + d * r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpeedLinesPainter old) => old.p != p;
}
