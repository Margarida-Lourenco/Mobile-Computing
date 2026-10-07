import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final bool isMyPage;
  final String area;
  final String firstName;
  final VoidCallback onArea;

  const AppHeader({
    super.key,
    required this.isMyPage,
    required this.area,
    required this.firstName,
    required this.onArea,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Göod Together',
                style: AppTextStyles.captionAccentBold,
              ),
              Text(
                isMyPage ? 'My Page' : 'Hej, $firstName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.greeting,
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onArea,
          borderRadius: BorderRadius.circular(AppRadii.r15),
          child: Container(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s9, vertical: AppSpacing.s7),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadii.r15),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: AppIconSizes.s17,
                  color: AppColors.darkBlue,
                ),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your area',
                      style: AppTextStyles.captionMuted,
                    ),
                    Text(
                      area,
                      style: AppTextStyles.captionBold,
                    ),
                  ],
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: AppIconSizes.s16,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
