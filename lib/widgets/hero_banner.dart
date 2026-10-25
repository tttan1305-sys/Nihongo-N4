import 'package:flutter/material.dart';

import '../theme.dart';

/// Ảnh nền chào mừng ở đầu trang chủ: núi Phú Sĩ, tháp chùa và hoa anh đào.
/// Phủ lớp tối phía trên để chữ trắng dễ đọc, mép dưới hòa vào màu nền.
class HeroScenery extends StatelessWidget {
  static const image = 'assets/images/hero.jpg';

  final Widget child;
  final double height;

  const HeroScenery({super.key, required this.child, this.height = 270});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            image,
            key: const ValueKey('hero-image'),
            fit: BoxFit.cover,
            alignment: const Alignment(0.25, 0),
            // Ảnh chưa tải xong (hoặc lỗi) thì hiện màu nền thay vì ô trống.
            errorBuilder: (_, _, _) => ColoredBox(color: AppColors.surface),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x99081030), Color(0x00081030)],
                stops: [0.1, 0.65],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), AppColors.background],
                stops: [0.62, 1],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
