import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../data/word_bank.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/ruby_text.dart';
import '../widgets/ui.dart';
import 'word_study_screen.dart';

enum WordFilter { all, learned, notLearned, favorite }

const _filterLabels = {
  WordFilter.all: 'Tất cả',
  WordFilter.learned: 'Đã học',
  WordFilter.notLearned: 'Chưa học',
  WordFilter.favorite: 'Yêu thích',
};

/// Danh sách từ vựng: tìm kiếm, lọc, đánh dấu yêu thích, chia theo bài/chủ đề.
/// Từ của một bài N4 chỉ hiện khi đã học xong ngữ pháp bài đó.
class VocabListScreen extends StatefulWidget {
  final WordBank bank;
  final ProgressStore progress;
  final Speaker speaker;

  const VocabListScreen({
    super.key,
    required this.bank,
    required this.progress,
    required this.speaker,
  });

  @override
  State<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends State<VocabListScreen> {
  // Mở sẵn N4 nếu đã có bài N4 mở từ vựng, chưa có thì mở N5.
  late String _level =
      widget.bank.groups.any((g) => g.level == 'N4' && !_locked(g))
      ? 'N4'
      : 'N5';
  String _query = '';
  WordFilter _filter = WordFilter.all;

  bool _matches(WordEntry w) {
    final p = widget.progress;
    final ok = switch (_filter) {
      WordFilter.all => true,
      WordFilter.learned => p.isWordLearned(w.key),
      WordFilter.notLearned => !p.isWordLearned(w.key),
      WordFilter.favorite => p.isFavorite(w.key),
    };
    if (!ok) return false;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return plainText(w.word).contains(q) ||
        w.kana.contains(q) ||
        w.meaningVi.toLowerCase().contains(q);
  }

  bool _locked(WordGroup g) {
    final lesson = g.lesson;
    return lesson != null && !widget.progress.isVocabUnlocked(lesson);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.progress,
      builder: (context, _) {
        final rows = <Widget>[];
        for (final g in widget.bank.groups.where((g) => g.level == _level)) {
          final locked = _locked(g);
          final words = locked
              ? <WordEntry>[]
              : g.words.where(_matches).toList();
          final filtering = _query.isNotEmpty || _filter != WordFilter.all;
          if (filtering && words.isEmpty) continue;
          rows.add(
            _GroupHeader(group: g, progress: widget.progress, locked: locked),
          );
          if (locked) {
            rows.add(
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Học xong phần Ngữ pháp của bài này để mở từ vựng.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            );
          }
          for (var i = 0; i < words.length; i++) {
            rows.add(
              _WordRow(
                number: g.words.indexOf(words[i]) + 1,
                word: words[i],
                progress: widget.progress,
                speaker: widget.speaker,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WordStudyScreen(
                      words: words,
                      initialIndex: i,
                      progress: widget.progress,
                      speaker: widget.speaker,
                      title: g.title,
                    ),
                  ),
                ),
              ),
            );
          }
        }
        if (rows.isEmpty) {
          rows.add(
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Không có từ nào phù hợp.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text('Từ vựng $_level')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('vocab-search'),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm từ...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SegmentedButton<String>(
                      key: const ValueKey('vocab-level'),
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 'N4', label: Text('N4')),
                        ButtonSegment(value: 'N5', label: Text('N5')),
                      ],
                      selected: {_level},
                      onSelectionChanged: (s) =>
                          setState(() => _level = s.first),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final f in WordFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          key: ValueKey('filter-${f.name}'),
                          label: Text(_filterLabels[f]!),
                          selected: _filter == f,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.border),
                          shape: const StadiumBorder(),
                          labelStyle: TextStyle(
                            color: _filter == f ? Colors.white : AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: rows,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final WordGroup group;
  final ProgressStore progress;
  final bool locked;

  const _GroupHeader({
    required this.group,
    required this.progress,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final total = group.words.length;
    final learned = progress.learnedCount(group.words.map((w) => w.key));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (locked) ...[
                  const Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    '${group.title} · $total từ',
                    key: ValueKey('group-${group.id}'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '$learned/$total',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (group.level == 'N4')
              Text(
                group.subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            const SizedBox(height: 8),
            RoundedProgress(value: total == 0 ? 0 : learned / total),
          ],
        ),
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  final int number;
  final WordEntry word;
  final ProgressStore progress;
  final Speaker speaker;
  final VoidCallback onTap;

  const _WordRow({
    required this.number,
    required this.word,
    required this.progress,
    required this.speaker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final favorite = progress.isFavorite(word.key);
    final learned = progress.isWordLearned(word.key);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AppCard(
        key: ValueKey('word-${word.key}'),
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        onTap: onTap,
        child: Row(
          children: [
            NumberBadge(number),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 6,
                    children: [
                      RubyText(
                        word.word,
                        showRuby: false,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        '(${word.kana})',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      if (learned)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.green,
                        ),
                    ],
                  ),
                  Text(
                    word.meaningVi,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            IconButton(
              key: ValueKey('listen-${word.audioId}'),
              tooltip: 'Nghe',
              icon: const Icon(
                Icons.volume_up_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => speaker.speak(
                lesson: word.audioLesson,
                audioId: word.audioId,
                text: word.kana,
              ),
            ),
            IconButton(
              key: ValueKey('fav-${word.key}'),
              tooltip: 'Yêu thích',
              icon: Icon(
                favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: favorite ? AppColors.orange : AppColors.muted,
              ),
              onPressed: () => progress.toggleFavorite(word.key),
            ),
          ],
        ),
      ),
    );
  }
}
