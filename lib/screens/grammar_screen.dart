import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../services/speaker.dart';
import '../widgets/listen_button.dart';
import '../widgets/ruby_text.dart';
import 'quiz_screen.dart';

/// Chi tiết một mẫu ngữ pháp: giải thích, cách dùng thực tế, ví dụ, bài kiểm tra.
class GrammarScreen extends StatelessWidget {
  final int lessonNumber;
  final GrammarPoint grammar;
  final ProgressStore progress;
  final Speaker speaker;

  const GrammarScreen({
    super.key,
    required this.lessonNumber,
    required this.grammar,
    required this.progress,
    required this.speaker,
  });

  Future<void> _startQuiz(BuildContext context) async {
    final score = await Navigator.of(context).push<double>(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          title: 'Kiểm tra ngữ pháp',
          questions: grammar.quiz,
          passMark: ProgressStore.passMark,
          passMessage: 'Bạn đã qua mẫu ngữ pháp này.',
        ),
      ),
    );
    if (score != null) {
      await progress.saveGrammarScore(lessonNumber, grammar.id, score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ngữ pháp')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RubyText(
            grammar.pattern,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(grammar.meaningVi, style: text.titleMedium),
          const SizedBox(height: 16),
          Text('Giải thích', style: text.titleSmall),
          RubyText(grammar.explanationVi),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Người Nhật dùng thế nào', style: text.titleSmall),
                  RubyText(grammar.usageNoteVi),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Ví dụ', style: text.titleSmall),
          for (final e in grammar.examples) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: RubyText(e.ja, style: const TextStyle(fontSize: 20)),
                ),
                ListenButton(
                  speaker: speaker,
                  lesson: lessonNumber,
                  audioId: e.id,
                  text: plainText(e.ja),
                ),
              ],
            ),
            Text(e.vi, style: text.bodySmall),
          ],
          const SizedBox(height: 24),
          ListenableBuilder(
            listenable: progress,
            builder: (context, _) {
              final score = progress.grammarScore(lessonNumber, grammar.id);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (score != null)
                    Text(
                      'Điểm cao nhất: ${(score * 100).round()}%',
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const ValueKey('start-quiz'),
                    onPressed: () => _startQuiz(context),
                    icon: const Icon(Icons.quiz),
                    label: Text(
                      score == null
                          ? 'Làm bài kiểm tra'
                          : 'Làm lại bài kiểm tra',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
