import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../data/word_bank.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/ruby_text.dart';
import '../widgets/ui.dart';

/// Học từ vựng kiểu flashcard: mỗi lần một từ, nghĩa ẩn đến khi bấm
/// "Hiển thị nghĩa". "Đã nhớ" đánh dấu đã học, "Chưa nhớ" chỉ sang từ sau.
class WordStudyScreen extends StatefulWidget {
  final List<WordEntry> words;
  final int initialIndex;
  final ProgressStore progress;
  final Speaker speaker;
  final String title;

  const WordStudyScreen({
    super.key,
    required this.words,
    required this.progress,
    required this.speaker,
    this.initialIndex = 0,
    this.title = 'Học từ vựng',
  });

  @override
  State<WordStudyScreen> createState() => _WordStudyScreenState();
}

class _WordStudyScreenState extends State<WordStudyScreen> {
  late int _index = widget.initialIndex;
  bool _finished = false;
  bool _revealed = false;
  int _known = 0;

  WordEntry get _word => widget.words[_index];

  void _speak(WordEntry w) => widget.speaker.speak(
    lesson: w.audioLesson,
    audioId: w.audioId,
    text: w.kana,
  );

  Future<void> _answer({required bool known}) async {
    if (known) {
      await widget.progress.markWordLearned(_word.key);
      _known++;
    }
    setState(() {
      _revealed = false;
      if (_index + 1 < widget.words.length) {
        _index++;
      } else {
        _finished = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey('study-close'),
          tooltip: 'Đóng',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.title),
      ),
      body: _finished ? _done(context) : _card(context),
    );
  }

  Widget _done(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Bạn đã học xong ${widget.words.length} từ!',
              key: const ValueKey('study-done'),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Đã nhớ $_known từ. Vào Luyện tập để làm trắc nghiệm các từ vừa học.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Xong'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    final w = _word;
    final example = w.example;
    return ListenableBuilder(
      listenable: widget.progress,
      builder: (context, _) {
        final favorite = widget.progress.isFavorite(w.key);
        final showRuby = widget.progress.showFurigana;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: StepProgress(
                current: _index + 1,
                total: widget.words.length,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _Illustration(word: w),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: Column(
                            children: [
                              RubyText(
                                w.word,
                                showRuby: false,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '(${w.kana})',
                                key: const ValueKey('study-kana'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.muted,
                                ),
                              ),
                              if (_revealed && w.hanViet.isNotEmpty)
                                Text(
                                  w.hanViet.toUpperCase(),
                                  key: const ValueKey('study-hanviet'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.purple,
                                  ),
                                ),
                              const SizedBox(height: 10),
                              if (_revealed)
                                Text(
                                  w.meaningVi,
                                  key: const ValueKey('study-meaning'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                )
                              else
                                const Text(
                                  'Nhớ nghĩa rồi bấm Hiển thị nghĩa để kiểm tra',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.muted),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton.filled(
                                    key: ValueKey('listen-${w.audioId}'),
                                    iconSize: 28,
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.primarySoft,
                                      foregroundColor: AppColors.primary,
                                      fixedSize: const Size(56, 56),
                                    ),
                                    onPressed: () => _speak(w),
                                    icon: const Icon(Icons.volume_up_rounded),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    key: const ValueKey('study-favorite'),
                                    tooltip: 'Yêu thích',
                                    onPressed: () =>
                                        widget.progress.toggleFavorite(w.key),
                                    icon: Icon(
                                      favorite
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: favorite
                                          ? AppColors.orange
                                          : AppColors.muted,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Pill(w.level),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_revealed && example != null) ...[
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(
                            w.situationVi == null
                                ? 'Ví dụ'
                                : 'Dùng thực tế: ${w.situationVi}',
                            icon: Icons.chat_bubble_outline_rounded,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: RubyText(
                                  example.ja,
                                  showRuby: showRuby,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                key: ValueKey('listen-${example.id}'),
                                icon: const Icon(
                                  Icons.volume_up_rounded,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => widget.speaker.speak(
                                  lesson: w.audioLesson,
                                  audioId: example.id,
                                  text: plainText(example.ja),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            example.vi,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _AnswerButton(
                        key: const ValueKey('study-known'),
                        label: 'Đã nhớ',
                        icon: Icons.check_rounded,
                        color: AppColors.green,
                        onPressed: () => _answer(known: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _RevealButton(
                      revealed: _revealed,
                      onPressed: () => setState(() => _revealed = !_revealed),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AnswerButton(
                        key: const ValueKey('study-unknown'),
                        label: 'Chưa nhớ',
                        icon: Icons.close_rounded,
                        color: AppColors.red,
                        onPressed: () => _answer(known: false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _AnswerButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.7)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}

/// Nút tròn phát sáng ở giữa: hiện hoặc ẩn nghĩa của từ.
class _RevealButton extends StatelessWidget {
  final bool revealed;
  final VoidCallback onPressed;

  const _RevealButton({required this.revealed, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6FA2FF), AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.6),
            blurRadius: 22,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          key: const ValueKey('study-reveal'),
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                revealed
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.white,
              ),
              const SizedBox(height: 2),
              Text(
                revealed ? 'Ẩn nghĩa' : 'Hiển thị\nnghĩa',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Khung minh họa phía trên thẻ: nền màu nhạt với chữ Hán đầu tiên của từ
/// làm hình chìm, thay cho ảnh minh họa.
class _Illustration extends StatelessWidget {
  final WordEntry word;

  const _Illustration({required this.word});

  @override
  Widget build(BuildContext context) {
    final plain = plainText(word.word);
    final color =
        AppColors.cycle[word.key.hashCode.abs() % AppColors.cycle.length];
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            bottom: -18,
            child: Text(
              plain.isEmpty ? '' : plain.characters.first,
              style: TextStyle(
                fontSize: 110,
                fontWeight: FontWeight.w800,
                color: color.withValues(alpha: 0.16),
              ),
            ),
          ),
          const Positioned(
            left: 20,
            top: 18,
            child: Text('🌸', style: TextStyle(fontSize: 28)),
          ),
        ],
      ),
    );
  }
}
