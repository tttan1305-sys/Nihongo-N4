import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../services/recognizer.dart';
import '../services/speaker.dart';
import 'quiz_screen.dart';
import 'speaking_screen.dart';
import 'writing_screen.dart';

/// Luyện kỹ năng Nghe, Nói, Viết của bài (Đọc nằm ở tab Đọc hiểu).
class SkillsTab extends StatelessWidget {
  final Lesson lesson;
  final Speaker speaker;
  final Recognizer recognizer;

  const SkillsTab({super.key, required this.lesson, required this.speaker, required this.recognizer});

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final sentences = lesson.sentencesById;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _tile(
          context,
          key: 'skill-listening',
          icon: Icons.headphones,
          title: 'Nghe',
          subtitle: 'Nghe câu tiếng Nhật, chọn nghĩa đúng (${lesson.listening.length} câu)',
          onTap: () => _open(
            context,
            QuizScreen(
              title: 'Luyện nghe',
              questions: lesson.listening,
              passMark: ProgressStore.passMark,
              passMessage: 'Tai bạn đã quen với các câu của bài.',
              speaker: speaker,
              lesson: lesson.number,
              sentences: sentences,
            ),
          ),
        ),
        _tile(
          context,
          key: 'skill-speaking',
          icon: Icons.record_voice_over,
          title: 'Nói',
          subtitle: 'Nghe câu mẫu rồi đọc theo, máy chấm độ giống (${lesson.speakingIds.length} câu)',
          onTap: () => _open(
            context,
            SpeakingScreen(
              lesson: lesson.number,
              sentences: [for (final id in lesson.speakingIds) sentences[id]!],
              speaker: speaker,
              recognizer: recognizer,
            ),
          ),
        ),
        _tile(
          context,
          key: 'skill-writing',
          icon: Icons.draw,
          title: 'Viết',
          subtitle: 'Tập viết ${lesson.kanji.length} chữ Hán và gõ lại ${lesson.typing.length} câu bằng hiragana',
          onTap: () => _open(context, WritingScreen(kanji: lesson.kanji, typing: lesson.typing)),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context,
      {required String key,
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        key: ValueKey(key),
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 36),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
