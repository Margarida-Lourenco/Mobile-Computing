import 'package:flutter/material.dart';

import '../models/opportunity.dart';
import '../models/reward_progress.dart';
import '../models/community_impact.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/icon_box.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/search_box.dart';
import '../widgets/section_title.dart';

class DiscoverScreen extends StatelessWidget {
  final List<Opportunity> opportunities;
  final Set<String> favorites;
  final String category;
  final Set<String>? categories;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onCategory;
  final ValueChanged<Opportunity> onOpen;
  final ValueChanged<String> onFavorite;
  final VoidCallback onImpact;
  final VoidCallback onRewards;
  final RewardProgress rewards;
  final CommunityImpact? communityImpact;
  final String? impactStatus;

  const DiscoverScreen({
    super.key,
    required this.opportunities,
    required this.favorites,
    this.category = 'All',
    this.categories,
    required this.searchController,
    required this.onSearch,
    required this.onCategory,
    required this.onOpen,
    required this.onFavorite,
    required this.onImpact,
    required this.onRewards,
    this.rewards = const RewardProgress(),
    this.communityImpact,
    this.impactStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchBox(controller: searchController, onChanged: onSearch),
        CategoryChips(
          selected: categories ?? {category},
          onSelected: onCategory,
        ),
        const SizedBox(height: 18),
        _impactCard(),
        const SizedBox(height: 11),
        _contributionCard(),
        const SizedBox(height: 24),
        const SectionTitle(
          kicker: 'MAKE AN IMPACT',
          title: 'Opportunities near you',
        ),
        const SizedBox(height: 13),
        ...opportunities.map(
          (opportunity) => OpportunityCard(
            item: opportunity,
            favorite: favorites.contains(opportunity.id),
            onOpen: () => onOpen(opportunity),
            onFavorite: () => onFavorite(opportunity.id),
          ),
        ),
        if (opportunities.isEmpty)
          const EmptyState(text: 'No opportunities in this category yet.'),
      ],
    );
  }

  Widget _impactCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 205),
      padding: const EdgeInsets.all(AppSpacing.s21),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(AppRadii.r24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -10,
            child: Icon(
              Icons.groups_rounded,
              size: AppIconSizes.s150,
              color: AppColors.white.withValues(alpha: .25),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gothenburg is showing up.',
                style: AppTextStyles.heroTitle,
              ),
              const SizedBox(height: 4),
              Text(
                '${_monthName(DateTime.now().month)} - stats',
                style: AppTextStyles.captionBold,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _stat(
                      communityImpact?.hours.toStringAsFixed(1) ?? '—',
                      'hours shared',
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _stat(
                      '${communityImpact?.accounts ?? '—'}',
                      'members',
                    ),
                  ),
                ],
              ),
              if (impactStatus != null) ...[
                const SizedBox(height: 8),
                Text(impactStatus!, style: AppTextStyles.captionMuted),
              ],
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onImpact,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                icon: const Text(
                  'See your impact',
                  style: AppTextStyles.actionLabel,
                ),
                label: const Icon(
                  Icons.arrow_forward,
                  size: AppIconSizes.s16,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][month - 1];

  Widget _stat(String value, String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          Text(label, style: AppTextStyles.bodyMuted),
        ],
      );

  Widget _contributionCard() {
    return InkWell(
      onTap: onRewards,
      borderRadius: BorderRadius.circular(AppRadii.r17),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadii.r18),
        ),
        child: Row(
          children: [
            const IconBox(
              icon: AppIcons.badge,
              color: AppColors.green,
              size: AppIconSizes.s46,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR CONTRIBUTION',
                    style: AppTextStyles.captionAccentBold,
                  ),
                  Text(
                    '${rewards.hours.toStringAsFixed(1)} hours shared · ${rewards.badgesEarned} badges earned',
                    style: AppTextStyles.captionBold,
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: rewards.progress,
                    minHeight: 4,
                    backgroundColor: AppColors.progressTrack,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${rewards.remaining} more shifts until level ${rewards.level + 1}',
                    style: AppTextStyles.captionMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
