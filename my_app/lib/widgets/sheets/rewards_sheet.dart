import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/reward_progress.dart';
import '../app_sheet.dart';
import '../icon_box.dart';
import '../small_kicker.dart';

class RewardsSheet extends StatelessWidget {
  final RewardProgress rewards;
  const RewardsSheet({super.key, this.rewards = const RewardProgress()});

  @override
  Widget build(BuildContext context) {
    final badges = [
      [
        'First Step',
        'Completed your first activity',
        AppIcons.badge,
        rewards.completed >= 1,
      ],
      [
        'Helping Hand',
        'Shared 3 hours of your time',
        Icons.favorite,
        rewards.hours >= 3,
      ],
      [
        'Team Player',
        'Completed 3 activities',
        Icons.people_outline,
        rewards.completed >= 3,
      ],
      [
        'Local Hero',
        'Complete 5 local activities',
        Icons.location_on_outlined,
        rewards.completed >= 5,
      ],
    ];

    return AppSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBox(icon: AppIcons.badge, color: AppColors.green),
          const SizedBox(height: 12),
          const SmallKicker('YOUR KINDNESS COLLECTION'),
          const Text('Badges of good', style: AppTextStyles.sheetTitle),
          const Text(
            'Completed shifts and hours shared earn your next level.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 20),
          Text(
            'Level ${rewards.level} · ${rewards.title}',
            style: AppTextStyles.bodyBold,
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadii.r10)),
            child: LinearProgressIndicator(
              value: rewards.progress,
              minHeight: 7,
              backgroundColor: AppColors.paleBlue,
              valueColor: const AlwaysStoppedAnimation(AppColors.darkBlue),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${rewards.completed} completed shifts · ${rewards.remaining} more until level ${rewards.level + 1}',
            style: AppTextStyles.captionMuted,
          ),
          const SizedBox(height: 22),
          ...badges.map(
            (badge) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s12),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s13),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadii.r17),
                ),
                child: Row(
                  children: [
                    IconBox(
                      icon: badge[2] as IconData,
                      color: (badge[3] as bool)
                          ? AppColors.paleGreen
                          : AppColors.paleBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge[0] as String,
                            style: AppTextStyles.bodyBold,
                          ),
                          Text(
                            badge[1] as String,
                            style: AppTextStyles.captionMuted,
                          ),
                        ],
                      ),
                    ),
                    if (badge[3] as bool)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.darkBlue,
                        size: AppIconSizes.s19,
                      )
                    else
                      const Text(
                        'In progress',
                        style: AppTextStyles.captionMuted,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
