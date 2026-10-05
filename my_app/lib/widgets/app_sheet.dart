import 'package:flutter/material.dart';

class AppSheet extends StatelessWidget {
  final Widget child;

  const AppSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 10, 20, 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FCFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC2D8E5),
                  borderRadius: BorderRadius.circular(5),
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
