import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SmallKicker extends StatelessWidget {
  final String text;

  const SmallKicker(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.blue,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }
}
