import 'package:flutter/material.dart';
import '../models/opportunity.dart';
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
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onCategory;
  final ValueChanged<Opportunity> onOpen;
  final ValueChanged<String> onFavorite;
  final VoidCallback onImpact;
  final VoidCallback onRewards;

  const DiscoverScreen({
    super.key,
    required this.opportunities,
    required this.favorites,
    required this.category,
    required this.searchController,
    required this.onSearch,
    required this.onCategory,
    required this.onOpen,
    required this.onFavorite,
    required this.onImpact,
    required this.onRewards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchBox(controller: searchController, onChanged: onSearch),
        CategoryChips(selected: category, onSelected: onCategory),
        const SizedBox(height: 18),
        _impactCard(),
        const SizedBox(height: 11),
        _contributionCard(),
        const SizedBox(height: 24),
        SectionTitle(
          kicker: 'MAKE AN IMPACT',
          title: 'Opportunities near you',
          onAction: () => onCategory('All'),
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
          const EmptyState(
            text: 'No opportunities in this category yet.',
          ),
      ],
    );
  }

  Widget _impactCard() {
    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(AppRadii.r20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.badge,
                      size: AppIconSizes.s14,
                      color: AppColors.darkBlue,
                    ),
                    SizedBox(width: 5),
                    Flexible(
                        child: Text(
                      'THIS MONTH’S IMPACT',
                      style: AppTextStyles.captionAccentBold,
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Gothenburg is showing up.',
                style: AppTextStyles.heroTitle,
              ),
              const SizedBox(height: 9),
              const Wrap(
                spacing: 15,
                runSpacing: 8,
                children: [
                  Text(
                    '428\nhours shared',
                    style: AppTextStyles.captionMuted,
                  ),
                  Text(
                    '312\nneighbors',
                    style: AppTextStyles.captionMuted,
                  ),
                ],
              ),
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
        child: const Row(
          children: [
            IconBox(
              icon: AppIcons.badge,
              color: AppColors.green,
              size: AppIconSizes.s46,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR CONTRIBUTION',
                    style: AppTextStyles.captionAccentBold,
                  ),
                  Text(
                    '3 hours shared · 2 badges earned',
                    style: AppTextStyles.captionBold,
                  ),
                  SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: .6,
                    minHeight: 4,
                    backgroundColor: AppColors.progressTrack,
                    valueColor: AlwaysStoppedAnimation(AppColors.darkBlue),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '2 more activities until Local Hero',
                    style: AppTextStyles.captionMuted,
                  ),
                ],
              ),
            ),
            SizedBox(width: 7),
            Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
