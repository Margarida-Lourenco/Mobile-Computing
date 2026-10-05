import 'package:flutter/material.dart';
import '../../models/opportunity.dart';
import '../../theme/app_theme.dart';
import '../app_sheet.dart';
import '../icon_box.dart';
import '../small_kicker.dart';

class InviteSheet extends StatefulWidget {
  final Opportunity item;

  const InviteSheet({super.key, required this.item});

  @override
  State<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<InviteSheet> {
  final selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final friends = [
      ['AK', 'Amir Khan'],
      ['ES', 'Elin Svensson'],
      ['NJ', 'Nora Johansson'],
    ];

    return AppSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBox(icon: Icons.share_outlined, color: AppColors.paleGreen),
          const SizedBox(height: 12),
          const SmallKicker('CHALLENGE YOUR FRIENDS'),
          const Text(
            'Do good together',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Invite friends to join “${widget.item.title}”.',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          ...friends.map(
            (friend) => ListTile(
              onTap: () {
                setState(() {
                  selected.contains(friend[1])
                      ? selected.remove(friend[1])
                      : selected.add(friend[1]);
                });
              },
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.paleBlue,
                foregroundColor: AppColors.navy,
                child: Text(friend[0]),
              ),
              title: Text(
                friend[1],
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: Icon(
                selected.contains(friend[1])
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected.contains(friend[1])
                    ? AppColors.darkBlue
                    : AppColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: selected.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Invitation sent'),
                          content: const Text(
                            'We’ll let you know when your friends respond.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      );
                    },
              icon: const Icon(Icons.share_outlined),
              label: Text(
                'Send ${selected.isEmpty ? '' : selected.length} invitation'
                '${selected.length == 1 ? '' : 's'}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
