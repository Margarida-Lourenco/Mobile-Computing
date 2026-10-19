import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String kicker;
  final String title;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.kicker,
    required this.title,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kicker, style: AppTextStyles.sectionKicker),
              const SizedBox(height: 2),
              Text(title, style: AppTextStyles.statValue),
            ],
          ),
        ),
        if (onAction != null)
          TextButton(onPressed: onAction, child: const Text('See all')),
      ],
    );
  }
}
