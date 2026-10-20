import 'package:flutter/material.dart';

import '../data/flashcard_store.dart';
import '../data/lesson_repository.dart';
import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../services/recognizer.dart';
import '../services/speaker.dart';
import '../widgets/ruby_text.dart';
import 'grammar_screen.dart';
import 'reading_tab.dart';
import 'skills_tab.dart';
import 'vocab_tab.dart';

/// Màn hình bài học: Ngữ pháp → Từ vựng → Luyện kỹ năng → Đọc hiểu.
/// Tab Từ vựng khóa cho đến khi qua hết bài kiểm tra ngữ pháp;
/// Luyện kỹ năng và Đọc hiểu khóa cho đến khi học xong từ vựng.
class LessonScreen extends StatelessWidget {
  final LessonRepository repository;
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final Speaker speaker;
  final Recognizer recognizer;
  final int number;

  const LessonScreen({
    super.key,
    required this.repository,
    required this.progress,
    required this.flashcards,
    required this.speaker,
    required this.recognizer,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Lesson>(
      future: repository.load(number),
      builder: (context, snapshot) {
        final lesson = snapshot.data;
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Bài $number')),
            body: Center(
              child: snapshot.hasError
                  ? Text('Không mở được bài học: ${snapshot.error}')
                  : const CircularProgressIndicator(),
            ),
          );
        }
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Bài ${lesson.number}'),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  const Tab(text: 'Ngữ pháp'),
                  _lockableTab(
                    'Từ vựng',
                    () => progress.isVocabUnlocked(lesson),
                  ),
                  _lockableTab(
                    'Luyện kỹ năng',
                    () => progress.isVocabDone(lesson.number),
                  ),
                  _lockableTab(
                    'Đọc hiểu',
                    () => progress.isVocabDone(lesson.number),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _GrammarList(
                  lesson: lesson,
                  progress: progress,
                  speaker: speaker,
                ),
                ListenableBuilder(
                  listenable: progress,
                  builder: (context, _) => progress.isVocabUnlocked(lesson)
                      ? VocabTab(
                          lesson: lesson,
                          progress: progress,
                          flashcards: flashcards,
                          speaker: speaker,
                        )
                      : _Locked(
                          title: 'Phần Từ vựng đang khóa',
                          message:
                              'Hãy học xong phần Ngữ pháp trước. '
                              'Đã qua ${progress.passedGrammarCount(lesson)}/${lesson.grammar.length} mẫu ngữ pháp.',
                        ),
                ),
                _afterVocab(
                  lesson,
                  'Phần Luyện kỹ năng đang khóa',
                  () => SkillsTab(
                    lesson: lesson,
                    speaker: speaker,
                    recognizer: recognizer,
                  ),
                ),
                _afterVocab(
                  lesson,
                  'Bài đọc hiểu đang khóa',
                  () => ReadingTab(
                    lesson: lesson,
                    progress: progress,
                    speaker: speaker,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _lockableTab(String label, bool Function() unlocked) =>
      ListenableBuilder(
        listenable: progress,
        builder: (context, _) => Tab(
          icon: unlocked() ? null : const Icon(Icons.lock_outline, size: 16),
          iconMargin: EdgeInsets.zero,
          text: label,
        ),
      );

  Widget _afterVocab(
    Lesson lesson,
    String lockedTitle,
    Widget Function() build,
  ) => ListenableBuilder(
    listenable: progress,
    builder: (context, _) => progress.isVocabDone(lesson.number)
        ? build()
        : _Locked(
            title: lockedTitle,
            message: 'Hãy học xong phần Từ vựng của bài trước.',
          ),
  );
}

const _jaStyle = TextStyle(fontSize: 20);

class _GrammarList extends StatelessWidget {
  final Lesson lesson;
  final ProgressStore progress;
  final Speaker speaker;

  const _GrammarList({
    required this.lesson,
    required this.progress,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Học xong và đạt từ ${(ProgressStore.passMark * 100).round()}% mỗi bài kiểm tra ngữ pháp để mở phần Từ vựng.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (final g in lesson.grammar) _tile(context, g),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, GrammarPoint g) {
    final score = progress.grammarScore(lesson.number, g.id);
    final passed = progress.isGrammarPassed(lesson.number, g.id);
    return Card(
      child: ListTile(
        key: ValueKey('grammar-${g.id}'),
        contentPadding: const EdgeInsets.all(12),
        title: RubyText(
          g.pattern,
          style: _jaStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(g.meaningVi),
        trailing: passed
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : Text(score == null ? 'Chưa học' : '${(score * 100).round()}%'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GrammarScreen(
              lessonNumber: lesson.number,
              grammar: g,
              progress: progress,
              speaker: speaker,
            ),
          ),
        ),
      ),
    );
  }
}

class _Locked extends StatelessWidget {
  final String title;
  final String message;

  const _Locked({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
