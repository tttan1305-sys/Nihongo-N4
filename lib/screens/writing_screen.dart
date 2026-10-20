import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/japanese_text.dart';
import '../widgets/ruby_text.dart';

/// Luyện viết: tập viết chữ Hán của bài trên chữ mẫu mờ, rồi gõ lại câu bằng hiragana.
class WritingScreen extends StatelessWidget {
  final List<KanjiItem> kanji;
  final List<TypingItem> typing;

  const WritingScreen({super.key, required this.kanji, required this.typing});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Luyện viết'),
          bottom: const TabBar(tabs: [Tab(text: 'Tập viết chữ Hán'), Tab(text: 'Gõ hiragana')]),
        ),
        body: TabBarView(children: [
          _KanjiPractice(kanji: kanji),
          _TypingPractice(items: typing),
        ]),
      ),
    );
  }
}

class _KanjiPractice extends StatefulWidget {
  final List<KanjiItem> kanji;

  const _KanjiPractice({required this.kanji});

  @override
  State<_KanjiPractice> createState() => _KanjiPracticeState();
}

class _KanjiPracticeState extends State<_KanjiPractice> {
  int _index = 0;
  final _strokes = <List<Offset>>[];

  void _go(int i) => setState(() {
        _index = i;
        _strokes.clear();
      });

  @override
  Widget build(BuildContext context) {
    final k = widget.kanji[_index];
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Chữ ${_index + 1}/${widget.kanji.length}: ${k.meaningVi}', style: Theme.of(context).textTheme.titleMedium),
        Text('Cách đọc: ${k.readings}'),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: colors.outline)),
            child: LayoutBuilder(
              builder: (context, box) => GestureDetector(
                onPanStart: (d) => setState(() => _strokes.add([d.localPosition])),
                onPanUpdate: (d) => setState(() => _strokes.last.add(d.localPosition)),
                child: CustomPaint(
                  key: const ValueKey('kanji-canvas'),
                  painter: _CanvasPainter(_strokes, colors.primary, colors.outlineVariant),
                  child: Center(
                    child: Text(
                      k.char,
                      style: TextStyle(fontSize: box.maxWidth * 0.75, color: colors.onSurface.withValues(alpha: 0.12)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(_strokes.clear),
              icon: const Icon(Icons.refresh),
              label: const Text('Xóa'),
            ),
            const Spacer(),
            if (_index > 0) TextButton(onPressed: () => _go(_index - 1), child: const Text('Chữ trước')),
            FilledButton(
              key: const ValueKey('next-kanji'),
              onPressed: _index + 1 < widget.kanji.length ? () => _go(_index + 1) : null,
              child: const Text('Chữ tiếp'),
            ),
          ],
        ),
      ],
    );
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
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), g);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), g);
    final p = Paint()
      ..color = ink
      ..strokeWidth = size.width / 28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(s.first, p.strokeWidth / 2, p..style = PaintingStyle.fill);
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

class _TypingPractice extends StatefulWidget {
  final List<TypingItem> items;

  const _TypingPractice({required this.items});

  @override
  State<_TypingPractice> createState() => _TypingPracticeState();
}

class _TypingPracticeState extends State<_TypingPractice> {
  int _index = 0;
  bool? _correct;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    setState(() => _correct = normalizeJa(_controller.text) == normalizeJa(widget.items[_index].answer));
  }

  void _next() => setState(() {
        _index++;
        _correct = null;
        _controller.clear();
      });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_index >= widget.items.length) {
      return const Center(child: Text('Bạn đã luyện gõ xong các câu của bài.'));
    }
    final item = widget.items[_index];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Câu ${_index + 1}/${widget.items.length}', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        // Ẩn furigana: người học phải tự nhớ cách đọc.
        RubyText(item.ja, showRuby: false, style: const TextStyle(fontSize: 24)),
        Text(item.vi, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('typing-input'),
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Gõ cách đọc bằng hiragana',
            helperText: 'Dùng bàn phím tiếng Nhật (kana) trên điện thoại',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _check(),
        ),
        const SizedBox(height: 12),
        if (_correct != null)
          Text(
            _correct! ? 'Chính xác!' : 'Chưa đúng. Đáp án: ${item.answer}',
            key: const ValueKey('typing-result'),
            style: TextStyle(fontWeight: FontWeight.bold, color: _correct! ? colors.primary : colors.error),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(key: const ValueKey('typing-check'), onPressed: _check, child: const Text('Kiểm tra')),
            const Spacer(),
            if (_correct != null)
              OutlinedButton(key: const ValueKey('typing-next'), onPressed: _next, child: const Text('Câu tiếp')),
          ],
        ),
      ],
    );
  }
}
