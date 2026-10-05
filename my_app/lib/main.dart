import 'package:flutter/material.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GoodTogetherApp());
}

class GoodTogetherApp extends StatelessWidget {
  const GoodTogetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Göod Together',
      theme: AppTheme.light,
      home: const HomeShell(),
    );
  }
}
