import 'package:flutter/material.dart';

import '../theme.dart';

/// Thẻ trắng bo tròn có bóng nhẹ, dùng khắp ứng dụng.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.color = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1B2440),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Thanh tiến độ bo tròn.
class RoundedProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const RoundedProgress({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        color: color,
        backgroundColor: color.withValues(alpha: 0.15),
      ),
    );
  }
}

/// Dòng "12/20" kèm thanh tiến độ ở đầu màn hình học/luyện tập.
class StepProgress extends StatelessWidget {
  final int current;
  final int total;
  final Widget? trailing;

  const StepProgress({
    super.key,
    required this.current,
    required this.total,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$current/$total',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RoundedProgress(value: total == 0 ? 0 : current / total),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

/// Vòng tròn màu có số thứ tự.
class NumberBadge extends StatelessWidget {
  final int number;
  final double size;

  const NumberBadge(this.number, {super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.cycle[(number - 1) % AppColors.cycle.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

/// Nhãn nhỏ bo tròn có màu.
class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final Color? background;

  const Pill(
    this.text, {
    super.key,
    this.color = AppColors.primary,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Biểu tượng trong ô vuông bo tròn có nền nhạt.
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconTile(this.icon, {super.key, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.55),
    );
  }
}

/// Tiêu đề một mục trong màn hình chi tiết (Cách dùng, Ví dụ...).
class SectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;

  const SectionLabel(
    this.text, {
    super.key,
    this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút tròn dùng cho mũi tên trước/sau.
class CircleNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const CircleNavButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      iconSize: 22,
      style: IconButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        backgroundColor: Colors.white,
        fixedSize: const Size(52, 52),
      ),
      icon: Icon(icon, color: AppColors.primary),
    );
  }
}
