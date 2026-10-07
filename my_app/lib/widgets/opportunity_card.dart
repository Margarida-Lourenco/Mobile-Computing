import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import 'icon_box.dart';
import 'event_photo.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity item;
  final bool favorite;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;

  const OpportunityCard({
    super.key,
    required this.item,
    required this.favorite,
    required this.onOpen,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      padding: const EdgeInsets.all(AppSpacing.s13),
      decoration: appCardDecoration(),
      child: Row(
        children: [
          if (item.coverImageUrl != null)
            EventPhoto(url: item.coverImageUrl!, height: 60, width: 60)
          else
            IconBox(
              icon: item.icon,
              color: item.id == '2' ? AppColors.paleGreen : AppColors.paleBlue,
              size: AppIconSizes.s48,
            ),
          const SizedBox(width: 13),
          Expanded(
            child: InkWell(
              onTap: onOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.organization.toUpperCase(),
                    style: AppTextStyles.cardKicker,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.cancelled ? '${item.title} · Cancelled' : item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: AppIconSizes.s13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.date,
                          style: AppTextStyles.captionMuted,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Icon(
                        Icons.schedule,
                        size: AppIconSizes.s13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.time,
                          style: AppTextStyles.captionMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.place} · ${item.distance}',
                    style: AppTextStyles.captionMuted,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onFavorite,
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: favorite ? AppColors.darkBlue : AppColors.inactiveIcon,
              size: AppIconSizes.s19,
            ),
          ),
        ],
      ),
    );
  }
}
