import 'package:flutter/material.dart';
import '../services/supabase_images.dart';
import '../theme/app_theme.dart';

class EventPhoto extends StatefulWidget {
  final String reference;
  final double height;
  final double? width;
  final Widget? fallback;
  const EventPhoto(
      {super.key,
      required this.reference,
      this.height = 180,
      this.width,
      this.fallback});
  @override
  State<EventPhoto> createState() => _EventPhotoState();
}

class _EventPhotoState extends State<EventPhoto> {
  late Future<String> url;
  @override
  void initState() {
    super.initState();
    url = _load();
  }

  Future<String> _load() async =>
      SupabaseImages.instance.signedUrl(widget.reference);
  @override
  void didUpdateWidget(covariant EventPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference) url = _load();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: FutureBuilder<String>(
                future: url,
                builder: (context, snapshot) {
                  final fallback = Center(
                      child: widget.fallback ??
                          const Icon(Icons.image_outlined,
                              color: AppColors.muted));
                  if (!snapshot.hasData) return fallback;
                  return Image.network(snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stack) => fallback);
                })),
      );
}
