import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_box.dart';
import '../widgets/section_title.dart';

class MapScreen extends StatelessWidget {
  final List<Opportunity> opportunities;
  final ValueChanged<Opportunity> onOpen;

  const MapScreen({
    super.key,
    required this.opportunities,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionTitle(
          kicker: 'EXPLORE GOTHENBURG',
          title: 'Help close to home',
        ),
        const SizedBox(height: 14),
        Container(
          height: 390,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4E4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDCE3DC)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 145,
                left: -50,
                right: -50,
                child: Transform.rotate(
                  angle: -.22,
                  child: Container(
                    height: 65,
                    color: const Color(0xFF9BD7ED),
                  ),
                ),
              ),
              const Positioned(
                top: 100,
                right: 45,
                child: Text(
                  'CENTRUM',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const Positioned(
                bottom: 70,
                left: 28,
                child: Text(
                  'SLOTTSSKOGEN',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    color: AppColors.muted,
                  ),
                ),
              ),
              const Positioned(
                bottom: 45,
                right: 30,
                child: Text(
                  'MAJORNA',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    color: AppColors.muted,
                  ),
                ),
              ),
              ...opportunities.asMap().entries.map((entry) {
                final positions = [
                  const Alignment(.55, -.55),
                  const Alignment(-.55, .5),
                  const Alignment(.55, .45),
                ];

                return Align(
                  alignment: positions[entry.key % positions.length],
                  child: GestureDetector(
                    onTap: () => onOpen(entry.value),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Color(0x3308344C),
                          ),
                        ],
                      ),
                      child: Icon(entry.value.icon, color: AppColors.navy),
                    ),
                  ),
                );
              }),
              Positioned(
                right: 14,
                bottom: 14,
                child: FloatingActionButton.small(
                  heroTag: 'locate',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.darkBlue,
                  onPressed: () {},
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(13, -30, 13, 0),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              IconBox(
                icon: opportunities.isEmpty
                    ? Icons.favorite_border
                    : opportunities.first.icon,
                color: AppColors.paleGreen,
                size: 40,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CLOSEST TO YOU',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      opportunities.isEmpty
                          ? 'No opportunities here yet'
                          : opportunities.first.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              if (opportunities.isNotEmpty)
                IconButton(
                  onPressed: () => onOpen(opportunities.first),
                  icon: const Icon(Icons.chevron_right),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
