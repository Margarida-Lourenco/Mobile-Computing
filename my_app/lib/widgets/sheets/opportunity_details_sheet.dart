import 'package:flutter/material.dart';
import '../../models/opportunity.dart';
import '../../theme/app_theme.dart';
import '../app_sheet.dart';
import '../icon_box.dart';
import '../event_photo.dart';

class OpportunityDetailsSheet extends StatelessWidget {
  final Opportunity item;
  final VoidCallback? onEdit, onDelete, onAttendees;
  final bool isFavorite, isJoined;
  final VoidCallback onFavorite, onJoin, onInvite;
  const OpportunityDetailsSheet(
      {super.key,
      required this.item,
      this.onEdit,
      this.onDelete,
      this.onAttendees,
      required this.isFavorite,
      required this.isJoined,
      required this.onFavorite,
      required this.onJoin,
      required this.onInvite});
  @override
  Widget build(BuildContext context) => AppSheet(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconBox(
              icon: item.icon,
              color: AppColors.paleGreen,
              size: AppIconSizes.s58),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ]),
        if (item.coverImageUrl != null)
          EventPhoto(url: item.coverImageUrl!, width: double.infinity),
        const SizedBox(height: 15),
        Text(item.organization.toUpperCase(),
            style: AppTextStyles.captionMutedBold),
        Text(item.title, style: AppTextStyles.eventTitle),
        if (item.cancelled)
          const Text('This event has been cancelled.',
              style: AppTextStyles.formError),
        const SizedBox(height: 15),
        Wrap(spacing: 14, runSpacing: 10, children: [
          _fact(Icons.calendar_today_outlined, item.date),
          _fact(Icons.schedule, item.time),
          _fact(Icons.location_on_outlined, item.place)
        ]),
        const SizedBox(height: 18),
        Text(item.description, style: AppTextStyles.description),
        const SizedBox(height: 16),
        Text('${item.spotsLeft} spots left', style: AppTextStyles.bodyMedium),
        if (onAttendees != null)
          TextButton.icon(
              onPressed: onAttendees,
              icon: const Icon(Icons.people_outline),
              label: Text('View volunteers (${item.attendeeCount})')),
        if (onEdit != null && !item.cancelled)
          TextButton(onPressed: onEdit, child: const Text('Edit event')),
        if (onDelete != null)
          TextButton(
              onPressed: onDelete,
              child: Text(item.cancelled
                  ? 'Retry cancellation notifications'
                  : 'Cancel event')),
        const SizedBox(height: 20),
        Wrap(spacing: 8, runSpacing: 8, children: [
          IconButton.filledTonal(
              onPressed: onFavorite,
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border)),
          if (!item.cancelled)
            OutlinedButton.icon(
                onPressed: onInvite,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Invite')),
          if (!item.cancelled)
            FilledButton(
                onPressed: !isJoined && item.spotsLeft == 0 ? null : onJoin,
                child: Text(isJoined
                    ? 'Leave event'
                    : item.spotsLeft == 0
                        ? 'Event full'
                        : 'I want to help')),
        ]),
      ]));
  Widget _fact(IconData icon, String text) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: AppIconSizes.s17, color: AppColors.darkBlue),
        const SizedBox(width: 5),
        Text(text, style: AppTextStyles.captionMuted)
      ]);
}
