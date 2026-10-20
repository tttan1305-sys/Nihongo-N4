import 'package:flutter/material.dart';

import '../data/flashcard_store.dart';
import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../services/speaker.dart';
import '../widgets/listen_button.dart';
import '../widgets/ruby_text.dart';

/// Phần từ vựng: mỗi từ có furigana, nghĩa, nút nghe và câu áp dụng thực tế.
class VocabTab extends StatelessWidget {
  final Lesson lesson;
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final Speaker speaker;

  const VocabTab({
    super.key,
    required this.lesson,
    required this.progress,
    required this.flashcards,
    required this.speaker,
  });

  Future<void> _finish() async {
    await flashcards.addLesson(lesson);
    await progress.markVocabDone(lesson.number);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([progress, flashcards]),
      builder: (context, _) {
        final showRuby = progress.showFurigana;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            SwitchListTile(
              key: const ValueKey('toggle-furigana'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Hiện furigana'),
              subtitle: const Text('Tắt đi để tự kiểm tra cách đọc chữ Hán'),
              value: showRuby,
              onChanged: progress.setShowFurigana,
            ),
            for (final v in lesson.vocab)
              _VocabCard(
                vocab: v,
                lesson: lesson.number,
                speaker: speaker,
                flashcards: flashcards,
                showRuby: showRuby,
              ),
            const SizedBox(height: 16),
            if (progress.isVocabDone(lesson.number))
              const ListTile(
                leading: Icon(Icons.check_circle),
                title: Text('Bạn đã học xong từ vựng bài này'),
                subtitle: Text('Các từ đã vào bộ flashcard để ôn tập.'),
              )
            else
              FilledButton.icon(
                key: const ValueKey('vocab-done'),
                onPressed: _finish,
                icon: const Icon(Icons.check),
                label: const Text('Đã học xong, đưa vào flashcard'),
              ),
          ],
        );
      },
    );
  }
}

class _VocabCard extends StatelessWidget {
  final Vocab vocab;
  final int lesson;
  final Speaker speaker;
  final FlashcardStore flashcards;
  final bool showRuby;

  const _VocabCard({
    required this.vocab,
    required this.lesson,
    required this.speaker,
    required this.flashcards,
    required this.showRuby,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = vocab.practical;
    final inDeck = flashcards.contains(lesson, vocab.id);
    return Card(
      key: ValueKey('vocab-${vocab.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: RubyText(
                    vocab.word,
                    showRuby: showRuby,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                // Đọc theo kana để máy đọc đúng âm của từ.
                ListenButton(
                  speaker: speaker,
                  lesson: lesson,
                  audioId: vocab.id,
                  text: vocab.kana,
                ),
                IconButton(
                  key: ValueKey('deck-${vocab.id}'),
                  tooltip: inDeck ? 'Bỏ khỏi flashcard' : 'Thêm vào flashcard',
                  icon: Icon(
                    inDeck ? Icons.bookmark : Icons.bookmark_add_outlined,
                  ),
                  onPressed: () => inDeck
                      ? flashcards.remove(lesson, vocab.id)
                      : flashcards.add(lesson, vocab.id),
                ),
              ],
            ),
            Text(vocab.meaningVi, style: text.titleMedium),
            Text(vocab.pos, style: text.bodySmall),
            const Divider(),
            Text('Dùng thực tế: ${p.situationVi}', style: text.labelMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: RubyText(
                    p.ja,
                    showRuby: showRuby,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                ListenButton(
                  speaker: speaker,
                  lesson: lesson,
                  audioId: p.id,
                  text: plainText(p.ja),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(p.vi, style: text.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
