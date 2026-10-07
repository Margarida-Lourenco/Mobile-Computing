import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class ProfileInfo {
  final String name;
  final String location;
  final String? imageUrl;
  final XFile? selectedImage;

  const ProfileInfo(
      {required this.name,
      required this.location,
      this.imageUrl,
      this.selectedImage});

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
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
  XFile? photo;
  bool busy = false;
  String? error;
  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => busy = true);
    final info = ProfileInfo(
        name: name.text.trim(),
        location: location.text.trim(),
        imageUrl: widget.profile.imageUrl,
        selectedImage: photo);
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
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Your profile',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text(
                      'Update the details shown on My Page and in your greeting.',
                      style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 24),
                  if (photo != null)
                    FutureBuilder(
                        future: photo!.readAsBytes(),
                        builder: (context, s) => s.data == null
                            ? const SizedBox()
                            : Image.memory(s.data!, height: 120)),
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
                                  setState(() =>
                                      error = 'Could not select image: $e');
                                }
                              }
                            },
                      icon: const Icon(Icons.photo),
                      label: const Text('Choose profile picture')),
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
        ));
  }
}
