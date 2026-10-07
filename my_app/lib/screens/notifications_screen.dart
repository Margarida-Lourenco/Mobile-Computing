import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  final List<AppNotification> notifications;
  final bool loading;
  final ValueChanged<AppNotification> onOpen;
  const NotificationsScreen(
      {super.key,
      required this.notifications,
      required this.onOpen,
      this.loading = false});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Notifications', style: AppTextStyles.pageTitle),
        const SizedBox(height: 12),
        if (loading) const LinearProgressIndicator(),
        if (!loading && notifications.isEmpty)
          const EmptyState(
              text:
                  'Your sign-ups and updates about your events will appear here.'),
        ...notifications.map((n) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s10),
            decoration: appCardDecoration(),
            child: ListTile(
                leading: Icon(
                    n.kind == 'cancelled' ||
                            n.kind == 'withdrawal' ||
                            n.kind == 'left'
                        ? Icons.event_busy_outlined
                        : Icons.notifications_active_outlined,
                    color: AppColors.darkBlue),
                title: Text(n.message,
                    style: n.read
                        ? AppTextStyles.bodyMuted
                        : AppTextStyles.bodyBold),
                subtitle: n.createdAt == null
                    ? const Text('Just now')
                    : Text(MaterialLocalizations.of(context)
                        .formatShortDate(n.createdAt!.toLocal())),
                trailing: n.read
                    ? null
                    : const Icon(Icons.circle,
                        size: 8, color: AppColors.darkBlue),
                onTap: () => onOpen(n)))),
      ]);
}
