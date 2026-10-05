import 'package:flutter/material.dart';
import '../../models/opportunity.dart';
import '../../theme/app_theme.dart';
import '../app_sheet.dart';
import '../icon_box.dart';

class OpportunityDetailsSheet extends StatelessWidget {
  final Opportunity item;
  final bool isFavorite;
  final bool isJoined;
  final VoidCallback onFavorite;
  final VoidCallback onJoin;
  final VoidCallback onInvite;

  const OpportunityDetailsSheet({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.isJoined,
    required this.onFavorite,
    required this.onJoin,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconBox(
                icon: item.icon,
                color: AppColors.paleGreen,
                size: 58,
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            item.organization.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              _fact(Icons.calendar_today_outlined, item.date),
              _fact(Icons.schedule, item.time),
              _fact(Icons.location_on_outlined, item.place),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            item.description,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 19,
                color: AppColors.darkBlue,
              ),
              const SizedBox(width: 5),
              Text(
                '${item.spots} spots left',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 15),
              const Text(
                'No experience needed',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onInvite,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Invite'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: onJoin,
                  child: Text(isJoined ? '✓ Joined' : 'I want to help'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fact(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.darkBlue),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
