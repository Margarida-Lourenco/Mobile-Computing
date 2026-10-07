import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../screens/pick_location_screen.dart';
import '../../models/opportunity.dart';
import '../../theme/app_theme.dart';
import '../app_sheet.dart';
import '../small_kicker.dart';

class PostOpportunitySheet extends StatefulWidget {
  final ValueChanged<Opportunity> onPublished;
  final Future<void> Function(Opportunity, XFile?) onSave;
  final Opportunity? existing;
  final String Function()? newId;

  const PostOpportunitySheet({
    super.key,
    required this.onPublished,
    required this.onSave,
    this.existing,
    this.newId,
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

  late final String draftId;
  XFile? photo;
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    draftId = widget.existing?.id ??
        widget.newId?.call() ??
        '${DateTime.now().microsecondsSinceEpoch}';
    final e = widget.existing;
    if (e != null) {
      title.text = e.title;
      organization.text = e.organization;
      place.text = e.place;
      description.text = e.description;
      spots.text = '${e.spots}';
      category = e.category;
      date = e.startsAt;
      start = e.startsAt == null ? null : TimeOfDay.fromDateTime(e.startsAt!);
      if (e.latitude != null && e.longitude != null) {
        mapPoint = LatLng(e.latitude!, e.longitude!);
      }
    }
  }

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
    return PopScope(
        canPop: !busy,
        child: AppSheet(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: busy ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SmallKicker('FOR ORGANIZATIONS & NEIGHBORS'),
                const Text(
                  'Post an opportunity',
                  style: AppTextStyles.compactSheetTitle,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Find kind people nearby for a short, meaningful task.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 20),
                if (photo != null)
                  FutureBuilder(
                      future: photo!.readAsBytes(),
                      builder: (c, s) => s.data == null
                          ? const SizedBox()
                          : Image.memory(s.data!, height: 150)),
                OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () async {
                            try {
                              final selected = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1600,
                                  imageQuality: 85);
                              if (mounted && selected != null) {
                                setState(() => photo = selected);
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(
                                    () => error = 'Could not select image: $e');
                              }
                            }
                          },
                    icon: const Icon(Icons.photo),
                    label: const Text('Choose event cover photo')),
                if (error != null) Text(error!),
                _field(
                    'Opportunity title', title, 'e.g. Pack weekend food bags'),
                _field('Host', organization, 'Your name or organization'),
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
                          size: AppIconSizes.s18,
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
                        icon:
                            const Icon(Icons.schedule, size: AppIconSizes.s18),
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
                    onPressed: busy ? null : _publish,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Publish opportunity'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _field(
    String label,
    TextEditingController controller, [
    String hint = '',
    int maxLines = 1,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
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
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.r13),
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

  Future<void> _publish() async {
    if (title.text.trim().isEmpty ||
        organization.text.trim().isEmpty ||
        place.text.trim().isEmpty ||
        description.text.trim().isEmpty ||
        mapPoint == null ||
        date == null ||
        start == null ||
        (int.tryParse(spots.text) ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Add all details, a date, start time, a positive volunteer count and a map pin.')));
      return;
    }

    final opportunity = Opportunity(
      id: draftId,
      ownerId: widget.existing?.ownerId ?? '',
      coverImageUrl: widget.existing?.coverImageUrl,
      imageUrls: widget.existing?.imageUrls ?? const [],
      startsAt: DateTime(
          date!.year, date!.month, date!.day, start!.hour, start!.minute),
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

    setState(() => busy = true);
    try {
      await widget.onSave(opportunity, photo);
      if (!mounted) return;
      setState(() => busy = false);
      widget.onPublished(opportunity);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => error = 'Could not publish: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
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
