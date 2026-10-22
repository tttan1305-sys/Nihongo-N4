import 'package:flutter/material.dart';

import '../data/lesson_repository.dart';
import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../models/n5.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/ruby_text.dart';
import '../widgets/ui.dart';
import 'grammar_screen.dart';

/// Tab Ngữ pháp: các mẫu câu của bài N4 (có bài kiểm tra) và N5 bài 1–25.
class GrammarListScreen extends StatefulWidget {
  final List<Lesson> lessons;
  final N5Data n5;
  final ProgressStore progress;
  final Speaker speaker;

  const GrammarListScreen({
    super.key,
    required this.lessons,
    required this.n5,
    required this.progress,
    required this.speaker,
  });

  @override
  State<GrammarListScreen> createState() => _GrammarListScreenState();
}

class _GrammarListScreenState extends State<GrammarListScreen> {
  String _level = 'N4';

  void _open(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;
    return Scaffold(
      appBar: AppBar(title: Text('Ngữ pháp $_level')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                key: const ValueKey('grammar-level'),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'N4', label: Text('N4 · Bài 26–50')),
                  ButtonSegment(value: 'N5', label: Text('N5 · Bài 1–25')),
                ],
                selected: {_level},
                onSelectionChanged: (s) => setState(() => _level = s.first),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: p,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: _level == 'N4' ? _n4() : _n5(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _n4() {
    final p = widget.progress;
    return [
      for (final lesson in widget.lessons) ...[
        _LessonHeader(
          title: 'Bài ${lesson.number}',
          subtitle: lesson.titleVi,
          trailing:
              '${p.passedGrammarCount(lesson)}/${lesson.grammar.length} đã qua',
        ),
        if (!p.isLessonUnlocked(lesson.number, first: firstLesson))
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Hoàn thành bài trước để mở bài này.',
              style: TextStyle(color: AppColors.muted),
            ),
          )
        else
          for (var i = 0; i < lesson.grammar.length; i++)
            _PointTile(
              key: ValueKey('gtab-${lesson.number}-${lesson.grammar[i].id}'),
              number: i + 1,
              pattern: lesson.grammar[i].pattern,
              meaning: lesson.grammar[i].meaningVi,
              passed: p.isGrammarPassed(lesson.number, lesson.grammar[i].id),
              onTap: () => _open(
                GrammarScreen(
                  lessonNumber: lesson.number,
                  grammar: lesson.grammar[i],
                  progress: p,
                  speaker: widget.speaker,
                ),
              ),
            ),
      ],
      if (widget.lessons.length < lastLesson - firstLesson + 1)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Bài ${firstLesson + widget.lessons.length}–$lastLesson đang soạn nội dung.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
    ];
  }

  List<Widget> _n5() => [
    for (final lesson in widget.n5.grammar) ...[
      _LessonHeader(
        title: 'Bài ${lesson.lesson}',
        subtitle: lesson.titleVi,
        trailing: '${lesson.points.length} mẫu',
      ),
      for (var i = 0; i < lesson.points.length; i++)
        _PointTile(
          key: ValueKey('gtab-n5-${lesson.points[i].id}'),
          number: i + 1,
          pattern: lesson.points[i].pattern,
          meaning: lesson.points[i].meaningVi,
          onTap: () => _open(
            GrammarScreen.n5(
              point: lesson.points[i],
              progress: widget.progress,
              speaker: widget.speaker,
            ),
          ),
        ),
    ],
  ];
}

class _LessonHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _LessonHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          Pill(trailing, color: AppColors.purple),
        ],
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  final int number;
  final String pattern;
  final String meaning;
  final bool passed;
  final VoidCallback onTap;

  const _PointTile({
    super.key,
    required this.number,
    required this.pattern,
    required this.meaning,
    required this.onTap,
    this.passed = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      onTap: onTap,
      child: Row(
        children: [
          NumberBadge(number),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RubyText(
                  pattern,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(meaning, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          Icon(
            passed ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
            color: passed ? AppColors.green : AppColors.muted,
          ),
        ],
      ),
    );
  }
}
