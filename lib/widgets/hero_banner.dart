import 'dart:math';

import 'package:flutter/material.dart';

/// Tranh phong cảnh Nhật Bản ban đêm ở đầu trang chủ: trời tím có sao, trăng,
/// núi Phú Sĩ, tháp chùa và cành hoa anh đào. Vẽ bằng code nên không cần file ảnh.
class HeroScenery extends StatelessWidget {
  final Widget child;
  final double height;

  const HeroScenery({super.key, required this.child, this.height = 270});

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

    // Trời đêm tím, dưới cùng hòa vào màu nền ứng dụng.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B1550),
            Color(0xFF3A2A86),
            Color(0xFF5B3A9E),
            Color(0xFF0B1430),
          ],
          stops: [0, 0.4, 0.68, 1],
        ).createShader(Offset.zero & size),
    );

    // Sao.
    final rnd = Random(3);
    final star = Paint()..color = Colors.white;
    for (var i = 0; i < 46; i++) {
      final o = Offset(rnd.nextDouble() * w, rnd.nextDouble() * h * 0.55);
      star.color = Colors.white.withValues(
        alpha: 0.35 + rnd.nextDouble() * 0.6,
      );
      canvas.drawCircle(o, 0.6 + rnd.nextDouble() * 1.1, star);
    }

    // Trăng có quầng sáng.
    final moon = Offset(w * 0.56, h * 0.24);
    canvas.drawCircle(
      moon,
      h * 0.17,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE9B8).withValues(alpha: 0.45),
            const Color(0xFFFFE9B8).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: moon, radius: h * 0.17)),
    );
    canvas.drawCircle(
      moon,
      h * 0.075,
      Paint()..color = const Color(0xFFFFF3D1),
    );

    // Núi Phú Sĩ.
    final peak = Offset(w * 0.66, h * 0.40);
    final mountain = Path()
      ..moveTo(w * 0.24, h)
      ..quadraticBezierTo(w * 0.48, h * 0.62, peak.dx - w * 0.05, peak.dy)
      ..lineTo(peak.dx + w * 0.05, peak.dy)
      ..quadraticBezierTo(w * 0.84, h * 0.62, w * 1.08, h)
      ..close();
    canvas.drawPath(
      mountain,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3D4C9C), Color(0xFF1A2560)],
        ).createShader(Rect.fromLTWH(0, peak.dy, w, h - peak.dy)),
    );
    // Tuyết trên đỉnh, mép dưới lượn sóng.
    final snow = Path()
      ..moveTo(peak.dx - w * 0.05, peak.dy)
      ..lineTo(peak.dx + w * 0.05, peak.dy)
      ..quadraticBezierTo(w * 0.735, h * 0.49, w * 0.75, h * 0.54)
      ..lineTo(w * 0.715, h * 0.51)
      ..lineTo(w * 0.69, h * 0.555)
      ..lineTo(w * 0.66, h * 0.515)
      ..lineTo(w * 0.63, h * 0.555)
      ..lineTo(w * 0.605, h * 0.51)
      ..lineTo(w * 0.57, h * 0.54)
      ..quadraticBezierTo(w * 0.585, h * 0.49, peak.dx - w * 0.05, peak.dy)
      ..close();
    canvas.drawPath(snow, Paint()..color = const Color(0xFFDDE4FF));

    // Đồi tối phía trước.
    final hill = Path()
      ..moveTo(0, h * 0.88)
      ..quadraticBezierTo(w * 0.35, h * 0.78, w * 0.7, h * 0.9)
      ..quadraticBezierTo(w * 0.88, h * 0.95, w, h * 0.86)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF0E1838));

    _pagoda(canvas, Offset(w * 0.93, h * 0.9), h * 0.42);
    _sakuraBranch(canvas, size);
  }

  void _pagoda(Canvas canvas, Offset base, double height) {
    final body = Paint()..color = const Color(0xFF8E2E52);
    final roof = Paint()..color = const Color(0xFF151B3D);
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
        ..color = const Color(0xFF151B3D)
        ..strokeWidth = 2,
    );
  }

  void _sakuraBranch(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final branch = Paint()
      ..color = const Color(0xFF3B2340)
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
