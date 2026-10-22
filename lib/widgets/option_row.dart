import 'package:flutter/material.dart';

import '../theme.dart';
import 'ruby_text.dart';

/// Trạng thái một đáp án: chưa chọn, đang chọn (chưa chấm), đúng, sai.
enum OptionState { idle, selected, right, wrong }

/// Một dòng đáp án A–D, đổi màu xanh/đỏ sau khi chấm.
class OptionRow extends StatelessWidget {
  final String letter;
  final String text;
  final OptionState state;
  final VoidCallback onTap;

  const OptionRow({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (state) {
      OptionState.right => (AppColors.green, AppColors.greenSoft),
      OptionState.wrong => (AppColors.red, AppColors.redSoft),
      OptionState.idle => (AppColors.primary, AppColors.surface),
      OptionState.selected => (AppColors.primary, AppColors.primarySoft),
    };
    final radius = BorderRadius.circular(16);
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: state == OptionState.idle ? AppColors.border : color,
          width: state == OptionState.idle ? 1 : 1.6,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: state == OptionState.idle
                      ? AppColors.primarySoft
                      : color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: state == OptionState.idle
                        ? AppColors.primary
                        : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RubyText(
                  text,
                  style: const TextStyle(fontSize: 17, color: AppColors.text),
                ),
              ),
              if (state == OptionState.right || state == OptionState.wrong)
                Icon(
                  state == OptionState.right
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
