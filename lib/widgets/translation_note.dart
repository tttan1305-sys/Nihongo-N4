import 'package:flutter/material.dart';

import '../theme.dart';
import 'ruby_text.dart';

/// Phần "Dịch nghĩa" đặt sau mỗi lời giải thích: câu tiếng Nhật (nếu có)
/// và nghĩa tiếng Việt của câu.
class TranslationNote extends StatelessWidget {
  final String vi;
  final String? ja;
  final String title;

  const TranslationNote(
    this.vi, {
    super.key,
    this.ja,
    this.title = 'Dịch nghĩa',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('translation-note'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.greenSoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, size: 18, color: AppColors.green),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (ja != null && ja!.isNotEmpty)
            RubyText(ja!, style: const TextStyle(fontSize: 17)),
          Text(
            vi,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              height: 1.35,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
