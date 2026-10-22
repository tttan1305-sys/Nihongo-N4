import 'dart:async';

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/ruby_text.dart';
import '../widgets/ui.dart';

const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

/// Bài kiểm tra trắc nghiệm, mỗi lần một câu. Đóng màn hình trả về điểm (0..1).
class QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final double passMark;
  final String passMessage;

  /// Dòng hỏi phía trên câu, ví dụ "Nghĩa của từ?".
  final String? heading;

  /// Hiện đồng hồ đếm thời gian làm bài.
  final bool showTimer;

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
    this.heading,
    this.showTimer = false,
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
  Timer? _timer;
  int _seconds = 0;

  bool get _finished => _index >= widget.questions.length;
  double get _score =>
      widget.questions.isEmpty ? 1 : _correct / widget.questions.length;

  @override
  void initState() {
    super.initState();
    if (widget.showTimer) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
    if (_finished) _timer?.cancel();
  });

  void _restart() => setState(() {
    _index = 0;
    _correct = 0;
    _picked = null;
    if (widget.showTimer) _startTimer();
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
        body: _finished ? _buildResult(context) : _buildQuestion(context),
      ),
    );
  }

  String get _clock =>
      '${(_seconds ~/ 60).toString().padLeft(2, '0')}:'
      '${(_seconds % 60).toString().padLeft(2, '0')}';

  Widget _buildQuestion(BuildContext context) {
    final q = widget.questions[_index];
    final last = _index + 1 >= widget.questions.length;
    final short = plainText(q.prompt).characters.length <= 10;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: StepProgress(
            current: _index + 1,
            total: widget.questions.length,
            trailing: widget.showTimer
                ? Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _clock,
                        key: const ValueKey('quiz-timer'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [
              if (widget.heading != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    widget.heading!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              if (q.prompt.isNotEmpty || q.audioId != null)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      if (q.prompt.isNotEmpty)
                        Center(
                          child: RubyText(
                            q.prompt,
                            style: TextStyle(
                              fontSize: short ? 34 : 20,
                              fontWeight: short
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      if (q.audioId != null && widget.speaker != null)
                        _listenPrompt(q.audioId!),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              for (var i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionRow(
                    key: ValueKey('option-$i'),
                    letter: _letters[i],
                    text: q.options[i],
                    state: _picked == null
                        ? _OptionState.idle
                        : i == q.answer
                        ? _OptionState.right
                        : i == _picked
                        ? _OptionState.wrong
                        : _OptionState.idle,
                    onTap: () => _pick(i),
                  ),
                ),
              if (_picked != null) _feedback(context, q),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('next'),
                onPressed: _picked == null ? null : _next,
                child: Text(last ? 'Xem kết quả' : 'Tiếp tục'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _feedback(BuildContext context, Question q) {
    final right = _picked == q.answer;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: right ? AppColors.greenSoft : AppColors.redSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            right ? 'Đúng rồi!' : 'Chưa đúng.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: right ? AppColors.green : AppColors.red,
            ),
          ),
          if (q.explanationVi != null) RubyText(q.explanationVi!),
          if (widget.sentences[q.audioId] case final s?) ...[
            const SizedBox(height: 4),
            RubyText(s.ja, style: const TextStyle(fontSize: 18)),
            Text(s.vi, style: const TextStyle(color: AppColors.muted)),
          ],
        ],
      ),
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
          icon: const Icon(Icons.volume_up_rounded),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            passed ? '🎉' : '💪',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            'Đúng $_correct/${widget.questions.length} câu (${(_score * 100).round()}%)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (widget.showTimer)
            Text(
              'Thời gian: $_clock',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          const SizedBox(height: 8),
          Text(
            passed
                ? widget.passMessage
                : 'Cần đạt từ ${(widget.passMark * 100).round()}% để qua. Xem lại ví dụ rồi làm lại nhé.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!passed) ...[
            OutlinedButton(onPressed: _restart, child: const Text('Làm lại')),
            const SizedBox(height: 8),
          ],
          FilledButton(
            key: const ValueKey('done'),
            onPressed: () => Navigator.of(context).pop(_score),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }
}

enum _OptionState { idle, right, wrong }

class _OptionRow extends StatelessWidget {
  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionRow({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (state) {
      _OptionState.right => (AppColors.green, AppColors.greenSoft),
      _OptionState.wrong => (AppColors.red, AppColors.redSoft),
      _OptionState.idle => (AppColors.primary, Colors.white),
    };
    final radius = BorderRadius.circular(16);
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: state == _OptionState.idle ? AppColors.border : color,
          width: state == _OptionState.idle ? 1 : 1.6,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: state == _OptionState.idle
                      ? AppColors.primarySoft
                      : color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: state == _OptionState.idle
                        ? AppColors.primary
                        : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RubyText(
                  text,
                  style: const TextStyle(fontSize: 17, color: AppColors.text),
                ),
              ),
              if (state != _OptionState.idle)
                Icon(
                  state == _OptionState.right
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
