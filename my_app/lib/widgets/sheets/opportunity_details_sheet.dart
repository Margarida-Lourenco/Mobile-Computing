import 'package:flutter/material.dart';
import '../../models/opportunity.dart';
import '../../theme/app_theme.dart';
import '../app_sheet.dart';
import '../icon_box.dart';
import '../event_photo.dart';

class OpportunityDetailsSheet extends StatelessWidget {
  final Opportunity item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isFavorite;
  final bool isJoined;
  final VoidCallback onFavorite;
  final VoidCallback onJoin;
  final VoidCallback onInvite;

  const OpportunityDetailsSheet({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
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
                size: AppIconSizes.s58,
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
          if (item.coverImageUrl != null)
            EventPhoto(url: item.coverImageUrl!, width: double.infinity),
          if (onEdit != null)
            TextButton(onPressed: onEdit, child: const Text('Edit event')),
          if (onDelete != null)
            TextButton(onPressed: onDelete, child: const Text('Delete event')),
          const SizedBox(height: 15),
          Text(
            item.organization.toUpperCase(),
            style: AppTextStyles.captionMutedBold,
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: AppTextStyles.eventTitle,
          ),
          if (item.coverImageUrl != null)
            EventPhoto(url: item.coverImageUrl!, width: double.infinity),
          if (onEdit != null)
            TextButton(onPressed: onEdit, child: const Text('Edit event')),
          if (onDelete != null)
            TextButton(onPressed: onDelete, child: const Text('Delete event')),
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
            style: AppTextStyles.description,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              const Icon(
                Icons.people_outline,
                size: AppIconSizes.s19,
                color: AppColors.darkBlue,
              ),
              Text(
                '${item.spots} spots left',
                style: AppTextStyles.bodyMedium,
              ),
              const Text(
                'No experience needed',
                style: AppTextStyles.captionMuted,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              IconButton.filledTonal(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onInvite,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Invite'),
              ),
              FilledButton(
                onPressed: onJoin,
                child: Text(isJoined ? '✓ Joined' : 'I want to help'),
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
        Icon(icon, size: AppIconSizes.s17, color: AppColors.darkBlue),
        const SizedBox(width: 5),
        Text(
          text,
          style: AppTextStyles.captionMuted,
        ),
      ],
    );
  }
}
