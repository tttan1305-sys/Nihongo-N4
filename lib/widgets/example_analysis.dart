import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../theme.dart';
import 'ruby_text.dart';
import 'translation_note.dart';

/// Nút "Phân tích" dưới câu ví dụ: bấm để xem từng cụm, cách chia thể và
/// lưu ý của câu.
class ExampleAnalysis extends StatefulWidget {
  final Analysis analysis;
  final String id;

  /// Nghĩa tiếng Việt của câu, hiện cuối phần phân tích.
  final String? vi;

  const ExampleAnalysis({
    super.key,
    required this.analysis,
    required this.id,
    this.vi,
  });

  @override
  State<ExampleAnalysis> createState() => _ExampleAnalysisState();
}

class _ExampleAnalysisState extends State<ExampleAnalysis> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          key: ValueKey('analysis-${widget.id}'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(0, 34),
            foregroundColor: AppColors.purple,
          ),
          onPressed: () => setState(() => _open = !_open),
          icon: Icon(
            _open ? Icons.expand_less_rounded : Icons.manage_search_rounded,
            size: 20,
          ),
          label: Text(_open ? 'Ẩn phân tích' : 'Phân tích'),
        ),
        if (_open)
          Container(
            key: ValueKey('analysis-body-${widget.id}'),
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purpleSoft.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in a.parts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 118,
                          child: RubyText(
                            p.ja,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RubyText(
                            p.vi,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (a.steps.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 6),
                    child: Text(
                      'Cách chia',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  for (final s in a.steps)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 6, right: 8),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: RubyText(
                              s,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                if (a.note.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.orangeSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RubyText(
                      'Lưu ý: ${a.note}',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                if (widget.vi case final vi? when vi.isNotEmpty)
                  TranslationNote(vi),
              ],
            ),
          ),
      ],
    );
  }
}
