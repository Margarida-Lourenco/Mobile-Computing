import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int index;
  final int unreadCount;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.index,
    this.unreadCount = 0,
    required this.onTap,
  });

  static const _labels = [
    'Discover',
    'Map',
    'Post',
    'Notifications',
    'My Page'
  ];
  static const _icons = [
    Icons.home_outlined,
    Icons.map_outlined,
    Icons.add_circle_outline,
    Icons.notifications_outlined,
    Icons.calendar_month_outlined
  ];
  static const _selectedIcons = [
    Icons.home,
    Icons.map,
    Icons.add_circle,
    Icons.notifications,
    Icons.calendar_month
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
              children: List.generate(_labels.length, (destination) {
            final selected = index == destination;
            final label = _labels[destination];
            final icon = Icon(
                selected ? _selectedIcons[destination] : _icons[destination],
                color: AppColors.navy);
            return Expanded(
              child: Semantics(
                container: true,
                button: true,
                selected: selected,
                label: destination == 3 && unreadCount > 0
                    ? '$label, $unreadCount unread'
                    : label,
                onTap: () => onTap(destination),
                excludeSemantics: true,
                child: InkWell(
                  onTap: () => onTap(destination),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 64,
                            height: 32,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.paleGreen
                                  : AppColors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: destination == 3
                                ? Badge(
                                    isLabelVisible: unreadCount > 0,
                                    label: Text('$unreadCount'),
                                    child: icon)
                                : icon,
                          ),
                          const SizedBox(height: 4),
                          // Fit the actual single-line label, including inherited text scaling.
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(label,
                                maxLines: 1,
                                softWrap: false,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.navy)),
                          ),
                        ]),
                  ),
                ),
              ),
            );
          })),
        ),
      ),
    );
  }
}
