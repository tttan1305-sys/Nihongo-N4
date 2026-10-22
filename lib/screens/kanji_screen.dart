import 'package:flutter/material.dart';

import '../data/n5_repository.dart';
import '../data/progress_store.dart';
import '../models/n5.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/ruby_text.dart';
import '../widgets/ui.dart';

/// Học Kanji N5: mỗi lần một chữ, có cách đọc, cách nhớ, ví dụ, bộ thủ, số nét.
/// Bấm "Đã nhớ" để đánh dấu và sang chữ sau.
class KanjiScreen extends StatefulWidget {
  final List<N5Kanji> kanji;
  final ProgressStore progress;
  final Speaker speaker;

  const KanjiScreen({
    super.key,
    required this.kanji,
    required this.progress,
    required this.speaker,
  });

  @override
  State<KanjiScreen> createState() => _KanjiScreenState();
}

class _KanjiScreenState extends State<KanjiScreen> {
  // Bắt đầu từ chữ đầu tiên chưa nhớ.
  late int _index = () {
    final i = widget.kanji.indexWhere(
      (k) => !widget.progress.isKanjiLearned(k.char),
    );
    return i < 0 ? 0 : i;
  }();

  N5Kanji get _k => widget.kanji[_index];

  Future<void> _learned() async {
    await widget.progress.markKanjiLearned(_k.char);
    if (_index + 1 < widget.kanji.length) setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final k = _k;
    return Scaffold(
      appBar: AppBar(title: const Text('Học Kanji')),
      body: ListenableBuilder(
        listenable: widget.progress,
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: StepProgress(
                current: _index + 1,
                total: widget.kanji.length,
                trailing: Text(
                  'Đã nhớ ${widget.kanji.where((k) => widget.progress.isKanjiLearned(k.char)).length}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          k.char,
                          key: const ValueKey('kanji-char'),
                          style: const TextStyle(
                            fontSize: 96,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          '(${k.reading})',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                '${k.hanViet} · ${k.meaningVi}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              key: ValueKey('listen-${k.id}'),
                              icon: const Icon(
                                Icons.volume_up_rounded,
                                color: AppColors.primary,
                              ),
                              onPressed: () => widget.speaker.speak(
                                lesson: n5AudioLesson,
                                audioId: k.id,
                                text: k.reading,
                              ),
                            ),
                            if (widget.progress.isKanjiLearned(k.char))
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.green,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            if (k.on.isNotEmpty)
                              Pill('On: ${k.on}', color: AppColors.purple),
                            if (k.kun.isNotEmpty)
                              Pill('Kun: ${k.kun}', color: AppColors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    color: AppColors.orangeSoft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel(
                          'Cách nhớ',
                          icon: Icons.lightbulb_outline_rounded,
                          color: AppColors.orange,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 26)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RubyText(
                                k.mnemonicVi,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel(
                          'Ví dụ',
                          icon: Icons.chat_bubble_outline_rounded,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RubyText(
                                    k.example.ja,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    k.example.vi,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: ValueKey('listen-${k.example.id}'),
                              icon: const Icon(
                                Icons.volume_up_rounded,
                                color: AppColors.primary,
                              ),
                              onPressed: () => widget.speaker.speak(
                                lesson: n5AudioLesson,
                                audioId: k.example.id,
                                text: readingText(k.example.ja),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Fact(
                          label: 'Bộ ${k.radical}',
                          value: k.radicalName,
                          note: k.radicalJa,
                          color: AppColors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Fact(
                          label: 'Số nét',
                          value: '${k.strokes}',
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Row(
                  children: [
                    CircleNavButton(
                      icon: Icons.chevron_left_rounded,
                      onPressed: _index == 0
                          ? null
                          : () => setState(() => _index--),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('kanji-learned'),
                        onPressed: _learned,
                        child: const Text('Đã nhớ, tiếp theo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleNavButton(
                      icon: Icons.chevron_right_rounded,
                      onPressed: _index + 1 >= widget.kanji.length
                          ? null
                          : () => setState(() => _index++),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  final Color color;

  const _Fact({
    required this.label,
    required this.value,
    required this.color,
    this.note = '',
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (note.isNotEmpty)
            Text(
              note,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
