import 'package:flutter/material.dart';

import '../data/n5_repository.dart';
import '../data/progress_store.dart';
import '../data/word_bank.dart';
import '../models/n5.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'kanji_screen.dart';
import 'listening_screen.dart';
import 'n5_screen.dart';
import 'quiz_screen.dart';
import 'sentence_order_screen.dart';

/// Từ đang mở để học: từ N5 và từ của các bài N4 đã học xong ngữ pháp.
List<WordEntry> unlockedWords(WordBank bank, ProgressStore progress) => [
  for (final g in bank.groups)
    if (g.lesson == null || progress.isVocabUnlocked(g.lesson!)) ...g.words,
];

/// Mở màn hình Luyện nghe: 10 câu nghe hiểu và 10 từ để chép chính tả.
void openListening(
  BuildContext context, {
  required WordBank bank,
  required N5Data n5Data,
  required ProgressStore progress,
  required Speaker speaker,
}) {
  final open = unlockedWords(bank, progress);
  final learned = open.where((w) => progress.isWordLearned(w.key)).toList();
  final words = [...(learned.length >= 10 ? learned : open)]..shuffle();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ListeningScreen(
        items: listeningItems(n5Data.grammar),
        words: words.take(10).toList(),
        progress: progress,
        speaker: speaker,
      ),
    ),
  );
}

/// Trang Luyện tập: trắc nghiệm từ vựng có tính giờ, sắp xếp câu, học Kanji,
/// Tổng hợp N5 và đề thi thử.
class PracticeScreen extends StatelessWidget {
  final WordBank bank;
  final N5Repository n5;
  final N5Data n5Data;
  final ProgressStore progress;
  final Speaker speaker;

  const PracticeScreen({
    super.key,
    required this.bank,
    required this.n5,
    required this.n5Data,
    required this.progress,
    required this.speaker,
  });

  void _vocabQuiz(BuildContext context) {
    final open = unlockedWords(bank, progress);
    final learned = open.where((w) => progress.isWordLearned(w.key)).toList();
    // Ưu tiên các từ đã học; học ít quá thì hỏi cả các từ chưa học.
    final source = learned.length >= 10 ? learned : open;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          title: 'Quiz từ vựng',
          heading: 'Nghĩa của từ?',
          showTimer: true,
          questions: meaningQuiz(source, open),
          passMark: ProgressStore.passMark,
          onAnswer: progress.recordAnswer,
          passMessage: 'Giỏi lắm! Bạn nhớ từ rất tốt.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập')),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final kanjiDone = n5Data.kanji
              .where((k) => progress.isKanjiLearned(k.char))
              .length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _PracticeTile(
                key: const ValueKey('practice-quiz'),
                icon: Icons.quiz_rounded,
                color: AppColors.primary,
                title: 'Trắc nghiệm từ vựng',
                subtitle: '10 câu chọn nghĩa đúng, có tính giờ',
                onTap: () => _vocabQuiz(context),
              ),
              _PracticeTile(
                key: const ValueKey('practice-listening'),
                icon: Icons.headphones_rounded,
                color: AppColors.green,
                title: 'Luyện nghe',
                subtitle: 'Nghe hiểu câu ngắn • Dictation từ vựng',
                onTap: () => openListening(
                  context,
                  bank: bank,
                  n5Data: n5Data,
                  progress: progress,
                  speaker: speaker,
                ),
              ),
              _PracticeTile(
                key: const ValueKey('practice-order'),
                icon: Icons.sort_rounded,
                color: AppColors.purple,
                title: 'Luyện tập câu',
                subtitle: 'Sắp xếp các từ để tạo thành câu đúng',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        SentenceOrderScreen(items: orderItems(n5Data.grammar)),
                  ),
                ),
              ),
              _PracticeTile(
                key: const ValueKey('practice-kanji'),
                icon: Icons.brush_rounded,
                color: AppColors.pink,
                title: 'Học Kanji',
                subtitle:
                    '${n5Data.kanji.length} chữ Hán N5 · đã nhớ $kanjiDone',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => KanjiScreen(
                      kanji: n5Data.kanji,
                      progress: progress,
                      speaker: speaker,
                    ),
                  ),
                ),
              ),
              _PracticeTile(
                key: const ValueKey('practice-n5'),
                icon: Icons.assignment_rounded,
                color: AppColors.orange,
                title: 'Tổng hợp N5 và đề thi thử',
                subtitle: 'Kiến thức cần nhớ, các thể, 5 đề test có giải thích',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => N5Screen(
                      repository: n5,
                      progress: progress,
                      speaker: speaker,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PracticeTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PracticeTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          IconTile(icon, color: color, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
