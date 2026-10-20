import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../services/speaker.dart';
import '../widgets/listen_button.dart';
import '../widgets/ruby_text.dart';
import 'quiz_screen.dart';

/// Bài đọc hiểu cuối bài: hoàn toàn tiếng Nhật, có nghe cả bài và câu hỏi hiểu bài.
class ReadingTab extends StatelessWidget {
  final Lesson lesson;
  final ProgressStore progress;
  final Speaker speaker;

  const ReadingTab({super.key, required this.lesson, required this.progress, required this.speaker});

  Future<void> _answer(BuildContext context) async {
    final score = await Navigator.of(context).push<double>(MaterialPageRoute(
      builder: (_) => QuizScreen(
        title: 'Đọc hiểu',
        questions: lesson.reading.questions,
        passMark: ProgressStore.passMark,
        passMessage: 'Bạn đã hoàn thành bài ${lesson.number}!',
      ),
    ));
    if (score != null) await progress.saveReadingScore(lesson.number, score);
  }

  @override
  Widget build(BuildContext context) {
    final r = lesson.reading;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final score = progress.readingScore(lesson.number);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: RubyText(r.titleJa, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                ListenButton(
                  speaker: speaker,
                  lesson: lesson.number,
                  audioId: r.id,
                  text: r.paragraphs.map(plainText).join('\n'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final p in r.paragraphs) ...[
              RubyText(p, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
            ],
            if (score != null)
              Text(
                progress.isLessonCompleted(lesson.number)
                    ? 'Đã hoàn thành bài · điểm đọc hiểu ${(score * 100).round()}%'
                    : 'Điểm đọc hiểu ${(score * 100).round()}%, cần từ ${(ProgressStore.passMark * 100).round()}% để hoàn thành bài',
                key: const ValueKey('reading-status'),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey('reading-quiz'),
              onPressed: () => _answer(context),
              icon: const Icon(Icons.quiz),
              label: Text('Trả lời ${r.questions.length} câu hỏi'),
            ),
          ],
        );
      },
    );
  }
}
