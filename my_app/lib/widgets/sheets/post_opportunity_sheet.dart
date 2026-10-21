import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/opportunity_filters.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:latlong2/latlong.dart';

import '../../screens/pick_location_screen.dart';
import '../../models/opportunity.dart';
import '../../theme/app_theme.dart';
import '../small_kicker.dart';
import '../photo_editor.dart';

class PostOpportunitySheet extends StatefulWidget {
  final ValueChanged<Opportunity> onPublished;
  final Future<void> Function(Opportunity, Uint8List?) onSave;
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
  bool busy = false;
  Uint8List? photo;
  bool removePhoto = false;
  bool slowSave = false;
  Timer? saveTimer;
  final submitArea = GlobalKey();
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
      end = e.endsAt == null ? null : TimeOfDay.fromDateTime(e.endsAt!);
      if (e.latitude != null && e.longitude != null) {
        mapPoint = LatLng(e.latitude!, e.longitude!);
      }
    }
  }

  String category = 'Social';
  DateTime? date;
  TimeOfDay? start;
  TimeOfDay? end;
  LatLng? mapPoint;

  @override
  void dispose() {
    saveTimer?.cancel();
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.existing == null
              ? 'Post an opportunity'
              : 'Edit opportunity'),
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: busy ? null : () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            )
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: SingleChildScrollView(
                key: const ValueKey('post-page-scroll'),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SmallKicker('FOR ORGANIZATIONS & NEIGHBORS'),
                    const SizedBox(height: 6),
                    const Text(
                      'Find kind people nearby for a short, meaningful task.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: 20),
                    PhotoEditor(
                      label: 'Choose event cover photo',
                      busy: busy,
                      reference:
                          removePhoto ? null : widget.existing?.coverImageUrl,
                      selected: photo,
                      onSelected: (bytes) => setState(() {
                        photo = bytes;
                        removePhoto = false;
                      }),
                      onRemove: () => setState(() {
                        photo = null;
                        removePhoto = true;
                      }),
                    ),
                    _field('Opportunity title', title,
                        'e.g. Pack weekend food bags'),
                    _field('Host', organization, 'Your name or organization'),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: _decoration('Category'),
                      items: {...OpportunityFilters.categories, category}
                          .map(
                              (x) => DropdownMenuItem(value: x, child: Text(x)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => category = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const ValueKey('post-date'),
                        onPressed: busy ? null : _pickDate,
                        icon:
                            const Icon(Icons.calendar_today_outlined, size: 18),
                        label: Text(date == null
                            ? 'Date'
                            : '${date!.day}/${date!.month}/${date!.year}'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: OutlinedButton.icon(
                          key: const ValueKey('post-start'),
                          onPressed: busy ? null : _pickTime,
                          icon: const Icon(Icons.schedule, size: 18),
                          label: Text(
                              start == null ? 'Start time' : _clock(start!)),
                        )),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('–', style: AppTextStyles.bodyBold),
                        ),
                        Expanded(
                            child: OutlinedButton.icon(
                          key: const ValueKey('post-end'),
                          onPressed: busy ? null : _pickEndTime,
                          icon: const Icon(Icons.schedule, size: 18),
                          label: Text(end == null ? 'End time' : _clock(end!)),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field('Address', place, 'Street or meeting point'),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push<LatLng>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PickLocationScreen(initialPoint: mapPoint),
                          ),
                        );
                        if (result != null && mounted) {
                          setState(() => mapPoint = result);
                        }
                      },
                      icon: const Icon(Icons.location_on_outlined),
                      label: Text(
                        mapPoint == null
                            ? 'Place map pin'
                            : 'Map pin placed · change',
                      ),
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
                    Column(
                      key: submitArea,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (error != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.s12),
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                error!,
                                key: const ValueKey('publishError'),
                                style: AppTextStyles.formError,
                              ),
                            ),
                          ),
                        if (busy)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.s12),
                            child: Text(
                              slowSave
                                  ? 'Still waiting for Firebase. Check your internet connection. Your save is still in progress.'
                                  : 'Saving your opportunity…',
                              style: AppTextStyles.bodyMuted,
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: busy ? null : _publish,
                            icon: busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.arrow_forward),
                            label:
                                Text(busy ? 'Saving…' : 'Publish opportunity'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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
      initialDate:
          date != null && !date!.isBefore(DateUtils.dateOnly(DateTime.now()))
              ? date!
              : DateTime.now(),
    );
    if (picked != null) setState(() => date = picked);
  }

  String _clock(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  Widget _timePicker(BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: _timePicker,
    );
    if (picked != null) setState(() => start = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: end ?? const TimeOfDay(hour: 12, minute: 0),
      builder: _timePicker,
    );
    if (picked != null && mounted) setState(() => end = picked);
  }

  Future<void> _publish() async {
    if (busy) return;
    FocusScope.of(context).unfocus();
    final missing = <String>[
      if (title.text.trim().isEmpty) 'title',
      if (organization.text.trim().isEmpty) 'Host',
      if (place.text.trim().isEmpty) 'location',
      if (description.text.trim().isEmpty) 'description',
      if (date == null) 'date',
      if (start == null) 'start time',
      if (end == null) 'end time',
      if (mapPoint == null) 'map pin (choose Use this location)',
      if ((int.tryParse(spots.text) ?? 0) <= 0 ||
          (int.tryParse(spots.text) ?? 0) > 10000)
        'volunteer count between 1 and 10000',
    ];
    if (missing.isNotEmpty) {
      setState(() => error = 'Please add: ${missing.join(', ')}.');
      revealSubmitArea();
      return;
    }
    if (title.text.trim().length > 200 ||
        description.text.trim().length > 10000) {
      setState(
        () => error =
            'Keep the title within 200 characters and the description within 10000 characters.',
      );
      revealSubmitArea();
      return;
    }

    if (end!.hour * 60 + end!.minute <= start!.hour * 60 + start!.minute) {
      setState(
        () => error =
            'Choose an end time later than the start time on the same date.',
      );
      revealSubmitArea();
      return;
    }
    final opportunity = Opportunity(
      id: draftId,
      removeCoverImage: removePhoto,
      attendeeCount: widget.existing?.attendeeCount ?? 0,
      endsAt: DateTime(
        date!.year,
        date!.month,
        date!.day,
        end!.hour,
        end!.minute,
      ),
      ownerId: widget.existing?.ownerId ?? '',
      coverImageUrl: widget.existing?.coverImageUrl,
      imageUrls: widget.existing?.imageUrls ?? const [],
      startsAt: DateTime(
        date!.year,
        date!.month,
        date!.day,
        start!.hour,
        start!.minute,
      ),
      organization: organization.text.trim(),
      title: title.text.trim(),
      date: date == null ? 'New' : '${date!.day} ${_month(date!.month)}',
      time: '${_clock(start!)}${end == null ? '' : ' – ${_clock(end!)}'}',
      place: place.text.trim(),
      distance: 'New',
      category: category,
      description: description.text.trim(),
      spots: int.tryParse(spots.text) ?? 4,
      icon: Icons.people_outline_rounded,
      latitude: mapPoint!.latitude,
      longitude: mapPoint!.longitude,
    );

    setState(() {
      busy = true;
      error = null;
      slowSave = false;
    });
    revealSubmitArea();
    saveTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && busy) {
        setState(() => slowSave = true);
        revealSubmitArea();
      }
    });
    try {
      await widget.onSave(opportunity, photo);
      if (!mounted) return;
      setState(() => busy = false);
      widget.onPublished(opportunity);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => error = publishError(e));
        revealSubmitArea();
      }
    } finally {
      saveTimer?.cancel();
      if (mounted) setState(() => busy = false);
    }
  }

  void revealSubmitArea() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = submitArea.currentContext;
      if (mounted && target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 200),
          alignment: 1,
        );
      }
    });
  }

  String publishError(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'permission-denied' || error.code == 'unauthorized') {
        return 'Firebase rejected the save. Check that you are signed in and the latest Firestore rules are published. (${error.code})';
      }
      if (error.code == 'unavailable' ||
          error.code == 'network-request-failed') {
        return 'Could not reach Firebase. Check your internet connection and try again. (${error.code})';
      }
      return 'Could not publish: ${error.message ?? error.code} (${error.code})';
    }
    return 'Could not publish: $error';
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
