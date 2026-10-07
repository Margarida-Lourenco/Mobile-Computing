import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/section_title.dart';
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
        .where((o) => widget.joined.contains(o.id))
        .toList();
    final postedItems = widget.opportunities
        .where((o) => widget.posted.contains(o.id))
        .toList();
    final favoriteItems = widget.opportunities
        .where((o) => widget.favorites.contains(o.id))
        .toList();

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
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Volunteering',
                  label: Text('Volunteering'),
                ),
                ButtonSegment(value: 'Posted', label: Text('Posted')),
                ButtonSegment(value: 'Favorites', label: Text('Favorites')),
              ],
              selected: {activityTab},
              onSelectionChanged: (selection) {
                setState(() => activityTab = selection.first);
              },
            )),
        if (activityTab == 'Volunteering') ...[
          const SizedBox(height: 14),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Agenda')),
                  ButtonSegment(value: true, label: Text('Calendar')),
                ],
                selected: {calendar},
                onSelectionChanged: (selection) {
                  setState(() => calendar = selection.first);
                },
              )),
          if (calendar) _calendar(),
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
                    '${_month(selectedDate.month)} ${selectedDate.year} · ${joinedItems.length} shifts',
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
          ...joinedItems.map(_card),
          if (joinedItems.isEmpty)
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

  Widget _calendar() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.r18),
      ),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
              width: 350,
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                onDateChanged: (date) => setState(() => selectedDate = date),
              ))),
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
