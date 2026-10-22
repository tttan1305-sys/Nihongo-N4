import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../data/word_bank.dart';
import '../theme.dart';
import 'ui.dart';

/// Thẻ mục tiêu: số từ vựng đã học trên tổng số từ của ứng dụng.
class GoalCard extends StatelessWidget {
  final WordBank? bank;
  final ProgressStore progress;
  final String title;

  const GoalCard({
    super.key,
    required this.bank,
    required this.progress,
    this.title = 'JLPT N4 · Từ vựng',
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final total = bank?.total ?? 0;
        final learned = bank == null
            ? 0
            : progress.learnedCount(bank!.all.map((w) => w.key));
        final ratio = total == 0 ? 0.0 : learned / total;
        return AppCard(
          key: const ValueKey('goal-card'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IconTile(
                    Icons.emoji_events_rounded,
                    color: AppColors.orange,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          bank == null ? 'Đang tải...' : '$learned/$total từ',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(ratio * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RoundedProgress(value: ratio, height: 10),
            ],
          ),
        );
      },
    );
  }
}
