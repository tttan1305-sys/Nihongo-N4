import 'package:flutter/material.dart';

import '../data/n5_repository.dart';
import '../data/progress_store.dart';
import '../models/n5.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/content_scale.dart';
import '../widgets/listen_button.dart';
import '../widgets/option_row.dart';
import '../widgets/ruby_text.dart';
import '../widgets/ui.dart';

const _letters = ['A', 'B', 'C', 'D'];

/// Làm một bài kiểm tra Các thể & Ngữ pháp N5. Chọn xong mỗi câu là hiện
/// ngay câu đúng, nghĩa của câu, phân tích, lý do từng đáp án sai và mẹo nhớ.
class N5CheckScreen extends StatefulWidget {
  final N5CheckSet set;
  final ProgressStore progress;
  final Speaker speaker;

  const N5CheckScreen({
    super.key,
    required this.set,
    required this.progress,
    required this.speaker,
  });

  @override
  State<N5CheckScreen> createState() => _N5CheckScreenState();
}

class _N5CheckScreenState extends State<N5CheckScreen> {
  /// Các câu của lượt đang làm: cả bài, hoặc chỉ những câu sai lượt trước.
  late List<N5CheckQuestion> _round = widget.set.questions;
  final _picked = <String, int>{};
  int _index = 0;
  bool _finished = false;
  final _scroll = ScrollController();

  bool get _fullRound => _round.length == widget.set.questions.length;

  List<N5CheckQuestion> get _wrong => [
    for (final q in _round)
      if (_picked[q.id] != q.answer) q,
  ];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < _round.length - 1) {
      setState(() => _index++);
      if (_scroll.hasClients) _scroll.jumpTo(0);
      return;
    }
    if (_fullRound) {
      await widget.progress.saveN5TestScore(
        widget.set.id,
        (_round.length - _wrong.length) / _round.length,
      );
    }
    setState(() => _finished = true);
  }

  void _start(List<N5CheckQuestion> questions) => setState(() {
    for (final q in questions) {
      _picked.remove(q.id);
    }
    _round = questions;
    _index = 0;
    _finished = false;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _finished
              ? '${widget.set.titleVi}: kết quả'
              : '${widget.set.titleVi}  (${_index + 1}/${_round.length})',
        ),
      ),
      body: ContentScale(child: _finished ? _results() : _question()),
    );
  }

  Widget _question() {
    final q = _round[_index];
    final picked = _picked[q.id];
    final done = picked != null;
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_index + (done ? 1 : 0)) / _round.length,
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final c in q.coversVi) _CoverPill(c)],
              ),
              const SizedBox(height: 12),
              RubyText(q.prompt, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              for (var i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OptionRow(
                    key: ValueKey('check-option-$i'),
                    letter: _letters[i],
                    text: q.options[i],
                    state: !done
                        ? OptionState.idle
                        : i == q.answer
                        ? OptionState.right
                        : i == picked
                        ? OptionState.wrong
                        : OptionState.idle,
                    onTap: () {
                      if (!done) setState(() => _picked[q.id] = i);
                    },
                  ),
                ),
              if (done)
                _Explanation(
                  key: ValueKey('check-explain-${q.id}'),
                  question: q,
                  picked: picked,
                  speaker: widget.speaker,
                ),
            ],
          ),
        ),
        if (done)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('check-next'),
                  onPressed: _next,
                  child: Text(
                    _index < _round.length - 1
                        ? 'Câu tiếp theo'
                        : 'Xem kết quả',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _results() {
    final text = Theme.of(context).textTheme;
    final wrong = _wrong;
    final right = _round.length - wrong.length;
    final score = right / _round.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đúng $right/${_round.length} câu (${(score * 100).round()}%)',
                key: const ValueKey('check-score'),
                style: text.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                wrong.isEmpty
                    ? 'Tuyệt vời! Bạn đã nắm chắc phần này.'
                    : score >= ProgressStore.passMark
                    ? 'Rất tốt. Xem lại các câu sai bên dưới rồi làm lại cho chắc.'
                    : 'Đọc kỹ phân tích các câu sai, rồi làm lại những câu đó nhé.',
              ),
              if (!_fullRound)
                Text(
                  'Lượt này chỉ làm lại câu sai nên không tính vào điểm cao nhất.',
                  style: text.bodySmall,
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (wrong.isNotEmpty)
                    FilledButton.icon(
                      key: const ValueKey('check-retry-wrong'),
                      icon: const Icon(Icons.replay),
                      label: Text('Làm lại ${wrong.length} câu sai'),
                      onPressed: () => _start(wrong),
                    ),
                  OutlinedButton.icon(
                    key: const ValueKey('check-retry-all'),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm lại cả bài'),
                    onPressed: () => _start(widget.set.questions),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (wrong.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Các câu sai', style: text.titleMedium),
          for (final q in wrong)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ExpansionTile(
                key: ValueKey('check-review-${q.id}'),
                leading: Icon(Icons.cancel, color: AppColors.red),
                title: RubyText(q.fullJa, style: const TextStyle(fontSize: 16)),
                subtitle: Text(q.coversVi.join(' · ')),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  _Explanation(
                    question: q,
                    picked: _picked[q.id],
                    speaker: widget.speaker,
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _CoverPill extends StatelessWidget {
  final String text;

  const _CoverPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: RubyText(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

/// Phần giải thích sau khi chọn: đúng/sai, câu đúng và nghĩa, phân tích,
/// vì sao các đáp án khác sai, mẹo nhớ.
class _Explanation extends StatelessWidget {
  final N5CheckQuestion question;
  final int? picked;
  final Speaker speaker;

  const _Explanation({
    super.key,
    required this.question,
    required this.picked,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    final q = question;
    final right = picked == q.answer;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              right ? Icons.check_circle : Icons.cancel,
              color: right ? AppColors.green : AppColors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                right
                    ? 'Chính xác!'
                    : picked == null
                    ? 'Đáp án đúng là ${_letters[q.answer]}'
                    : 'Chưa đúng. Đáp án đúng là ${_letters[q.answer]}',
                key: const ValueKey('check-verdict'),
                style: text.titleMedium?.copyWith(
                  color: right ? AppColors.green : AppColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _Block(
          icon: Icons.task_alt,
          color: AppColors.green,
          title: 'Câu đúng',
          trailing: ListenButton(
            speaker: speaker,
            lesson: n5AudioLesson,
            audioId: q.id,
            text: readingText(q.fullJa),
          ),
          children: [RubyText(q.fullJa, style: const TextStyle(fontSize: 19))],
        ),
        _Block(
          icon: Icons.manage_search,
          color: AppColors.primary,
          title: 'Phân tích',
          children: [RubyText(q.explainVi)],
        ),
        _Block(
          icon: Icons.rule,
          color: AppColors.red,
          title: 'Vì sao các đáp án khác sai',
          children: [
            for (var i = 0; i < q.options.length; i++)
              if (i != q.answer)
                _WrongReason(
                  key: ValueKey('check-wrong-$i'),
                  letter: _letters[i],
                  option: q.options[i],
                  reason: q.wrongVi[i],
                  picked: i == picked,
                ),
          ],
        ),
        if (q.tipVi.isNotEmpty)
          _Block(
            icon: Icons.lightbulb,
            color: AppColors.orange,
            title: 'Mẹo nhớ',
            children: [RubyText(q.tipVi)],
          ),
        // Dịch nghĩa luôn đứng sau cùng, sau mọi lời giải thích.
        _Block(
          key: const ValueKey('check-translation'),
          icon: Icons.translate,
          color: AppColors.green,
          title: 'Dịch nghĩa',
          children: [
            RubyText(q.fullJa, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 4),
            Text(
              q.meaningVi,
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const _Block({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 15,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _WrongReason extends StatelessWidget {
  final String letter;
  final String option;
  final String reason;
  final bool picked;

  const _WrongReason({
    super.key,
    required this.letter,
    required this.option,
    required this.reason,
    required this.picked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: picked ? AppColors.redSoft : null,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: picked ? AppColors.red : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$letter.  ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Expanded(
                child: RubyText(option, style: const TextStyle(fontSize: 17)),
              ),
              if (picked)
                Text(
                  'Bạn chọn',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          RubyText(reason),
        ],
      ),
    );
  }
}
