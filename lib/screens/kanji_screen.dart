import 'package:flutter/material.dart';

import '../data/n5_repository.dart';
import '../data/progress_store.dart';
import '../models/n5.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/content_scale.dart';
import '../widgets/kanji_canvas.dart';
import '../widgets/ruby_text.dart';
import '../widgets/ui.dart';

/// Học Kanji N5: mỗi lần một chữ, tập viết tay trên chữ mẫu hoặc xem cách đọc,
/// bộ thủ, số nét; có mẹo ghi nhớ và ví dụ. Bấm "Đã nhớ" để sang chữ sau.
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

  bool _writing = true;

  N5Kanji get _k => widget.kanji[_index];

  Future<void> _learned() async {
    await widget.progress.markKanjiLearned(_k.char);
    if (_index + 1 < widget.kanji.length) setState(() => _index++);
  }

  void _showExample(BuildContext context) {
    final k = _k;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                          key: const ValueKey('kanji-example-ja'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          k.example.vi,
                          style: const TextStyle(color: AppColors.muted),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = _k;
    return Scaffold(
      appBar: AppBar(title: const Text('Kanji')),
      body: ContentScale(
        child: ListenableBuilder(
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
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
                      child: Row(
                        children: [
                          Text(
                            k.char,
                            key: const ValueKey('kanji-char'),
                            style: const TextStyle(
                              fontSize: 56,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '(${k.reading})',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  '${k.hanViet} · ${k.meaningVi}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.progress.isKanjiLearned(k.char))
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.green,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ModeTabs(
                      writing: _writing,
                      onChanged: (v) => setState(() => _writing = v),
                    ),
                    const SizedBox(height: 14),
                    if (_writing)
                      KanjiCanvas(char: k.char)
                    else
                      _lookAndRemember(k),
                    const SizedBox(height: 14),
                    AppCard(
                      borderColor: AppColors.orange,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel(
                            'Ghi nhớ',
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
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Row(
                    children: [
                      CircleNavButton(
                        icon: Icons.chevron_left_rounded,
                        onPressed: _index == 0
                            ? null
                            : () => setState(() => _index--),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          key: const ValueKey('kanji-example'),
                          onPressed: () => _showExample(context),
                          child: const Text('Xem ví dụ'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          key: const ValueKey('kanji-learned'),
                          onPressed: _learned,
                          child: const Text('Đã nhớ'),
                        ),
                      ),
                      const SizedBox(width: 8),
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
      ),
    );
  }

  Widget _lookAndRemember(N5Kanji k) {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(
                k.char,
                style: const TextStyle(
                  fontSize: 110,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  shadows: [Shadow(color: AppColors.primary, blurRadius: 18)],
                ),
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
    );
  }
}

/// Hai thẻ chuyển giữa "Viết tay" và "Nhìn & Nhớ".
class _ModeTabs extends StatelessWidget {
  final bool writing;
  final ValueChanged<bool> onChanged;

  const _ModeTabs({required this.writing, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget tab(String key, String label, IconData icon, bool value) {
      final selected = writing == value;
      return Expanded(
        child: InkWell(
          key: ValueKey(key),
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return NormalTextScale(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            tab('kanji-tab-write', 'Viết tay', Icons.edit_rounded, true),
            tab(
              'kanji-tab-look',
              'Nhìn & Nhớ',
              Icons.visibility_rounded,
              false,
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
