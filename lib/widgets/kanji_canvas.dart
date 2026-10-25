import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Ô tập viết chữ Hán: chữ mẫu mờ ở giữa, kẻ chữ thập, viết bằng ngón tay.
/// Đổi [char] thì nét đã viết được xóa.
class KanjiCanvas extends StatefulWidget {
  final String char;
  final double maxWidth;

  const KanjiCanvas({super.key, required this.char, this.maxWidth = 320});

  @override
  State<KanjiCanvas> createState() => _KanjiCanvasState();
}

class _KanjiCanvasState extends State<KanjiCanvas> {
  final _strokes = <List<Offset>>[];

  @override
  void didUpdateWidget(KanjiCanvas old) {
    super.didUpdateWidget(old);
    if (old.char != widget.char) _strokes.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, box) => RawGestureDetector(
                      gestures: {
                        _InkPanRecognizer:
                            GestureRecognizerFactoryWithHandlers<
                              _InkPanRecognizer
                            >(_InkPanRecognizer.new, (r) {
                              r.dragStartBehavior = DragStartBehavior.down;
                              r.onStart = (d) {
                                setState(() => _strokes.add([d.localPosition]));
                              };
                              r.onUpdate = (d) {
                                setState(
                                  () => _strokes.last.add(d.localPosition),
                                );
                              };
                            }),
                      },
                      child: CustomPaint(
                        key: const ValueKey('kanji-canvas'),
                        painter: _CanvasPainter(
                          _strokes,
                          AppColors.primary,
                          AppColors.border,
                        ),
                        child: Center(
                          child: Text(
                            widget.char,
                            style: TextStyle(
                              fontSize: box.maxWidth * 0.72,
                              color: AppColors.text.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: IconButton(
                    key: const ValueKey('canvas-clear'),
                    tooltip: 'Xóa nét',
                    onPressed: () => setState(_strokes.clear),
                    icon: Icon(Icons.refresh_rounded, color: AppColors.muted),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 12,
                  child: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nhận nét vẽ ngay khi chạm, không nhường cho trang cuộn phía ngoài.
/// Nếu dùng GestureDetector thường, nét kéo dọc bị trang cuộn giành mất.
class _InkPanRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class _CanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color ink;
  final Color guide;

  _CanvasPainter(this.strokes, this.ink, this.guide);

  @override
  void paint(Canvas canvas, Size size) {
    final g = Paint()
      ..color = guide
      ..strokeWidth = 1;
    // Đường kẻ chữ thập giúp căn chữ, giống vở tập viết.
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      g,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      g,
    );
    final p = Paint()
      ..color = ink
      ..strokeWidth = size.width / 28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(
          s.first,
          p.strokeWidth / 2,
          p..style = PaintingStyle.fill,
        );
        p.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (final o in s.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_CanvasPainter old) => true;
}
