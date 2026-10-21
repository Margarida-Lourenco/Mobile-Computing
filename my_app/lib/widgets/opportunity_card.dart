import 'package:flutter/material.dart';

import '../models/opportunity.dart';
import '../theme/app_theme.dart';
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
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s10),
        decoration: appCardDecoration(),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadii.r18),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              InkWell(
                onTap: onOpen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      key: const ValueKey('listing-photo'),
                      aspectRatio: 16 / 9,
                      child: item.coverImageUrl != null
                          ? EventPhoto(
                              reference: item.coverImageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : ColoredBox(
                              color: AppColors.paleBlue,
                              child: Icon(item.icon,
                                  size: 48, color: AppColors.darkBlue),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.organization.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardKicker,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.title,
                            softWrap: true,
                            style: AppTextStyles.cardTitle
                                .copyWith(fontSize: 18, height: 1.25),
                          ),
                          if (item.cancelled) ...[
                            const SizedBox(height: 4),
                            const Text('Cancelled',
                                style: AppTextStyles.formError),
                          ],
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 14,
                            runSpacing: 6,
                            children: [
                              _fact(Icons.calendar_today_outlined, item.date),
                              _fact(Icons.schedule, item.time),
                            ],
                          ),
                          const SizedBox(height: 7),
                          _fact(
                            Icons.location_on_outlined,
                            [
                              item.place,
                              if (item.distance.isNotEmpty) item.distance
                            ].join(' · '),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  tooltip:
                      favorite ? 'Remove from favorites' : 'Add to favorites',
                  isSelected: favorite,
                  onPressed: onFavorite,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.navy,
                    shape: const CircleBorder(),
                  ),
                  icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _fact(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.muted),
          const SizedBox(width: 5),
          Flexible(child: Text(text, style: AppTextStyles.captionMuted)),
        ],
      );
}
