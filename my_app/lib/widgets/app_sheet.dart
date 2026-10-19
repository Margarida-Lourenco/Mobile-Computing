import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A single, bounded scroll surface for every modal, including short browsers
/// and the smaller viewport left while the on-screen keyboard is visible.
class AppSheet extends StatelessWidget {
  final Widget child;
  const AppSheet({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * .92),
          child: Material(
            color: AppColors.background,
            clipBehavior: Clip.antiAlias,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadii.r28)),
            child: SingleChildScrollView(
              key: const ValueKey('sheet-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                      child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.s8),
                    decoration: BoxDecoration(
                        color: AppColors.sheetHandle,
                        borderRadius: BorderRadius.circular(AppRadii.r5)),
                  )),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
