import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../app_sheet.dart';
import '../icon_box.dart';
import '../small_kicker.dart';

class RewardsSheet extends StatelessWidget {
  const RewardsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      ['First Step', 'Completed your first activity', Icons.auto_awesome, true],
      ['Helping Hand', 'Shared 3 hours of your time', Icons.favorite, true],
      ['Team Player', 'Invited a friend to help', Icons.people_outline, false],
      [
        'Local Hero',
        'Complete 5 local activities',
        Icons.location_on_outlined,
        false
      ],
    ];

    return AppSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBox(icon: Icons.auto_awesome, color: AppColors.green),
          const SizedBox(height: 12),
          const SmallKicker('YOUR KINDNESS COLLECTION'),
          const Text(
            'Badges of good',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const Text(
            'Every hour, invitation, and helping hand counts.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          const Text(
            'Kind Neighbor',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: .6,
              minHeight: 7,
              backgroundColor: AppColors.paleBlue,
              valueColor: AlwaysStoppedAnimation(AppColors.darkBlue),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '3 of 5 activities · 2 more to become a Local Hero',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          ...badges.map(
            (badge) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(17),
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
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            badge[1] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (badge[3] as bool)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.darkBlue,
                        size: 19,
                      )
                    else
                      const Text(
                        'In progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
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
