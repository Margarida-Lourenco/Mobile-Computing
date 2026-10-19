import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.r15),
      ),
      child: Icon(icon, color: AppColors.navy, size: size * .48),
    );
  }
}
