import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../models/reward_progress.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/section_title.dart';
import '../widgets/event_calendar.dart';
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
  final RewardProgress rewards;

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
    this.rewards = const RewardProgress(),
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

    final visibleJoined = pastShifts ? pastItems : calendar
        ? joinedItems
            .where((e) =>
                e.startsAt != null &&
                DateUtils.isSameDay(e.startsAt, selectedDate))
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
              foregroundImage: widget.profile.imageUrl == null
                  ? null
                  : NetworkImage(widget.profile.imageUrl!),
              child: Text(
                widget.profile.initials,
                style: AppTextStyles.avatarInitials,
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
                onPressed: widget.onEditInfo, child: const Text('Edit info')),
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
                        'LEVEL ${widget.rewards.level} · ${widget.rewards.title.toUpperCase()}',
                        style: AppTextStyles.captionAccentBold,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your good deeds earn badges',
                        style: AppTextStyles.bodyBold,
                      ),
                      Text(
                        '${widget.rewards.badgesEarned} badges earned · ${widget.rewards.completed} completed shifts',
                        style: AppTextStyles.captionMuted,
                      ),
                    ],
                  ),
                ),
                Icon(AppIcons.badge, color: AppColors.darkBlue),
                Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        const SectionTitle(
          kicker: 'YOUR COMMITMENTS',
          title: 'Your activity',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
            builder: (context, constraints) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['My shifts', 'Posted', 'Favorites']
                    .map((tab) => SizedBox(
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
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.r12))),
                            onPressed: () => setState(() => activityTab = tab),
                            child: Text('$tab (${tab == 'My shifts' ? joinedItems.length : tab == 'Posted' ? postedItems.length : favoriteItems.length})',
                                maxLines: 1, overflow: TextOverflow.ellipsis))))
                    .toList())),
        if (activityTab == 'My shifts') ...[
          const SizedBox(height: 14),
          Wrap(alignment: WrapAlignment.end, spacing: 4, children: [
            TextButton.icon(
                onPressed: () => setState(() { calendar = false; pastShifts = false; }),
                icon: Icon(Icons.view_agenda_outlined,
                    color: !calendar && !pastShifts ? AppColors.navy : AppColors.muted),
                label: Text('Agenda',
                    style: !calendar && !pastShifts
                        ? AppTextStyles.bodyBold
                        : AppTextStyles.bodyMuted)),
            TextButton.icon(
                onPressed: () => setState(() { calendar = true; pastShifts = false; }),
                icon: Icon(Icons.calendar_month_outlined,
                    color: calendar && !pastShifts ? AppColors.navy : AppColors.muted),
                label: Text('Calendar',
                    style: calendar && !pastShifts
                        ? AppTextStyles.bodyBold
                        : AppTextStyles.bodyMuted)),
            TextButton.icon(
                onPressed: () => setState(() => pastShifts = true),
                icon: const Icon(Icons.history),
                label: Text('Past shifts (${pastItems.length})',
                    style: pastShifts ? AppTextStyles.bodyBold : AppTextStyles.bodyMuted))
          ]),
          if (calendar && !pastShifts)
            EventCalendar(
                selectedDate: selectedDate,
                events: joinedItems,
                onSelected: (date) => setState(() => selectedDate = date)),
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
                    pastShifts ? '${visibleJoined.length} past shifts' : !calendar ? '${visibleJoined.length} upcoming shifts' : '${selectedDate.day} ${_month(selectedDate.month)} ${selectedDate.year} · ${visibleJoined.length} shifts',
                    maxLines: 2,
                    style: AppTextStyles.bodyBold,
                  ),
                  const Text(
                    'Gothenburg',
                    style: AppTextStyles.captionMuted,
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: 10),
          ...visibleJoined.map(_card),
          if (visibleJoined.isEmpty)
            EmptyState(
              text: pastShifts ? 'No past shifts yet. Completed shifts will appear here.' : 'No shifts here. Choose Discover to find a small way to help.',
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
