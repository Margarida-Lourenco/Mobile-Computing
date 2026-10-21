import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../data/city_areas.dart';
import '../app_sheet.dart';
import '../icon_box.dart';
import '../small_kicker.dart';

class AreaPickerSheet extends StatefulWidget {
  final String currentArea;
  final ValueChanged<String> onSelected;

  const AreaPickerSheet({
    super.key,
    required this.currentArea,
    required this.onSelected,
  });

  @override
  State<AreaPickerSheet> createState() => _AreaPickerSheetState();
}

class _AreaPickerSheetState extends State<AreaPickerSheet> {
  String query = '';

  String normalize(String value) => value
      .toLowerCase()
      .replaceAll('å', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o');

  @override
  Widget build(BuildContext context) {
    final areas = areaCenters.keys.where(
      (name) => normalize(name).contains(normalize(query.trim())),
    );
    return AppSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBox(
            icon: Icons.location_on_outlined,
            color: AppColors.paleBlue,
          ),
          const SizedBox(height: 12),
          const SmallKicker('EXPLORE LOCALLY'),
          const Text('Choose your area', style: AppTextStyles.sheetTitle),
          const SizedBox(height: 6),
          const Text(
            'The map will open around this neighborhood.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 15),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search areas',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 12),
          if (areas.isEmpty) const Text('No areas match your search.'),
          ...areas.map(
            (area) => ListTile(
              onTap: () {
                widget.onSelected(area);
                Navigator.pop(context);
              },
              contentPadding: EdgeInsets.zero,
              leading: const IconBox(
                icon: Icons.location_on_outlined,
                color: AppColors.paleGreen,
                size: AppIconSizes.s42,
              ),
              title: Text(area, style: AppTextStyles.bodyBold),
              trailing: Icon(
                widget.currentArea == area
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: widget.currentArea == area
                    ? AppColors.darkBlue
                    : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
