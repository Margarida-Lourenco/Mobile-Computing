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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: appCardDecoration(),
      child: Row(
        children: [
          if (item.coverImageUrl != null)
            EventPhoto(url: item.coverImageUrl!, height: 60, width: 60)
          else
            IconBox(
              icon: item.icon,
              color: item.id == '2' ? AppColors.paleGreen : AppColors.paleBlue,
              size: 48,
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Icon(
                        Icons.schedule,
                        size: 13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.place} · ${item.distance}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onFavorite,
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: favorite ? AppColors.darkBlue : const Color(0xFF91A4AF),
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}
