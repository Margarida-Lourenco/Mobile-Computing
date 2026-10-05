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
      padding: const EdgeInsets.only(top: 14, bottom: 2),
      child: Row(
        children: ['All', 'Today', 'Outdoors', 'Social', 'Food']
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  selected: selected == category,
                  onSelected: (_) => onSelected(category),
                  selectedColor: AppColors.navy,
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Color(0xFFCDDfea)),
                  labelStyle: TextStyle(
                    color: selected == category
                        ? Colors.white
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
