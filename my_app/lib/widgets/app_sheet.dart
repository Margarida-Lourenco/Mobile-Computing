import '../theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppSheet extends StatelessWidget {
  final Widget child;

  const AppSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.r28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: AppColors.sheetHandle,
                  borderRadius: BorderRadius.circular(AppRadii.r5),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
