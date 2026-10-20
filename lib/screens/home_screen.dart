import 'package:flutter/material.dart';

import '../data/flashcard_store.dart';
import '../data/lesson_repository.dart';
import '../data/progress_store.dart';
import '../services/recognizer.dart';
import '../services/speaker.dart';
import 'flashcard_screen.dart';
import 'lesson_screen.dart';

/// Trang chủ: số thẻ cần ôn hôm nay và lộ trình bài 26 → 50.
class HomeScreen extends StatelessWidget {
  final LessonRepository repository;
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final Speaker speaker;
  final Recognizer recognizer;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.progress,
    required this.flashcards,
    required this.speaker,
    required this.recognizer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lộ trình N4')),
      body: FutureBuilder<Set<int>>(
        future: repository.availableLessons(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final available = snapshot.data!;
          return ListenableBuilder(
            listenable: progress,
            builder: (context, _) => ListView.separated(
            itemCount: lastLesson - firstLesson + 2,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              if (i == 0) return _reviewCard(context);
              final number = firstLesson + i - 1;
              final written = available.contains(number);
              final unlocked = progress.isLessonUnlocked(number, first: firstLesson);
              final completed = progress.isLessonCompleted(number);
              final ready = written && unlocked;
              return ListTile(
                key: ValueKey('lesson-$number'),
                leading: CircleAvatar(child: Text('$number')),
                title: Text('Bài $number'),
                subtitle: Text(!written
                    ? 'Đang soạn nội dung'
                    : completed
                        ? 'Đã hoàn thành'
                        : unlocked
                            ? 'Sẵn sàng'
                            : 'Hoàn thành bài trước để mở'),
                enabled: ready,
                trailing: Icon(completed
                    ? Icons.check_circle
                    : ready
                        ? Icons.chevron_right
                        : Icons.lock_outline),
                onTap: ready
                    ? () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => LessonScreen(
                            repository: repository,
                            progress: progress,
                            flashcards: flashcards,
                            speaker: speaker,
                            recognizer: recognizer,
                            number: number,
                          ),
                        ))
                    : null,
              );
            },
          ),
          );
        },
      ),
    );
  }

  Widget _reviewCard(BuildContext context) {
    return ListenableBuilder(
      listenable: flashcards,
      builder: (context, _) {
        final due = flashcards.dueCards().length;
        return Card(
          margin: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.style, size: 36),
            title: Text(
              flashcards.totalCount == 0 ? 'Chưa có flashcard' : 'Hôm nay cần ôn $due thẻ',
              key: const ValueKey('due-count'),
            ),
            subtitle: Text(flashcards.totalCount == 0
                ? 'Học xong phần Từ vựng của một bài để thêm thẻ.'
                : 'Tổng cộng ${flashcards.totalCount} thẻ'),
            trailing: FilledButton(
              key: const ValueKey('start-review'),
              onPressed: due == 0
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => FlashcardScreen(
                          repository: repository,
                          flashcards: flashcards,
                          progress: progress,
                          speaker: speaker,
                        ),
                      )),
              child: const Text('Ôn'),
            ),
          ),
        );
      },
    );
  }
}
