import '../theme/app_theme.dart';
import 'package:flutter/material.dart';

class EventPhoto extends StatelessWidget {
  final String url;
  final double height;
  final double? width;
  const EventPhoto(
      {super.key, required this.url, this.height = 180, this.width});
  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: Image.network(url,
          height: height,
          width: width,
          fit: BoxFit.cover,
          loadingBuilder: (c, w, p) => p == null
              ? w
              : SizedBox(
                  height: height,
                  width: width,
                  child: const Center(child: CircularProgressIndicator())),
          errorBuilder: (c, e, s) => SizedBox(
              height: height,
              width: width,
              child: const Icon(Icons.image_not_supported_outlined))));
}
