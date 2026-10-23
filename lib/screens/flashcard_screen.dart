import 'package:flutter/material.dart';

import '../data/flashcard_store.dart';
import '../data/lesson_repository.dart';
import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../services/speaker.dart';
import '../srs/sm2.dart';
import '../widgets/listen_button.dart';
import '../widgets/content_scale.dart';
import '../widgets/ruby_text.dart';

/// Ôn các thẻ đến hạn hôm nay. Thẻ bấm "Quên" quay lại cuối hàng trong cùng lượt ôn.
class FlashcardScreen extends StatefulWidget {
  final LessonRepository repository;
  final FlashcardStore flashcards;
  final ProgressStore progress;
  final Speaker speaker;

  const FlashcardScreen({
    super.key,
    required this.repository,
    required this.flashcards,
    required this.progress,
    required this.speaker,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late final List<CardId> _queue = widget.flashcards.dueCards();
  late final Future<Map<String, Vocab>> _vocab = _loadVocab();
  bool _revealed = false;
  int _reviewed = 0;

  Future<Map<String, Vocab>> _loadVocab() async {
    final result = <String, Vocab>{};
    for (final number in {for (final id in _queue) id.lesson}) {
      final lesson = await widget.repository.load(number);
      for (final v in lesson.vocab) {
        result[CardId(number, v.id).toString()] = v;
      }
    }
    return result;
  }

  Future<void> _rate(Rating rating) async {
    final id = _queue.removeAt(0);
    await widget.flashcards.rate(id, rating);
    setState(() {
      if (rating == Rating.again) _queue.add(id);
      _reviewed++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ôn flashcard')),
      body: ContentScale(
        child: FutureBuilder<Map<String, Vocab>>(
          future: _vocab,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            // Bỏ qua thẻ của từ không còn trong bài (nội dung bài đã sửa).
            _queue.removeWhere(
              (id) => !snapshot.data!.containsKey(id.toString()),
            );
            if (_queue.isEmpty) return _done(context);
            final id = _queue.first;
            return _card(context, id, snapshot.data![id.toString()]!);
          },
        ),
      ),
    );
  }

  Widget _done(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Hôm nay bạn đã ôn xong!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Đã ôn $_reviewed lượt thẻ.'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, CardId id, Vocab v) {
    final text = Theme.of(context).textTheme;
    final state = widget.flashcards.stateOf(id)!;
    final now = widget.flashcards.now;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Còn ${_queue.length} thẻ · Bài ${id.lesson}',
          style: text.labelLarge,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                RubyText(
                  v.word,
                  showRuby: widget.progress.showFurigana,
                  style: const TextStyle(fontSize: 36),
                ),
                ListenButton(
                  speaker: widget.speaker,
                  lesson: id.lesson,
                  audioId: v.id,
                  text: v.kana,
                ),
                if (_revealed) ...[
                  const Divider(),
                  Text(
                    v.kana,
                    key: const ValueKey('answer-kana'),
                    style: text.titleMedium,
                  ),
                  Text(
                    v.meaningVi,
                    style: text.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  RubyText(
                    v.practical.ja,
                    style: const TextStyle(fontSize: 17),
                  ),
                  Text(
                    v.practical.vi,
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!_revealed)
          FilledButton(
            key: const ValueKey('reveal'),
            onPressed: () => setState(() => _revealed = true),
            child: const Text('Hiện đáp án'),
          )
        else
          Row(
            children: [
              for (final (rating, label) in [
                (Rating.again, 'Quên'),
                (Rating.hard, 'Khó'),
                (Rating.good, 'Được'),
                (Rating.easy, 'Dễ'),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: OutlinedButton(
                      key: ValueKey('rate-${rating.name}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _rate(rating),
                      child: Column(
                        children: [
                          Text(label),
                          Text(
                            nextIntervalLabel(state, rating, now),
                            style: text.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
