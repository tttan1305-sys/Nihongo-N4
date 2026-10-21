import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../models/n5.dart';
import '../widgets/ruby_text.dart';

const _letters = ['A', 'B', 'C', 'D'];

/// Làm một đề test N5: chọn đáp án từng câu, không hiện đúng sai cho đến khi
/// nộp bài. Nộp xong hiện điểm, đáp án và giải thích chi tiết từng câu.
class N5TestScreen extends StatefulWidget {
  final N5Test test;
  final ProgressStore progress;

  const N5TestScreen({super.key, required this.test, required this.progress});

  @override
  State<N5TestScreen> createState() => _N5TestScreenState();
}

class _N5TestScreenState extends State<N5TestScreen> {
  late List<int?> _picked;
  int _index = 0;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _picked = List.filled(widget.test.questions.length, null);
  }

  int get _answered => _picked.where((p) => p != null).length;

  int get _correct => [
    for (var i = 0; i < _picked.length; i++)
      if (_picked[i] == widget.test.questions[i].answer) i,
  ].length;

  Future<void> _submit() async {
    final missing = _picked.length - _answered;
    if (missing > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nộp bài?'),
          content: Text('Bạn còn $missing câu chưa trả lời.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Làm tiếp'),
            ),
            FilledButton(
              key: const ValueKey('confirm-submit'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Nộp bài'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await widget.progress.saveN5TestScore(
      widget.test.id,
      _correct / _picked.length,
    );
    setState(() => _submitted = true);
  }

  void _restart() => setState(() {
    _picked = List.filled(widget.test.questions.length, null);
    _index = 0;
    _submitted = false;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _submitted
              ? '${widget.test.titleVi}: kết quả'
              : '${widget.test.titleVi}  (${_index + 1}/${_picked.length})',
        ),
      ),
      body: _submitted ? _results(context) : _question(context),
    );
  }

  Widget _question(BuildContext context) {
    final q = widget.test.questions[_index];
    final passage = q.passageId == null
        ? null
        : widget.test.passages[q.passageId];
    final last = _index == _picked.length - 1;
    return Column(
      children: [
        LinearProgressIndicator(value: _answered / _picked.length),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Câu ${_index + 1} · ${q.section}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              if (passage != null) _Passage(passage),
              _Prompt(q),
              const SizedBox(height: 16),
              for (var i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _Option(
                    key: ValueKey('option-$i'),
                    letter: _letters[i],
                    text: q.options[i],
                    selected: _picked[_index] == i,
                    onTap: () => setState(() => _picked[_index] = i),
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _index == 0
                      ? null
                      : () => setState(() => _index--),
                  child: const Text('Câu trước'),
                ),
                const Spacer(),
                if (last)
                  FilledButton(
                    key: const ValueKey('submit-test'),
                    onPressed: _submit,
                    child: Text('Nộp bài ($_answered/${_picked.length})'),
                  )
                else
                  FilledButton(
                    key: const ValueKey('next-question'),
                    onPressed: () => setState(() => _index++),
                    child: const Text('Câu sau'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _results(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final questions = widget.test.questions;
    final score = _correct / questions.length;
    final sections = <String, (int, int)>{};
    for (var i = 0; i < questions.length; i++) {
      final (right, total) = sections[questions[i].section] ?? (0, 0);
      sections[questions[i].section] = (
        right + (_picked[i] == questions[i].answer ? 1 : 0),
        total + 1,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đúng $_correct/${questions.length} câu (${(score * 100).round()}%)',
                  key: const ValueKey('test-score'),
                  style: text.headlineSmall,
                ),
                Text(
                  score >= ProgressStore.passMark
                      ? 'Rất tốt! Bạn đã nắm chắc phần này.'
                      : score >= 0.6
                      ? 'Khá rồi. Xem lại giải thích các câu sai bên dưới.'
                      : 'Hãy ôn lại phần Kiến thức cần nhớ rồi làm lại nhé.',
                ),
                const SizedBox(height: 8),
                for (final e in sections.entries)
                  Text('${e.key}: ${e.value.$1}/${e.value.$2}'),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const ValueKey('retry-test'),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm lại đề này'),
                  onPressed: _restart,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Đáp án và giải thích', style: text.titleMedium),
        for (var i = 0; i < questions.length; i++)
          _Review(
            key: ValueKey('review-${questions[i].id}'),
            number: i + 1,
            question: questions[i],
            passage: questions[i].passageId == null
                ? null
                : widget.test.passages[questions[i].passageId],
            picked: _picked[i],
          ),
      ],
    );
  }
}

class _Passage extends StatelessWidget {
  final String text;

  const _Passage(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RubyText(text, style: const TextStyle(fontSize: 17)),
    );
  }
}

class _Prompt extends StatelessWidget {
  final TestQuestion question;

  const _Prompt(this.question);

  @override
  Widget build(BuildContext context) {
    final hint = switch (question.type) {
      'reading' => 'Chọn cách đọc của từ trong 【】',
      'writing' => 'Chọn chữ Hán của từ trong 【】',
      'order' => 'Chọn từ đặt vào ô ★',
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null)
          Text(hint, style: Theme.of(context).textTheme.bodySmall),
        RubyText(question.prompt, style: const TextStyle(fontSize: 20)),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  const _Option({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color ?? (selected ? scheme.primaryContainer : null),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? scheme.primary : scheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text('$letter.  ', style: const TextStyle(fontSize: 16)),
              Expanded(
                child: RubyText(text, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Một câu sau khi nộp: đáp án đã chọn, đáp án đúng, giải thích.
class _Review extends StatelessWidget {
  final int number;
  final TestQuestion question;
  final String? passage;
  final int? picked;

  const _Review({
    super.key,
    required this.number,
    required this.question,
    required this.passage,
    required this.picked,
  });

  @override
  Widget build(BuildContext context) {
    final right = picked == question.answer;
    final text = Theme.of(context).textTheme;
    const green = Color(0xFFDDF2DD);
    const red = Color(0xFFF8D7D7);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        initiallyExpanded: !right,
        leading: Icon(
          right ? Icons.check_circle : Icons.cancel,
          color: right ? Colors.green : Colors.red,
        ),
        title: Text('Câu $number · ${question.section}'),
        subtitle: Text(
          picked == null
              ? 'Chưa trả lời · Đáp án ${_letters[question.answer]}'
              : right
              ? 'Đúng (${_letters[question.answer]})'
              : 'Bạn chọn ${_letters[picked!]} · Đáp án ${_letters[question.answer]}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (passage != null) _Passage(passage!),
          _Prompt(question),
          const SizedBox(height: 8),
          for (var i = 0; i < question.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _Option(
                letter: _letters[i],
                text: question.options[i],
                selected: i == picked,
                color: i == question.answer
                    ? green
                    : i == picked
                    ? red
                    : null,
              ),
            ),
          const SizedBox(height: 4),
          Text('Giải thích', style: text.titleSmall),
          RubyText(question.explanationVi),
        ],
      ),
    );
  }
}
