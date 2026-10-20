import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/speaker.dart';
import '../widgets/ruby_text.dart';

/// Bài kiểm tra trắc nghiệm, mỗi lần một câu. Đóng màn hình trả về điểm (0..1).
class QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final double passMark;
  final String passMessage;

  /// Dùng cho câu hỏi nghe (có audioId): phát câu và hiện lại câu sau khi trả lời.
  final Speaker? speaker;
  final int lesson;
  final Map<String, Sentence> sentences;

  const QuizScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.passMark,
    this.passMessage = 'Bạn đã qua phần này.',
    this.speaker,
    this.lesson = 0,
    this.sentences = const {},
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int _correct = 0;
  int? _picked;

  bool get _finished => _index >= widget.questions.length;
  double get _score => widget.questions.isEmpty ? 1 : _correct / widget.questions.length;

  void _pick(int option) {
    if (_picked != null) return;
    setState(() {
      _picked = option;
      if (option == widget.questions[_index].answer) _correct++;
    });
  }

  void _next() => setState(() {
        _index++;
        _picked = null;
      });

  void _restart() => setState(() {
        _index = 0;
        _correct = 0;
        _picked = null;
      });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_finished ? _score : null);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _finished ? _buildResult(context) : _buildQuestion(context),
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final q = widget.questions[_index];
    final colors = Theme.of(context).colorScheme;
    return ListView(
      children: [
        Text('Câu ${_index + 1}/${widget.questions.length}', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        if (q.prompt.isNotEmpty) RubyText(q.prompt, style: const TextStyle(fontSize: 20)),
        if (q.audioId != null && widget.speaker != null) _listenPrompt(q.audioId!),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              key: ValueKey('option-$i'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(12),
                backgroundColor: _picked == null
                    ? null
                    : i == q.answer
                        ? colors.primaryContainer
                        : i == _picked
                            ? colors.errorContainer
                            : null,
              ),
              onPressed: () => _pick(i),
              child: RubyText(q.options[i], style: TextStyle(fontSize: 18, color: colors.onSurface)),
            ),
          ),
        if (_picked != null) ...[
          const SizedBox(height: 8),
          Text(_picked == q.answer ? 'Đúng rồi!' : 'Chưa đúng.',
              style: TextStyle(fontWeight: FontWeight.bold, color: _picked == q.answer ? colors.primary : colors.error)),
          if (q.explanationVi != null) RubyText(q.explanationVi!),
          if (widget.sentences[q.audioId] case final s?) ...[
            RubyText(s.ja, style: const TextStyle(fontSize: 18)),
            Text(s.vi, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('next'),
            onPressed: _next,
            child: Text(_index + 1 < widget.questions.length ? 'Câu tiếp theo' : 'Xem kết quả'),
          ),
        ],
      ],
    );
  }

  Widget _listenPrompt(String audioId) {
    final s = widget.sentences[audioId];
    return Column(
      children: [
        const Text('Nghe rồi chọn nghĩa đúng'),
        const SizedBox(height: 8),
        IconButton.filledTonal(
          key: const ValueKey('quiz-listen'),
          iconSize: 48,
          icon: const Icon(Icons.volume_up),
          onPressed: () => widget.speaker!.speak(
            lesson: widget.lesson,
            audioId: audioId,
            text: s == null ? '' : plainText(s.ja),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final passed = _score >= widget.passMark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(passed ? Icons.check_circle : Icons.replay, size: 72,
            color: passed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error),
        const SizedBox(height: 16),
        Text('Đúng $_correct/${widget.questions.length} câu (${(_score * 100).round()}%)',
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          passed
              ? widget.passMessage
              : 'Cần đạt từ ${(widget.passMark * 100).round()}% để qua. Xem lại ví dụ rồi làm lại nhé.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (!passed) OutlinedButton(onPressed: _restart, child: const Text('Làm lại')),
        const SizedBox(height: 8),
        FilledButton(
          key: const ValueKey('done'),
          onPressed: () => Navigator.of(context).pop(_score),
          child: const Text('Xong'),
        ),
      ],
    );
  }
}
