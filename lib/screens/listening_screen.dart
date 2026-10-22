import 'dart:math';

import 'package:flutter/material.dart';

import '../data/n5_repository.dart';
import '../data/progress_store.dart';
import '../data/word_bank.dart';
import '../services/japanese_text.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/option_row.dart';
import '../widgets/ruby_text.dart';
import '../widgets/ui.dart';

const _letters = ['A', 'B', 'C', 'D'];

/// Luyện nghe: "Nghe hiểu" (nghe câu, chọn nghĩa) và "Dictation" (nghe từ,
/// gõ lại bằng kana).
class ListeningScreen extends StatelessWidget {
  final List<ListeningItem> items;
  final List<WordEntry> words;
  final ProgressStore progress;
  final Speaker speaker;

  const ListeningScreen({
    super.key,
    required this.items,
    required this.words,
    required this.progress,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Luyện nghe'),
          bottom: const TabBar(
            tabs: [
              Tab(key: ValueKey('tab-comprehension'), text: 'Nghe hiểu'),
              Tab(key: ValueKey('tab-dictation'), text: 'Dictation'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Comprehension(items: items, progress: progress, speaker: speaker),
            _Dictation(words: words, progress: progress, speaker: speaker),
          ],
        ),
      ),
    );
  }
}

class _Comprehension extends StatefulWidget {
  final List<ListeningItem> items;
  final ProgressStore progress;
  final Speaker speaker;

  const _Comprehension({
    required this.items,
    required this.progress,
    required this.speaker,
  });

  @override
  State<_Comprehension> createState() => _ComprehensionState();
}

class _ComprehensionState extends State<_Comprehension> {
  int _index = 0;
  int _correct = 0;
  int? _picked;
  bool _checked = false;
  bool _showText = false;

  ListeningItem get _item => widget.items[_index];

  void _play() => widget.speaker.speak(
    lesson: n5AudioLesson,
    audioId: _item.id,
    text: readingText(_item.ja),
  );

  void _check() {
    final right = _picked == _item.answer;
    widget.progress.recordAnswer(right);
    setState(() {
      _checked = true;
      _showText = true;
      if (right) _correct++;
    });
  }

  void _next() => setState(() {
    _index++;
    _picked = null;
    _checked = false;
    _showText = false;
  });

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(child: Text('Chưa có câu nghe.'));
    }
    if (_index >= widget.items.length) {
      return _Result(
        text: 'Đúng $_correct/${widget.items.length} câu',
        onRestart: () => setState(() {
          _index = 0;
          _correct = 0;
          _picked = null;
          _checked = false;
          _showText = false;
        }),
      );
    }
    final item = _item;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              StepProgress(current: _index + 1, total: widget.items.length),
              const SizedBox(height: 16),
              _Player(
                seed: item.id,
                onPlay: _play,
                transcript: _showText
                    ? RubyText(
                        item.ja,
                        key: const ValueKey('listen-text'),
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.text,
                        ),
                      )
                    : TextButton.icon(
                        key: const ValueKey('listen-show-text'),
                        onPressed: () => setState(() => _showText = true),
                        icon: const Icon(Icons.subtitles_outlined),
                        label: const Text('Hiện lời'),
                      ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chọn đáp án đúng:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < item.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OptionRow(
                    key: ValueKey('listen-option-$i'),
                    letter: _letters[i],
                    text: item.options[i],
                    state: !_checked
                        ? (_picked == i
                              ? OptionState.selected
                              : OptionState.idle)
                        : i == item.answer
                        ? OptionState.right
                        : i == _picked
                        ? OptionState.wrong
                        : OptionState.idle,
                    onTap: () {
                      if (!_checked) setState(() => _picked = i);
                    },
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: _checked
                  ? FilledButton(
                      key: const ValueKey('listen-next'),
                      onPressed: _next,
                      child: Text(
                        _index + 1 == widget.items.length
                            ? 'Xem kết quả'
                            : 'Tiếp theo',
                      ),
                    )
                  : FilledButton(
                      key: const ValueKey('listen-check'),
                      onPressed: _picked == null ? null : _check,
                      child: const Text('Kiểm tra'),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dictation extends StatefulWidget {
  final List<WordEntry> words;
  final ProgressStore progress;
  final Speaker speaker;

  const _Dictation({
    required this.words,
    required this.progress,
    required this.speaker,
  });

  @override
  State<_Dictation> createState() => _DictationState();
}

class _DictationState extends State<_Dictation> {
  final _controller = TextEditingController();
  int _index = 0;
  int _correct = 0;
  bool? _right;

  WordEntry get _word => widget.words[_index];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() => widget.speaker.speak(
    lesson: _word.audioLesson,
    audioId: _word.audioId,
    text: _word.kana,
  );

  void _check() {
    if (_right != null) return;
    final right = normalizeJa(_controller.text) == normalizeJa(_word.kana);
    widget.progress.recordAnswer(right);
    setState(() {
      _right = right;
      if (right) _correct++;
    });
  }

  void _next() => setState(() {
    _index++;
    _right = null;
    _controller.clear();
  });

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return const Center(child: Text('Chưa có từ để nghe.'));
    }
    if (_index >= widget.words.length) {
      return _Result(
        text: 'Đúng $_correct/${widget.words.length} từ',
        onRestart: () => setState(() {
          _index = 0;
          _correct = 0;
          _right = null;
          _controller.clear();
        }),
      );
    }
    final w = _word;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              StepProgress(current: _index + 1, total: widget.words.length),
              const SizedBox(height: 16),
              _Player(
                seed: w.key,
                onPlay: _play,
                transcript: const Text(
                  'Nghe rồi gõ lại từ bằng hiragana/katakana',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const ValueKey('dictation-input'),
                controller: _controller,
                enabled: _right == null,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  hintText: 'Gõ từ vừa nghe...',
                  prefixIcon: Icon(Icons.keyboard_rounded),
                ),
                onSubmitted: (_) => _check(),
              ),
              if (_right != null) ...[
                const SizedBox(height: 14),
                AppCard(
                  key: const ValueKey('dictation-result'),
                  borderColor: _right! ? AppColors.green : AppColors.red,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _right! ? 'Chính xác!' : 'Chưa đúng',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _right! ? AppColors.green : AppColors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 8,
                        children: [
                          RubyText(
                            w.word,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '(${w.kana}) · ${w.meaningVi}',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: _right == null
                  ? FilledButton(
                      key: const ValueKey('dictation-check'),
                      onPressed: _check,
                      child: const Text('Kiểm tra'),
                    )
                  : FilledButton(
                      key: const ValueKey('dictation-next'),
                      onPressed: _next,
                      child: Text(
                        _index + 1 == widget.words.length
                            ? 'Xem kết quả'
                            : 'Tiếp theo',
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Khung phát âm: nút phát tròn phát sáng, sóng âm và lời (nếu hiện).
class _Player extends StatelessWidget {
  final String seed;
  final VoidCallback onPlay;
  final Widget transcript;

  const _Player({
    required this.seed,
    required this.onPlay,
    required this.transcript,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.55),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: IconButton.filled(
                  key: const ValueKey('listen-play'),
                  tooltip: 'Nghe',
                  iconSize: 30,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    fixedSize: const Size(58, 58),
                  ),
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: CustomPaint(painter: _WavePainter(seed.hashCode)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: transcript),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final int seed;

  _WavePainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);
    const bars = 34;
    final step = size.width / bars;
    final paint = Paint()
      ..strokeWidth = step * 0.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < bars; i++) {
      final t = sin(i / bars * pi);
      final h =
          size.height * (0.15 + 0.85 * t * (0.4 + rnd.nextDouble() * 0.6));
      paint.color = Color.lerp(AppColors.primary, AppColors.purple, i / bars)!;
      final x = step * (i + 0.5);
      canvas.drawLine(
        Offset(x, (size.height - h) / 2),
        Offset(x, (size.height + h) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.seed != seed;
}

class _Result extends StatelessWidget {
  final String text;
  final VoidCallback onRestart;

  const _Result({required this.text, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎧', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            text,
            key: const ValueKey('listen-score'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: onRestart, child: const Text('Làm lại')),
        ],
      ),
    );
  }
}
