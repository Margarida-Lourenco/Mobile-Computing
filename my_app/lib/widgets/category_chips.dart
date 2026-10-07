import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.only(top: AppSpacing.s14, bottom: AppSpacing.s2),
      child: Row(
        children: ['All', 'Today', 'Outdoors', 'Social', 'Food']
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s8),
                child: ChoiceChip(
                  label: Text(
                    category,
                    style: TextStyle(
                      fontSize: AppFonts.caption,
                      fontWeight: AppFonts.medium,
                      color: selected == category
                          ? AppColors.white
                          : AppColors.navy,
                    ),
                  ),
                  selected: selected == category,
                  onSelected: (_) => onSelected(category),
                  selectedColor: AppColors.navy,
                  backgroundColor: AppColors.transparent,
                  side: const BorderSide(color: AppColors.chipBorder),
                  labelStyle: TextStyle(
                    color: selected == category
                        ? AppColors.white
                        : AppColors.muted,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
