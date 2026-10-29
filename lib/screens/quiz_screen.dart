import 'dart:async';

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/content_scale.dart';
import '../widgets/option_row.dart';
import '../widgets/ruby_text.dart';
import '../widgets/translation_note.dart';
import '../widgets/skin_widgets.dart';
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

  /// Gọi sau mỗi câu trả lời (true nếu đúng), để ghi thống kê.
  final ValueChanged<bool>? onAnswer;

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
    this.onAnswer,
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
    final right = option == widget.questions[_index].answer;
    widget.onAnswer?.call(right);
    setState(() {
      _picked = option;
      if (right) _correct++;
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
        body: SkinBackground(
          child: ContentScale(
            child: _finished ? _buildResult(context) : _buildQuestion(context),
          ),
        ),
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
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _clock,
                        key: const ValueKey('quiz-timer'),
                        style: TextStyle(
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              if (q.prompt.isNotEmpty || q.audioId != null)
                _promptFrame(
                  Column(
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
                              color:
                                  SkinPalette.current.skin == AppSkin.mechanical
                                  ? SkinPalette.current.screenInk
                                  : AppColors.text,
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
                  child: OptionRow(
                    key: ValueKey('option-$i'),
                    letter: _letters[i],
                    text: q.options[i],
                    state: _picked == null
                        ? OptionState.idle
                        : i == q.answer
                        ? OptionState.right
                        : i == _picked
                        ? OptionState.wrong
                        : OptionState.idle,
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
                child: Text(last ? 'Xem kết quả' : 'Tiếp theo'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Khung câu hỏi: thẻ thường (Neon), màn hình LCD (Mechanical) hoặc
  /// Kumo hỏi trong bong bóng thoại (Anime).
  Widget _promptFrame(Widget child) {
    final p = SkinPalette.current;
    switch (p.skin) {
      case AppSkin.neon:
        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: child,
        );
      case AppSkin.mechanical:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: p.surfaceHigh,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: p.border),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 150),
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 22),
            decoration: BoxDecoration(
              color: p.screen,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -22,
                  left: -4,
                  child: Text(
                    'INPUT >_',
                    style: skinLabelStyle(color: p.screenDim, size: 10),
                  ),
                ),
                Center(child: child),
              ],
            ),
          ),
        );
      case AppSkin.anime:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const KumoMascot(width: 56),
                const SizedBox(width: 6),
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: p.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: p.border, width: 2),
                  ),
                  child: Text(
                    'Kumo',
                    style: TextStyle(
                      color: p.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Center(child: child),
            ),
          ],
        );
    }
  }

  Widget _feedback(BuildContext context, Question q) {
    final right = _picked == q.answer;
    final skin = SkinPalette.current.skin;
    final title = switch (skin) {
      AppSkin.mechanical => right ? 'CHÍNH XÁC' : 'CHƯA ĐÚNG',
      AppSkin.anime => right ? '「すごい！」 Chính xác rồi!' : '「ざんねん…」 Chưa đúng',
      AppSkin.neon => right ? 'Đúng rồi!' : 'Chưa đúng.',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: right ? AppColors.greenSoft : AppColors.redSoft,
        borderRadius: BorderRadius.circular(skinCardRadius() - 4),
        border: skin == AppSkin.neon
            ? null
            : Border.all(
                color: right ? AppColors.green : AppColors.red,
                width: skin == AppSkin.anime ? 2 : 1,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: skin == AppSkin.mechanical
                ? skinLabelStyle(
                    color: right ? AppColors.green : AppColors.red,
                    size: 12,
                  )
                : TextStyle(
                    fontWeight: FontWeight.bold,
                    color: right ? AppColors.green : AppColors.red,
                  ),
          ),
          if (q.explanationVi != null) RubyText(q.explanationVi!),
          if (widget.sentences[q.audioId] case final s?)
            TranslationNote(s.vi, ja: s.ja)
          else if (q.translationVi case final vi?)
            TranslationNote(vi, ja: q.translationJa),
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
              style: TextStyle(color: AppColors.muted),
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
