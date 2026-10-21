import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/supabase_images.dart';
import 'event_photo.dart';

class PhotoEditor extends StatefulWidget {
  final String label;
  final String? reference;
  final Uint8List? selected;
  final bool busy;
  final bool circular;
  final ValueChanged<Uint8List> onSelected;
  final VoidCallback onRemove;
  const PhotoEditor({
    super.key,
    required this.label,
    this.reference,
    this.selected,
    this.busy = false,
    this.circular = false,
    required this.onSelected,
    required this.onRemove,
  });
  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  bool choosing = false;
  Future<void> pick() async {
    setState(() => choosing = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      SupabaseImages.contentType(bytes);
      if (mounted) widget.onSelected(bytes);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not choose photo: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => choosing = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.circular
      ? _profilePhoto()
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.selected != null)
              Image.memory(widget.selected!, height: 140, fit: BoxFit.cover)
            else if (widget.reference != null)
              EventPhoto(
                reference: widget.reference!,
                height: 140,
                width: double.infinity,
              ),
            OutlinedButton.icon(
              onPressed: widget.busy || choosing ? null : pick,
              icon: const Icon(Icons.photo_outlined),
              label: Text(widget.label),
            ),
            if (widget.selected != null || widget.reference != null)
              TextButton.icon(
                onPressed: widget.busy || choosing ? null : widget.onRemove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove photo'),
              ),
          ],
        );

  Widget _profilePhoto() {
    final hasPhoto = widget.selected != null || widget.reference != null;
    return Center(
      child: Column(
        children: [
          Tooltip(
            message:
                hasPhoto ? 'Change profile picture' : 'Add profile picture',
            child: Semantics(
              button: true,
              label:
                  hasPhoto ? 'Change profile picture' : 'Add profile picture',
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.busy || choosing ? null : pick,
                  child: SizedBox(
                    key: const ValueKey('profile-photo-circle'),
                    width: 120,
                    height: 120,
                    child: choosing
                        ? const Center(child: CircularProgressIndicator())
                        : widget.selected != null
                            ? Image.memory(widget.selected!, fit: BoxFit.cover)
                            : widget.reference != null
                                ? EventPhoto(
                                    reference: widget.reference!,
                                    width: 120,
                                    height: 120)
                                : const Icon(Icons.add, size: 48),
                  ),
                ),
              ),
            ),
          ),
          if (hasPhoto)
            TextButton.icon(
              onPressed: widget.busy || choosing ? null : widget.onRemove,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove photo'),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
