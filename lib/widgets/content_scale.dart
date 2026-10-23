import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cỡ chữ của nội dung bài học (chữ Nhật, ví dụ, nghĩa, giải thích), đặt
/// trong Cài đặt. Menu, thanh tiêu đề và nút giữ cỡ chữ thường.
class ContentScaleScope extends InheritedWidget {
  final double scale;

  const ContentScaleScope({
    super.key,
    required this.scale,
    required super.child,
  });

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ContentScaleScope>()?.scale ??
      1;

  @override
  bool updateShouldNotify(ContentScaleScope old) => old.scale != scale;
}

/// Phóng chữ trong [child] theo cỡ chữ nội dung, nhân với cỡ chữ của máy.
class ContentScale extends StatelessWidget {
  final Widget child;

  const ContentScale({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scale = ContentScaleScope.of(context);
    final mq = MediaQuery.of(context);
    if (scale == 1) return child;
    return MediaQuery(
      data: mq.copyWith(textScaler: _ContentScaler(mq.textScaler, scale)),
      child: _ButtonTextScale(base: mq.textScaler, child: child),
    );
  }
}

/// Nút nằm trong vùng nội dung vẫn giữ cỡ chữ thường.
class _ButtonTextScale extends InheritedWidget {
  final TextScaler base;

  const _ButtonTextScale({required this.base, required super.child});

  @override
  bool updateShouldNotify(_ButtonTextScale old) => old.base != base;
}

/// Bọc nút (hoặc hàng nút) trong vùng [ContentScale] để giữ cỡ chữ thường.
class NormalTextScale extends StatelessWidget {
  final Widget child;

  const NormalTextScale({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final base = context
        .dependOnInheritedWidgetOfExactType<_ButtonTextScale>()
        ?.base;
    if (base == null) return child;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: base),
      child: child,
    );
  }
}

/// Phóng chữ thường lên [factor] lần nhưng không vượt quá [cap]; chữ vốn đã
/// to (chữ Hán cỡ lớn, ô tập viết) giữ nguyên cỡ để không tràn khung.
class _ContentScaler extends TextScaler {
  static const cap = 36.0;

  final TextScaler base;
  final double factor;

  const _ContentScaler(this.base, this.factor);

  @override
  double scale(double fontSize) {
    final size = base.scale(fontSize);
    return math.max(size, math.min(size * factor, cap));
  }

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _ContentScaler && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
