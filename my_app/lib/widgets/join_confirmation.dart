import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

void showJoinConfirmation(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.removeCurrentSnackBar();
  messenger.showSnackBar(
    const SnackBar(
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.white),
          SizedBox(width: 8),
          Expanded(child: Text('You’re signed up! Thank you for helping.')),
        ],
      ),
    ),
  );
}
