import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../app_sheet.dart';
import '../icon_box.dart';
import '../small_kicker.dart';

class AreaPickerSheet extends StatelessWidget {
  final String currentArea;
  final ValueChanged<String> onSelected;

  const AreaPickerSheet({
    super.key,
    required this.currentArea,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const areas = {
      'Majorna': 'West · parks and community spaces',
      'Linné': 'Central · social and food initiatives',
      'Haga': 'Central · local neighborhood projects',
      'Centrum': 'City center · the widest selection',
      'Kvillebäcken': 'Hisingen · growing local community',
    };

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
          const Text(
            'Choose your area',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'We’ll prioritize opportunities closest to this neighborhood.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 15),
          ...areas.entries.map(
            (entry) => ListTile(
              onTap: () {
                onSelected(entry.key);
                Navigator.pop(context);
              },
              contentPadding: EdgeInsets.zero,
              leading: const IconBox(
                icon: Icons.location_on_outlined,
                color: AppColors.paleGreen,
                size: 42,
              ),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                entry.value,
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Icon(
                currentArea == entry.key
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: currentArea == entry.key
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
