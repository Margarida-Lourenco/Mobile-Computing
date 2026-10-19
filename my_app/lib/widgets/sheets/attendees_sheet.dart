import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_sheet.dart';

class AttendeesSheet extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> attendees;
  final String title;
  const AttendeesSheet({
    super.key,
    required this.attendees,
    required this.title,
  });
  @override
  Widget build(BuildContext context) => AppSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Signed-up volunteers',
                    style: AppTextStyles.sheetTitle,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
            Text(title, style: AppTextStyles.bodyMuted),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: attendees,
              builder: (context, s) {
                if (s.hasError) {
                  return const Text(
                    'Could not load volunteers. Check connection and the updated Firebase rules.',
                  );
                }
                if (!s.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (s.data!.isEmpty) {
                  return const Text('Nobody has signed up yet.');
                }
                return Column(
                  children: s.data!
                      .map(
                        (a) => ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(a['username'] as String? ?? 'Member'),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      );
}
