import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import '../widgets/section_title.dart';

const gothenburg = LatLng(57.7007, 11.9680);
const areaCenters = <String, LatLng>{
  'Majorna': LatLng(57.6952, 11.9187),
  'Centrum': gothenburg,
  'Hisingen': LatLng(57.7210, 11.9432),
  'Linné': LatLng(57.6969, 11.9528),
  'Haga': LatLng(57.6987, 11.9555),
  'Kvillebäcken': LatLng(57.7225, 11.9465),
};

class MapScreen extends StatefulWidget {
  final List<Opportunity> opportunities;
  final ValueChanged<Opportunity> onOpen;
  final String area;
  const MapScreen(
      {super.key,
      required this.opportunities,
      required this.onOpen,
      required this.area});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final controller = MapController();
  LatLng? userLocation;

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.area != oldWidget.area) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.move(areaCenters[widget.area] ?? gothenburg, 12.5);
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Opportunity? get closest {
    if (userLocation == null) return null;
    final located = widget.opportunities
        .where((o) => o.latitude != null && o.longitude != null)
        .toList();
    if (located.isEmpty) return null;
    located.sort((a, b) => Geolocator.distanceBetween(userLocation!.latitude,
            userLocation!.longitude, a.latitude!, a.longitude!)
        .compareTo(Geolocator.distanceBetween(userLocation!.latitude,
            userLocation!.longitude, b.latitude!, b.longitude!)));
    return located.first;
  }

  Future<void> _locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message('Turn on location services to find nearby opportunities.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _message('Location access is off. You can still browse the map.');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() => userLocation = point);
      controller.move(point, 14);
    } catch (_) {
      _message('Could not get your location. Try again or browse the map.');
    }
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final nearby = closest;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      const SectionTitle(
          kicker: 'EXPLORE GOTHENBURG', title: 'Help close to home'),
      const SizedBox(height: 14),
      SizedBox(
          height: 390,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.r24),
              child: Stack(children: [
                FlutterMap(
                  mapController: controller,
                  options: MapOptions(
                      initialCenter: areaCenters[widget.area] ?? gothenburg,
                      initialZoom: 12.5),
                  children: [
                    TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'se.goodtogether.app'),
                    MarkerLayer(markers: [
                      for (final item in widget.opportunities)
                        if (item.latitude != null && item.longitude != null)
                          Marker(
                              point: LatLng(item.latitude!, item.longitude!),
                              width: 48,
                              height: 48,
                              child: IconButton.filled(
                                  tooltip: item.title,
                                  style: IconButton.styleFrom(
                                      backgroundColor: AppColors.navy,
                                      foregroundColor: AppColors.white),
                                  onPressed: () => widget.onOpen(item),
                                  icon: Icon(item.icon))),
                      if (userLocation != null)
                        Marker(
                            point: userLocation!,
                            width: 44,
                            height: 44,
                            child: const Icon(Icons.my_location,
                                color: AppColors.darkBlue,
                                size: AppIconSizes.s34)),
                    ]),
                  ],
                ),
                Positioned(
                    right: 12,
                    bottom: 38,
                    child: FloatingActionButton(
                      heroTag: 'locate',
                      mini: true,
                      tooltip: 'Use my location',
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.navy,
                      onPressed: _locate,
                      child: const Icon(Icons.my_location),
                    )),
                Positioned(
                    left: 8,
                    bottom: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: .88),
                          borderRadius: BorderRadius.circular(AppRadii.r4)),
                      child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.s5,
                              vertical: AppSpacing.s2),
                          child: Text('© OpenStreetMap contributors',
                              style: AppTextStyles.captionNavy)),
                    )),
              ]))),
      const SizedBox(height: 12),
      if (nearby != null)
        ListTile(
            tileColor: AppColors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.r18)),
            leading: Icon(nearby.icon, color: AppColors.navy),
            title: Text(nearby.title,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: const Text('Nearest to your location'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => widget.onOpen(nearby))
      else
        const Padding(
            padding: EdgeInsets.all(AppSpacing.s12),
            child: Text(
                'Tap a marker to view an opportunity, or use the location button to find the closest one.')),
    ]);
  }
}
