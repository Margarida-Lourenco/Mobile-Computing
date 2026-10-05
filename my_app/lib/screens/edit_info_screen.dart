import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileInfo {
  final String name;
  final String location;

  const ProfileInfo({required this.name, required this.location});

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

  const EditInfoScreen({super.key, required this.profile});

  @override
  State<EditInfoScreen> createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit info')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Your profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                  'Update the details shown on My Page and in your greeting.',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 24),
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
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(
                        context,
                        ProfileInfo(
                          name: name.text.trim(),
                          location: location.text.trim(),
                        ));
                  }
                },
                child: const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
