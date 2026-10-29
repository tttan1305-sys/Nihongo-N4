import 'dart:math';

import 'package:flutter/material.dart';

import '../data/word_bank.dart';
import '../theme.dart';
import '../widgets/content_scale.dart';
import '../widgets/ruby_text.dart';
import '../widgets/translation_note.dart';
import '../widgets/ui.dart';

/// Luyện tập câu: chạm các cụm từ theo đúng thứ tự để tạo thành câu.
class SentenceOrderScreen extends StatefulWidget {
  final List<OrderItem> items;
  final Random? random;

  const SentenceOrderScreen({super.key, required this.items, this.random});

  @override
  State<SentenceOrderScreen> createState() => _SentenceOrderScreenState();
}

class _SentenceOrderScreenState extends State<SentenceOrderScreen> {
  late final Random _rnd = widget.random ?? Random();
  int _index = 0;
  int _correct = 0;

  /// Thứ tự cụm từ đã xáo của câu hiện tại (chỉ số trong item.chunks).
  late List<int> _bank;

  /// Các cụm người dùng đã chọn, theo thứ tự chọn.
  final List<int> _chosen = [];
  bool? _result;

  OrderItem get _item => widget.items[_index];

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    final n = _item.chunks.length;
    _bank = List.generate(n, (i) => i);
    // Xáo đến khi khác thứ tự đúng.
    do {
      _bank.shuffle(_rnd);
    } while (_bank.join(',') == List.generate(n, (i) => i).join(','));
    _chosen.clear();
    _result = null;
  }

  void _check() {
    final answer = _chosen.map((i) => _item.chunks[i]).join();
    final right = answer == _item.sentence;
    setState(() {
      _result = right;
      if (right) _correct++;
    });
  }

  void _next() => setState(() {
    _index++;
    if (_index < widget.items.length) _shuffle();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập câu')),
      body: ContentScale(
        child: _index >= widget.items.length ? _done(context) : _question(),
      ),
    );
  }

  Widget _done(BuildContext context) {
    final total = widget.items.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Đúng $_correct/$total câu',
              key: const ValueKey('order-score'),
              style: Theme.of(context).textTheme.headlineSmall,
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

  Widget _question() {
    final item = _item;
    final remaining = _bank.where((i) => !_chosen.contains(i)).toList();
    final checked = _result != null;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: StepProgress(current: _index + 1, total: widget.items.length),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [
              Text(
                'Sắp xếp các từ để tạo thành câu đúng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(item.vi, style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 16),
              // Ô trả lời: cụm đã chọn, chạm để bỏ ra.
              AppCard(
                padding: const EdgeInsets.all(14),
                color: checked
                    ? (_result! ? AppColors.greenSoft : AppColors.redSoft)
                    : AppColors.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 90),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      for (var k = 0; k < item.chunks.length; k++)
                        k < _chosen.length
                            ? _Chunk(
                                key: ValueKey('chosen-$k'),
                                text: item.chunks[_chosen[k]],
                                selected: true,
                                onTap: checked
                                    ? null
                                    : () => setState(() => _chosen.removeAt(k)),
                              )
                            : const _EmptySlot(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final i in remaining)
                    _Chunk(
                      key: ValueKey('chunk-$i'),
                      text: item.chunks[i],
                      onTap: checked
                          ? null
                          : () => setState(() => _chosen.add(i)),
                    ),
                ],
              ),
              if (checked) ...[
                const SizedBox(height: 20),
                Text(
                  _result! ? 'Chính xác!' : 'Chưa đúng. Câu đúng là:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _result! ? AppColors.green : AppColors.red,
                  ),
                ),
                if (!_result!)
                  RubyText(
                    item.chunks.join('　'),
                    style: const TextStyle(fontSize: 18),
                  ),
                TranslationNote(item.vi),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: checked
                  ? FilledButton(
                      key: const ValueKey('order-next'),
                      onPressed: _next,
                      child: const Text('Tiếp tục'),
                    )
                  : FilledButton(
                      key: const ValueKey('order-check'),
                      onPressed: _chosen.length == item.chunks.length
                          ? _check
                          : null,
                      child: const Text('Kiểm tra'),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chunk extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  const _Chunk({
    super.key,
    required this.text,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: RubyText(
            text,
            style: TextStyle(fontSize: 18, color: AppColors.text),
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
        color: AppColors.background,
      ),
    );
  }
}
