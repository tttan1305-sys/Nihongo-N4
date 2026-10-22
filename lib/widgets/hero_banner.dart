import 'dart:math';

import 'package:flutter/material.dart';

/// Tranh phong cảnh Nhật Bản ở đầu trang chủ: trời xanh, núi Phú Sĩ,
/// tháp chùa và cành hoa anh đào. Vẽ bằng code nên không cần file ảnh.
class HeroScenery extends StatelessWidget {
  final Widget child;
  final double height;

  const HeroScenery({super.key, required this.child, this.height = 250});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
        height: height,
        child: CustomPaint(painter: _SceneryPainter(), child: child),
      ),
    );
  }
}

class _SceneryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Trời.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9CC7FF), Color(0xFFD9EAFF), Color(0xFFF6FAFF)],
        ).createShader(Offset.zero & size),
    );

    // Mặt trời và mây.
    canvas.drawCircle(
      Offset(w * 0.80, h * 0.20),
      h * 0.09,
      Paint()..color = const Color(0xFFFFF1D6),
    );
    _cloud(canvas, Offset(w * 0.58, h * 0.18), h * 0.05);
    _cloud(canvas, Offset(w * 0.92, h * 0.34), h * 0.04);

    // Núi Phú Sĩ.
    final peak = Offset(w * 0.70, h * 0.32);
    final mountain = Path()
      ..moveTo(w * 0.36, h)
      ..quadraticBezierTo(w * 0.55, h * 0.55, peak.dx - w * 0.05, peak.dy)
      ..lineTo(peak.dx + w * 0.05, peak.dy)
      ..quadraticBezierTo(w * 0.86, h * 0.55, w * 1.06, h)
      ..close();
    canvas.drawPath(
      mountain,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5B86D6), Color(0xFF8FB3EE)],
        ).createShader(Rect.fromLTWH(0, peak.dy, w, h - peak.dy)),
    );
    // Tuyết trên đỉnh, mép dưới lượn sóng.
    final snow = Path()
      ..moveTo(peak.dx - w * 0.05, peak.dy)
      ..lineTo(peak.dx + w * 0.05, peak.dy)
      ..quadraticBezierTo(w * 0.775, h * 0.42, w * 0.79, h * 0.47)
      ..lineTo(w * 0.755, h * 0.44)
      ..lineTo(w * 0.73, h * 0.49)
      ..lineTo(w * 0.70, h * 0.45)
      ..lineTo(w * 0.67, h * 0.49)
      ..lineTo(w * 0.645, h * 0.44)
      ..lineTo(w * 0.61, h * 0.47)
      ..quadraticBezierTo(w * 0.625, h * 0.42, peak.dx - w * 0.05, peak.dy)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white);

    // Đồi phía trước.
    final hill = Path()
      ..moveTo(0, h * 0.86)
      ..quadraticBezierTo(w * 0.35, h * 0.74, w * 0.7, h * 0.86)
      ..quadraticBezierTo(w * 0.88, h * 0.92, w, h * 0.84)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFFBFE3C8));

    _pagoda(canvas, Offset(w * 0.92, h * 0.88), h * 0.42);
    _sakuraBranch(canvas, size);
  }

  void _cloud(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(c, r, paint);
    canvas.drawCircle(c.translate(r * 1.1, r * 0.25), r * 0.8, paint);
    canvas.drawCircle(c.translate(-r * 1.1, r * 0.3), r * 0.7, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - r * 1.7, c.dy, r * 3.5, r * 0.9),
        Radius.circular(r),
      ),
      paint,
    );
  }

  /// Tháp chùa năm tầng màu đỏ, [base] là chân tháp, [height] là chiều cao.
  void _pagoda(Canvas canvas, Offset base, double height) {
    final body = Paint()..color = const Color(0xFFD9434F);
    final roof = Paint()..color = const Color(0xFF3A3F58);
    const floors = 5;
    final floorH = height / (floors + 1);
    for (var i = 0; i < floors; i++) {
      final y = base.dy - floorH * (i + 1);
      final half = height * (0.20 - i * 0.025);
      canvas.drawRect(
        Rect.fromLTWH(base.dx - half * 0.55, y, half * 1.1, floorH),
        body,
      );
      final r = Path()
        ..moveTo(base.dx - half * 1.25, y + floorH * 0.15)
        ..quadraticBezierTo(
          base.dx,
          y - floorH * 0.55,
          base.dx + half * 1.25,
          y + floorH * 0.15,
        )
        ..lineTo(base.dx + half * 0.9, y + floorH * 0.05)
        ..lineTo(base.dx - half * 0.9, y + floorH * 0.05)
        ..close();
      canvas.drawPath(r, roof);
    }
    final top = base.dy - floorH * floors;
    canvas.drawLine(
      Offset(base.dx, top),
      Offset(base.dx, top - floorH * 1.2),
      Paint()
        ..color = const Color(0xFF3A3F58)
        ..strokeWidth = 2,
    );
  }

  void _sakuraBranch(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final branch = Paint()
      ..color = const Color(0xFF6B4A3A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(w * 1.02, h * 0.02)
      ..quadraticBezierTo(w * 0.9, h * 0.12, w * 0.74, h * 0.06)
      ..moveTo(w * 0.9, h * 0.09)
      ..quadraticBezierTo(w * 0.88, h * 0.18, w * 0.94, h * 0.22);
    canvas.drawPath(path, branch);
    final rnd = Random(7);
    for (final p in [
      Offset(w * 0.76, h * 0.07),
      Offset(w * 0.81, h * 0.04),
      Offset(w * 0.85, h * 0.10),
      Offset(w * 0.92, h * 0.21),
      Offset(w * 0.96, h * 0.06),
      Offset(w * 0.88, h * 0.15),
    ]) {
      _blossom(canvas, p, 6 + rnd.nextDouble() * 3);
    }
    // Vài cánh hoa rơi.
    final petal = Paint()..color = const Color(0xFFFFB7CB);
    for (final p in [
      Offset(w * 0.55, h * 0.30),
      Offset(w * 0.62, h * 0.52),
      Offset(w * 0.47, h * 0.62),
    ]) {
      canvas.drawOval(Rect.fromCenter(center: p, width: 6, height: 4), petal);
    }
  }

  void _blossom(Canvas canvas, Offset c, double r) {
    final petal = Paint()..color = const Color(0xFFFFB7CB);
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * pi / 5 - pi / 2;
      canvas.drawCircle(c + Offset(cos(a), sin(a)) * r * 0.55, r * 0.5, petal);
    }
    canvas.drawCircle(c, r * 0.25, Paint()..color = const Color(0xFFFF6F91));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
