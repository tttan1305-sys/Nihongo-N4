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
    final p = SkinPalette.current;
    final mech = p.skin == AppSkin.mechanical;
    final anime = p.skin == AppSkin.anime;
    final radius = BorderRadius.circular(mech ? 4 : 16);
    final idleBorder = anime ? 2.0 : 1.0;
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: state == OptionState.idle ? AppColors.border : color,
          width: state == OptionState.idle ? idleBorder : idleBorder + 0.8,
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
                  shape: mech ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: mech ? BorderRadius.circular(3) : null,
                  border: anime
                      ? Border.all(color: AppColors.border, width: 2)
                      : null,
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontFamily: mech ? 'JetBrainsMono' : null,
                    fontWeight: FontWeight.w700,
                    color: state == OptionState.idle
                        ? AppColors.primaryText
                        : p.skin == AppSkin.neon
                        ? Colors.white
                        : p.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RubyText(
                  text,
                  style: TextStyle(fontSize: 17, color: AppColors.text),
                ),
              ),
              if (anime && state == OptionState.selected)
                Icon(Icons.play_arrow_rounded, color: AppColors.primary),
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
