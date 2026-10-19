import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/opportunity_filters.dart';

class CategoryChips extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onSelected;
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: 14, bottom: 2),
        child: Row(
          children: OpportunityFilters.labels
              .map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: selected.contains(category),
                    onSelected: (_) => onSelected(category),
                    showCheckmark: true,
                    checkmarkColor: AppColors.navy,
                    selectedColor: AppColors.paleGreen,
                    backgroundColor: AppColors.background,
                    labelStyle: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: selected.contains(category)
                          ? AppColors.paleGreen
                          : AppColors.chipBorder,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
}
