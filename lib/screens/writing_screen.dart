import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/japanese_text.dart';
import '../widgets/kanji_canvas.dart';
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tập viết chữ Hán'),
              Tab(text: 'Gõ hiragana'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _KanjiPractice(kanji: kanji),
            _TypingPractice(items: typing),
          ],
        ),
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

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final k = widget.kanji[_index];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Chữ ${_index + 1}/${widget.kanji.length}: ${k.meaningVi}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text('Cách đọc: ${k.readings}'),
        const SizedBox(height: 12),
        KanjiCanvas(char: k.char),
        const SizedBox(height: 12),
        Row(
          children: [
            const Spacer(),
            if (_index > 0)
              TextButton(
                onPressed: () => _go(_index - 1),
                child: const Text('Chữ trước'),
              ),
            FilledButton(
              key: const ValueKey('next-kanji'),
              onPressed: _index + 1 < widget.kanji.length
                  ? () => _go(_index + 1)
                  : null,
              child: const Text('Chữ tiếp'),
            ),
          ],
        ),
      ],
    );
  }
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
    setState(
      () => _correct =
          normalizeJa(_controller.text) ==
          normalizeJa(widget.items[_index].answer),
    );
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
        Text(
          'Câu ${_index + 1}/${widget.items.length}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        // Ẩn furigana: người học phải tự nhớ cách đọc.
        RubyText(
          item.ja,
          showRuby: false,
          style: const TextStyle(fontSize: 24),
        ),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _correct! ? colors.primary : colors.error,
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
              key: const ValueKey('typing-check'),
              onPressed: _check,
              child: const Text('Kiểm tra'),
            ),
            const Spacer(),
            if (_correct != null)
              OutlinedButton(
                key: const ValueKey('typing-next'),
                onPressed: _next,
                child: const Text('Câu tiếp'),
              ),
          ],
        ),
      ],
    );
  }
}
