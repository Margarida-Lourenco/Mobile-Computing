import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'icon_box.dart';

class EmptyState extends StatelessWidget {
  final String text;

  const EmptyState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s28),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.sheetHandle),
        borderRadius: BorderRadius.circular(AppRadii.r18),
      ),
      child: Column(
        children: [
          const Icon(Icons.eco_outlined, color: AppColors.darkBlue),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.captionMuted,
          ),
        ],
      ),
    );
  }
}

class EmptyAction extends StatelessWidget {
  final String title;
  final String body;
  final String action;
  final VoidCallback onPressed;

  const EmptyAction({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s25),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.r18),
      ),
      child: Column(
        children: [
          const IconBox(icon: Icons.add, color: AppColors.green),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.bodyBold),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTextStyles.captionMuted,
          ),
          const SizedBox(height: 13),
          FilledButton(onPressed: onPressed, child: Text(action)),
        ],
      ),
    );
  }
}
