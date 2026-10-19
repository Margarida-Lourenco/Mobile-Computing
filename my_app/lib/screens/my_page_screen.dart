import 'package:flutter/material.dart';

import '../models/opportunity.dart';
import '../models/reward_progress.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/section_title.dart';
import '../widgets/event_calendar.dart';
import '../widgets/event_photo.dart';
import 'edit_info_screen.dart';

class MyPageScreen extends StatefulWidget {
  final List<Opportunity> opportunities;
  final Set<String> joined;
  final Set<String> favorites;
  final Set<String> posted;
  final ValueChanged<Opportunity> onOpen;
  final ValueChanged<String> onFavorite;
  final VoidCallback onRewards;
  final VoidCallback onPost;
  final ProfileInfo profile;
  final VoidCallback onEditInfo;
  final VoidCallback? onSignOut;

  const MyPageScreen({
    super.key,
    required this.opportunities,
    required this.joined,
    required this.favorites,
    required this.posted,
    required this.onOpen,
    required this.onFavorite,
    required this.onRewards,
    required this.onPost,
    required this.profile,
    required this.onEditInfo,
    this.onSignOut,
  });

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String activityTab = 'My shifts';
  bool pastShifts = false;
  bool calendar = true;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final rewards = RewardProgress.fromShifts(
      widget.opportunities,
      widget.joined,
      now,
    );
    final allJoined = widget.opportunities
        .where((o) => widget.joined.contains(o.id) && !o.cancelled)
        .toList();
    final joinedItems = allJoined.where((o) => !o.hasEnded(now)).toList();
    final pastItems = allJoined.where((o) => o.hasEnded(now)).toList()
      ..sort((a, b) => b.completionTime!.compareTo(a.completionTime!));
    final postedItems = widget.opportunities
        .where((o) => widget.posted.contains(o.id))
        .toList();
    final favoriteItems = widget.opportunities
        .where((o) => widget.favorites.contains(o.id))
        .toList();

    final visibleJoined = pastShifts
        ? pastItems
        : calendar
            ? joinedItems
                .where(
                  (e) =>
                      e.startsAt != null &&
                      DateUtils.isSameDay(e.startsAt, selectedDate),
                )
                .toList()
            : joinedItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.paleGreen,
              child: widget.profile.imageUrl == null
                  ? Text(
                      widget.profile.initials,
                      style: AppTextStyles.avatarInitials,
                    )
                  : ClipOval(
                      child: EventPhoto(
                        reference: widget.profile.imageUrl!,
                        width: 60,
                        height: 60,
                        fallback: Text(
                          widget.profile.initials,
                          style: AppTextStyles.avatarInitials,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Göod Together member',
                    style: AppTextStyles.captionMuted,
                  ),
                  Text(
                    widget.profile.displayUsername,
                    style: AppTextStyles.profileTitle,
                  ),
                  Text(
                    widget.profile.location,
                    style: AppTextStyles.captionMuted,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: widget.onEditInfo,
              child: const Text('Edit info'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        InkWell(
          onTap: widget.onRewards,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s15),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(AppRadii.r18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEVEL ${rewards.level} · ${rewards.title.toUpperCase()}',
                        style: AppTextStyles.captionAccentBold,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Your good deeds earn badges',
                        style: AppTextStyles.bodyBold,
                      ),
                      Text(
                        '${rewards.badgesEarned} badges earned · ${rewards.completed} completed shifts',
                        style: AppTextStyles.captionMuted,
                      ),
                    ],
                  ),
                ),
                const Icon(AppIcons.badge, color: AppColors.darkBlue),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        const SectionTitle(kicker: 'YOUR COMMITMENTS', title: 'Your activity'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['My shifts', 'Posted', 'Favorites']
                .map(
                  (tab) => SizedBox(
                    width: constraints.maxWidth < 300
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 16) / 3,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: activityTab == tab
                            ? AppColors.navy
                            : AppColors.white,
                        foregroundColor: activityTab == tab
                            ? AppColors.white
                            : AppColors.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.r12),
                        ),
                      ),
                      onPressed: () => setState(() => activityTab = tab),
                      child: Text(
                        '$tab (${tab == 'My shifts' ? joinedItems.length : tab == 'Posted' ? postedItems.length : favoriteItems.length})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (activityTab == 'My shifts') ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _viewTab(
                  'Agenda',
                  Icons.view_agenda_outlined,
                  !calendar && !pastShifts,
                  () => setState(() {
                    calendar = false;
                    pastShifts = false;
                  }),
                ),
              ),
              Expanded(
                child: _viewTab(
                  'Calendar',
                  Icons.calendar_month_outlined,
                  calendar && !pastShifts,
                  () => setState(() {
                    calendar = true;
                    pastShifts = false;
                  }),
                ),
              ),
              Expanded(
                child: _viewTab(
                  'Past shifts',
                  Icons.history,
                  pastShifts,
                  () => setState(() => pastShifts = true),
                ),
              ),
            ],
          ),
          if (calendar && !pastShifts)
            EventCalendar(
              selectedDate: selectedDate,
              events: joinedItems,
              onSelected: (date) => setState(() => selectedDate = date),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.paleGreen,
                  borderRadius: BorderRadius.circular(AppRadii.r13),
                ),
                child: Text(
                  '${selectedDate.day}',
                  style: AppTextStyles.calendarDay,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pastShifts
                          ? '${visibleJoined.length} past shifts'
                          : !calendar
                              ? '${visibleJoined.length} upcoming shifts'
                              : '${selectedDate.day} ${_month(selectedDate.month)} ${selectedDate.year} · ${visibleJoined.length} shifts',
                      maxLines: 2,
                      style: AppTextStyles.bodyBold,
                    ),
                    const Text('Gothenburg', style: AppTextStyles.captionMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...visibleJoined.map(_card),
          if (visibleJoined.isEmpty)
            EmptyState(
              text: pastShifts
                  ? 'No past shifts yet. Completed shifts will appear here.'
                  : 'No shifts here. Choose Discover to find a small way to help.',
            ),
        ] else if (activityTab == 'Posted') ...[
          const SizedBox(height: 16),
          ...postedItems.map(_card),
          if (postedItems.isEmpty)
            EmptyAction(
              title: 'You haven’t posted anything yet',
              body:
                  'Create a short activity and find people nearby who can help.',
              action: 'Post an opportunity',
              onPressed: widget.onPost,
            ),
        ] else ...[
          const SizedBox(height: 16),
          ...favoriteItems.map(_card),
          if (favoriteItems.isEmpty)
            const EmptyState(
              text:
                  'No favorites yet. Tap the heart on an opportunity to save it here.',
            ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ),
      ],
    );
  }

  Widget _viewTab(
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        foregroundColor: selected ? AppColors.navy : AppColors.muted,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Opportunity opportunity) {
    return OpportunityCard(
      item: opportunity,
      favorite: widget.favorites.contains(opportunity.id),
      onOpen: () => widget.onOpen(opportunity),
      onFavorite: () => widget.onFavorite(opportunity.id),
    );
  }

  String _month(int month) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month];
}
