import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../screens/pick_location_screen.dart';
import '../../models/opportunity.dart';
import '../../theme/app_theme.dart';
import '../app_sheet.dart';
import '../small_kicker.dart';

class PostOpportunitySheet extends StatefulWidget {
  final ValueChanged<Opportunity> onPublished;

  const PostOpportunitySheet({
    super.key,
    required this.onPublished,
  });

  @override
  State<PostOpportunitySheet> createState() => _PostOpportunitySheetState();
}

class _PostOpportunitySheetState extends State<PostOpportunitySheet> {
  final title = TextEditingController();
  final organization = TextEditingController();
  final place = TextEditingController();
  final description = TextEditingController();
  final spots = TextEditingController(text: '4');

  String category = 'Community';
  DateTime? date;
  TimeOfDay? start;
  LatLng? mapPoint;

  @override
  void dispose() {
    title.dispose();
    organization.dispose();
    place.dispose();
    description.dispose();
    spots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SmallKicker('FOR ORGANIZATIONS & NEIGHBORS'),
            const Text(
              'Post an opportunity',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Find kind people nearby for a short, meaningful task.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            _field('Opportunity title', title, 'e.g. Pack weekend food bags'),
            _field('Organization', organization, 'Your organization'),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: _decoration('Category'),
              items: ['Community', 'Outdoors', 'Social', 'Food']
                  .map(
                    (x) => DropdownMenuItem(value: x, child: Text(x)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => category = value);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                    ),
                    label: Text(
                      date == null ? 'Date' : '${date!.day}/${date!.month}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(
                      start == null ? 'Starts' : start!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _field('Location', place, 'Street or meeting point'),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<LatLng>(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            PickLocationScreen(initialPoint: mapPoint)));
                if (result != null && mounted) {
                  setState(() => mapPoint = result);
                }
              },
              icon: const Icon(Icons.location_on_outlined),
              label: Text(mapPoint == null
                  ? 'Place map pin'
                  : 'Map pin placed · change'),
            ),
            const SizedBox(height: 12),
            _field('Volunteers', spots),
            _field(
              'What will volunteers do?',
              description,
              'Keep it clear, friendly, and easy to understand.',
              3,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _publish,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Publish opportunity'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, [
    String hint = '',
    int maxLines = 1,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: _decoration(label).copyWith(hintText: hint),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => start = picked);
  }

  void _publish() {
    if (title.text.trim().isEmpty ||
        organization.text.trim().isEmpty ||
        place.text.trim().isEmpty ||
        description.text.trim().isEmpty ||
        mapPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Complete the details and place a map pin before publishing.')));
      return;
    }

    final opportunity = Opportunity(
      id: DateTime.now().millisecondsSinceEpoch,
      organization: organization.text.trim(),
      title: title.text.trim(),
      date: date == null ? 'New' : '${date!.day} ${_month(date!.month)}',
      time: start == null ? 'Time to be confirmed' : start!.format(context),
      place: place.text.trim(),
      distance: 'New',
      category: category,
      description: description.text.trim(),
      spots: int.tryParse(spots.text) ?? 4,
      icon: Icons.people_outline_rounded,
      latitude: mapPoint!.latitude,
      longitude: mapPoint!.longitude,
    );

    widget.onPublished(opportunity);
    Navigator.pop(context);
  }

  String _month(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
