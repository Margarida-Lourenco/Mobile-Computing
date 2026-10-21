import 'package:flutter/material.dart';

import '../models/opportunity.dart';
import '../models/opportunity_order.dart';
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
  bool calendar = false;
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
    final joinedItems =
        OpportunityOrder.byDate(allJoined.where((o) => !o.hasEnded(now)), now);
    final pastItems = allJoined.where((o) => o.hasEnded(now)).toList()
      ..sort((a, b) => b.completionTime!.compareTo(a.completionTime!));
    final postedItems = OpportunityOrder.byDate(
        widget.opportunities.where((o) => widget.posted.contains(o.id)), now);
    final favoriteItems = OpportunityOrder.byDate(
        widget.opportunities.where((o) => widget.favorites.contains(o.id)),
        now);

    final periodItems = pastShifts ? pastItems : joinedItems;
    final visibleJoined = calendar
        ? periodItems
            .where((e) =>
                e.startsAt != null &&
                DateUtils.isSameDay(e.startsAt, selectedDate))
            .toList()
        : periodItems;
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
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            _activityTab('My shifts', joinedItems.length),
            _activityTab('Posted', postedItems.length),
            _activityTab('Favorites', favoriteItems.length),
          ]),
        ),
        if (activityTab == 'My shifts') ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                _periodTab('Upcoming', !pastShifts,
                    () => _setPeriod(false, joinedItems)),
                _periodTab(
                    'Past', pastShifts, () => _setPeriod(true, pastItems)),
              ]),
            )),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.chipBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(children: [
                _viewButton('Agenda', Icons.view_agenda_outlined, !calendar,
                    () => setState(() => calendar = false)),
                _viewButton('Calendar', Icons.calendar_month_outlined, calendar,
                    () => setState(() => calendar = true)),
              ]),
            ),
          ]),
          if (calendar)
            EventCalendar(
              key: ValueKey(pastShifts),
              selectedDate: selectedDate,
              events: periodItems,
              onSelected: (date) => setState(() => selectedDate = date),
            ),
          const SizedBox(height: 18),
          if (visibleJoined.isNotEmpty)
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
                      const Text('Gothenburg',
                          style: AppTextStyles.captionMuted),
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
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.muted),
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ),
      ],
    );
  }

  Widget _activityTab(String label, int count) => Expanded(
        child: Semantics(
          selected: activityTab == label,
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              width: 3,
              color: activityTab == label ? AppColors.navy : Colors.transparent,
            ))),
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 48),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                foregroundColor:
                    activityTab == label ? AppColors.navy : AppColors.muted,
                shape: const RoundedRectangleBorder(),
              ),
              onPressed: () => setState(() => activityTab = label),
              child: FittedBox(
                  child: Row(children: [
                Text(label),
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('$count', style: AppTextStyles.captionNavy),
                ),
              ])),
            ),
          ),
        ),
      );

  void _setPeriod(bool past, List<Opportunity> events) => setState(() {
        pastShifts = past;
        selectedDate =
            events.where((e) => e.startsAt != null).firstOrNull?.startsAt ??
                DateTime.now();
      });

  Widget _periodTab(String label, bool selected, VoidCallback onTap) =>
      Expanded(
        child: Semantics(
          selected: selected,
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              foregroundColor: selected ? AppColors.navy : AppColors.muted,
              backgroundColor: selected ? AppColors.white : Colors.transparent,
              side: BorderSide(
                  color: selected ? AppColors.chipBorder : Colors.transparent),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: FittedBox(child: Text(label)),
          ),
        ),
      );

  Widget _viewButton(
          String label, IconData icon, bool selected, VoidCallback onTap) =>
      Semantics(
        selected: selected,
        child: IconButton(
          tooltip: label,
          onPressed: onTap,
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            backgroundColor: selected ? AppColors.navy : AppColors.white,
            foregroundColor: selected ? AppColors.white : AppColors.muted,
            shape: const RoundedRectangleBorder(),
          ),
          icon: Icon(icon),
        ),
      );

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
