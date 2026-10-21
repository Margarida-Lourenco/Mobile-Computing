import 'package:flutter/material.dart';

/// Category visuals are shared by map pins and their corresponding list rows.
class CategoryStyle {
  final Color color;
  final IconData icon;
  const CategoryStyle(this.color, this.icon);

  static CategoryStyle forCategory(String category) => switch (category) {
    'Social' ||
    'Community' ||
    'Food' => const CategoryStyle(Color(0xFF176A8A), Icons.groups_rounded),
    'Outdoors' => const CategoryStyle(Color(0xFF287641), Icons.park_rounded),
    'Animals' => const CategoryStyle(Color(0xFF8B5030), Icons.pets_rounded),
    'Housework' => const CategoryStyle(Color(0xFF00796B), Icons.home_rounded),
    'Education' => const CategoryStyle(Color(0xFF5651AA), Icons.school_rounded),
    'Culture' => const CategoryStyle(Color(0xFFAD3469), Icons.palette_rounded),
    'Sports' => const CategoryStyle(
      Color(0xFFAC5100),
      Icons.sports_soccer_rounded,
    ),
    _ => const CategoryStyle(Color(0xFF52616B), Icons.more_horiz_rounded),
  };
}
