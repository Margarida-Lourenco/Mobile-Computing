import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

void showJoinConfirmation(BuildContext context) {
  _showConfirmation(context, 'You’re signed up! Thank you for helping.');
}

// The prototype uses confirmation feedback rather than sending invitations.
void showCopiedLinkConfirmation(BuildContext context) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CopiedLinkToast(onExpired: () {
      entry.remove();
      entry.dispose();
    }),
  );
  overlay.insert(entry);
}

void _showConfirmation(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.removeCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

class _CopiedLinkToast extends StatefulWidget {
  const _CopiedLinkToast({required this.onExpired});

  final VoidCallback onExpired;

  @override
  State<_CopiedLinkToast> createState() => _CopiedLinkToastState();
}

class _CopiedLinkToastState extends State<_CopiedLinkToast> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), widget.onExpired);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
        left: 24,
        right: 24,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
        child: IgnorePointer(
          child: Center(
            child: Material(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(12),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Semantics(
                  liveRegion: true,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.white),
                      SizedBox(width: 8),
                      Text('Copied Link',
                          style: TextStyle(color: AppColors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
