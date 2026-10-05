import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/section_title.dart';

class MyPageScreen extends StatefulWidget {
  final List<Opportunity> opportunities;
  final Set<int> joined;
  final Set<int> favorites;
  final Set<int> posted;
  final ValueChanged<Opportunity> onOpen;
  final ValueChanged<int> onFavorite;
  final VoidCallback onRewards;
  final VoidCallback onPost;

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
  });

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String activityTab = 'Volunteering';
  bool calendar = true;
  int selectedDay = 18;

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
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.paleGreen,
              child: Text(
                'LM',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Göod Together member',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                  Text(
                    'Linnea Mårtensson',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Gothenburg, Sweden',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Edit info')),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat(widget.joined.length, 'Upcoming'),
              _stat(widget.favorites.length, 'Favorites'),
              _stat(widget.posted.length, 'Posted'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: widget.onRewards,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEVEL 2 · KIND NEIGHBOR',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your good deeds earn badges',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '2 badges earned · 2 more within reach',
                        style: TextStyle(fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.auto_awesome, color: AppColors.darkBlue),
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
        SegmentedButton<String>(
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
        ),
        if (activityTab == 'Volunteering') ...[
          const SizedBox(height: 14),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Agenda')),
              ButtonSegment(value: true, label: Text('Calendar')),
            ],
            selected: {calendar},
            onSelectionChanged: (selection) {
              setState(() => calendar = selection.first);
            },
          ),
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
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  '$selectedDay',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'May · 1 shift',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Gothenburg',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _calendar() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left),
              ),
              const Text(
                'May 2025',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (day) => Text(
                    day,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 5),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 34,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 38,
            ),
            itemBuilder: (_, index) {
              final day = index < 3 ? null : index - 2;
              if (day == null) return const SizedBox();

              final selected = day == selectedDay;
              return GestureDetector(
                onTap: () => setState(() => selectedDay = day),
                child: Center(
                  child: Container(
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.navy
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
