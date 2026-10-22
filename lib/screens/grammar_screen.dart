import 'package:flutter/material.dart';

import '../data/n5_repository.dart';
import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../models/n5.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/ruby_text.dart';
import '../widgets/ui.dart';
import 'quiz_screen.dart';

/// Chi tiết một mẫu ngữ pháp: nghĩa, cách dùng, cấu trúc, ví dụ, lưu ý và
/// bài kiểm tra (mẫu của bài N4). Mẫu N5 dùng [GrammarScreen.n5].
class GrammarScreen extends StatelessWidget {
  final int lessonNumber;
  final GrammarPoint? grammar;
  final N5GrammarPoint? n5Point;
  final ProgressStore progress;
  final Speaker speaker;

  const GrammarScreen({
    super.key,
    required this.lessonNumber,
    required GrammarPoint this.grammar,
    required this.progress,
    required this.speaker,
  }) : n5Point = null;

  const GrammarScreen.n5({
    super.key,
    required N5GrammarPoint point,
    required this.progress,
    required this.speaker,
  }) : grammar = null,
       n5Point = point,
       lessonNumber = n5AudioLesson;

  String get _pattern => grammar?.pattern ?? n5Point!.pattern;
  String get _meaning => grammar?.meaningVi ?? n5Point!.meaningVi;
  String get _explanation => grammar?.explanationVi ?? n5Point!.explanationVi;
  List<Sentence> get _examples => grammar?.examples ?? n5Point!.examples;

  Future<void> _startQuiz(BuildContext context) async {
    final g = grammar!;
    final score = await Navigator.of(context).push<double>(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          title: 'Kiểm tra ngữ pháp',
          questions: g.quiz,
          passMark: ProgressStore.passMark,
          passMessage: 'Bạn đã qua mẫu ngữ pháp này.',
        ),
      ),
    );
    if (score != null) {
      await progress.saveGrammarScore(lessonNumber, g.id, score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = grammar?.usageNoteVi;
    return Scaffold(
      appBar: AppBar(
        title: Text(grammar == null ? 'Ngữ pháp N5' : 'Ngữ pháp N4'),
      ),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RubyText(
                    grammarTitle(_pattern),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Pill(_meaning, color: AppColors.pink),
                  const SizedBox(height: 20),
                  const SectionLabel(
                    'Cách dùng',
                    icon: Icons.lightbulb_outline_rounded,
                  ),
                  RubyText(
                    _explanation,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel(
                    'Cấu trúc',
                    icon: Icons.account_tree_outlined,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RubyText(
                      _pattern,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel(
                    'Ví dụ',
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                  for (final e in _examples)
                    _Example(
                      sentence: e,
                      lesson: lessonNumber,
                      speaker: speaker,
                      showRuby: progress.showFurigana,
                    ),
                ],
              ),
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.orangeSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel(
                      'Lưu ý',
                      icon: Icons.info_outline_rounded,
                      color: AppColors.orange,
                    ),
                    RubyText(note, style: const TextStyle(height: 1.4)),
                  ],
                ),
              ),
            ],
            if (grammar != null) ...[
              const SizedBox(height: 20),
              _quizButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _quizButton(BuildContext context) {
    final score = progress.grammarScore(lessonNumber, grammar!.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (score != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Điểm cao nhất: ${(score * 100).round()}%',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        FilledButton.icon(
          key: const ValueKey('start-quiz'),
          onPressed: () => _startQuiz(context),
          icon: const Icon(Icons.quiz_outlined),
          label: Text(
            score == null ? 'Làm bài kiểm tra' : 'Làm lại bài kiểm tra',
          ),
        ),
      ],
    );
  }
}

/// Tiêu đề ngắn của mẫu câu: phần sau dấu ＋ cuối cùng, ví dụ
/// "{普通形|ふつうけい} ＋ んです" → "～んです".
String grammarTitle(String pattern) {
  final i = [
    pattern.lastIndexOf('＋'),
    pattern.lastIndexOf('+'),
  ].reduce((a, b) => a > b ? a : b);
  if (i < 0) return pattern;
  final tail = pattern.substring(i + 1).trim();
  return tail.startsWith('～') ? tail : '～$tail';
}

class _Example extends StatelessWidget {
  final Sentence sentence;
  final int lesson;
  final Speaker speaker;
  final bool showRuby;

  const _Example({
    required this.sentence,
    required this.lesson,
    required this.speaker,
    required this.showRuby,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RubyText(
                  sentence.ja,
                  showRuby: showRuby,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  sentence.vi,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            key: ValueKey('listen-${sentence.id}'),
            tooltip: 'Nghe',
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
            onPressed: () => speaker.speak(
              lesson: lesson,
              audioId: sentence.id,
              text: plainText(sentence.ja),
            ),
          ),
        ],
      ),
    );
  }
}
