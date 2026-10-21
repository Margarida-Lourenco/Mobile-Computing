import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/photo_editor.dart';

class ProfileInfo {
  final String username;
  final String name;
  final String location;
  final String? imageUrl;
  final Uint8List? selectedImage;
  final bool removeImage;

  const ProfileInfo({
    this.username = '',
    required this.name,
    required this.location,
    this.imageUrl,
    this.selectedImage,
    this.removeImage = false,
  });

  String get displayUsername => username.isEmpty ? name : username;
  String get firstName =>
      username.isEmpty ? name.trim().split(RegExp(r'\s+')).first : username;
  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

class EditInfoScreen extends StatefulWidget {
  final ProfileInfo profile;
  final Future<void> Function(ProfileInfo)? onSave;

  const EditInfoScreen({super.key, required this.profile, this.onSave});

  @override
  State<EditInfoScreen> createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  bool busy = false;
  Uint8List? photo;
  bool removePhoto = false;
  String? error;
  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => busy = true);
    final info = ProfileInfo(
      username: widget.profile.username,
      name: name.text.trim(),
      location: location.text.trim(),
      imageUrl: widget.profile.imageUrl,
      selectedImage: photo,
      removeImage: removePhoto,
    );
    try {
      await widget.onSave?.call(info);
      if (mounted) {
        setState(() => busy = false);
        Navigator.pop(context, info);
      }
    } catch (e) {
      if (mounted) setState(() => error = 'Could not save profile: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController location;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.profile.name);
    location = TextEditingController(text: widget.profile.location);
  }

  @override
  void dispose() {
    name.dispose();
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit info')),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.s20),
              children: [
                const Text('Your profile', style: AppTextStyles.pageTitle),
                const SizedBox(height: 8),
                const Text(
                  'Update the details shown on My Page and in your greeting.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 24),
                PhotoEditor(
                  circular: true,
                  label: 'Choose profile picture',
                  busy: busy,
                  reference: removePhoto ? null : widget.profile.imageUrl,
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
                if (error != null) Text(error!),
                TextFormField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: location,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your location'
                      : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : save,
                  child: const Text('Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
