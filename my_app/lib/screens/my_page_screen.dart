import 'package:flutter/material.dart';
import '../models/opportunity.dart';
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
  });

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String activityTab = 'Volunteering';
  bool calendar = true;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final joinedItems = widget.opportunities
        .where((o) => widget.joined.contains(o.id) && !o.cancelled)
        .toList();
    final postedItems = widget.opportunities
        .where((o) => widget.posted.contains(o.id))
        .toList();
    final favoriteItems = widget.opportunities
        .where((o) => widget.favorites.contains(o.id))
        .toList();

    final visibleJoined = calendar
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
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.r18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _stat(widget.joined.length, 'Upcoming')),
              Expanded(child: _stat(widget.favorites.length, 'Favorites')),
              Expanded(child: _stat(widget.posted.length, 'Posted')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: widget.onRewards,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s15),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(AppRadii.r18),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEVEL 2 · KIND NEIGHBOR',
                        style: AppTextStyles.captionAccentBold,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your good deeds earn badges',
                        style: AppTextStyles.bodyBold,
                      ),
                      Text(
                        '2 badges earned · 2 more within reach',
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
                children: ['Volunteering', 'Posted', 'Favorites']
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
                            child: Text(tab,
                                maxLines: 1, overflow: TextOverflow.ellipsis))))
                    .toList())),
        if (activityTab == 'Volunteering') ...[
          const SizedBox(height: 14),
          Wrap(alignment: WrapAlignment.end, spacing: 4, children: [
            TextButton.icon(
                onPressed: () => setState(() => calendar = false),
                icon: Icon(Icons.view_agenda_outlined,
                    color: !calendar ? AppColors.navy : AppColors.muted),
                label: Text('Agenda',
                    style: !calendar
                        ? AppTextStyles.bodyBold
                        : AppTextStyles.bodyMuted)),
            TextButton.icon(
                onPressed: () => setState(() => calendar = true),
                icon: Icon(Icons.calendar_month_outlined,
                    color: calendar ? AppColors.navy : AppColors.muted),
                label: Text('Calendar',
                    style: calendar
                        ? AppTextStyles.bodyBold
                        : AppTextStyles.bodyMuted))
          ]),
          if (calendar)
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
                    '${calendar ? '${selectedDate.day} ' : ''}${_month(selectedDate.month)} ${selectedDate.year} · ${visibleJoined.length} shifts',
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
            const EmptyState(
              text:
                  'This day is free. Choose Discover to find a small way to help.',
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

  Widget _stat(int value, String label) {
    return Column(
      children: [
        Text(
          '$value',
          style: AppTextStyles.statValue,
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.captionMuted,
        ),
      ],
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
