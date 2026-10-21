import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/opportunity.dart';
import '../data/city_areas.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';
import '../widgets/section_title.dart';

export '../data/city_areas.dart' show gothenburg;

class MapScreen extends StatefulWidget {
  final List<Opportunity> opportunities;
  final ValueChanged<Opportunity> onOpen;
  final String area;
  const MapScreen({
    super.key,
    required this.opportunities,
    required this.onOpen,
    required this.area,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final controller = MapController();
  LatLng? userLocation;
  String? selectedId;
  final mapKey = GlobalKey();

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.opportunities.any((e) => e.id == selectedId)) selectedId = null;
    if (widget.area != oldWidget.area) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.move(
              areaCenters[widget.area] ?? gothenburg, areaZoom(widget.area));
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
    located.sort(
      (a, b) => Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation!.longitude,
        a.latitude!,
        a.longitude!,
      ).compareTo(
        Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          b.latitude!,
          b.longitude!,
        ),
      ),
    );
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

  void _select(Opportunity item) {
    setState(() => selectedId = item.id);
    if (item.latitude == null || item.longitude == null) {
      _message(
        'This opportunity has no map pin. Use the arrow to view its details.',
      );
      return;
    }
    controller.move(LatLng(item.latitude!, item.longitude!), 15);
    final mapContext = mapKey.currentContext;
    if (mapContext != null) {
      Scrollable.ensureVisible(
        mapContext,
        duration: const Duration(milliseconds: 300),
        alignment: 0.05,
      );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionTitle(
          kicker: 'EXPLORE GOTHENBURG',
          title: 'Help close to home',
        ),
        const SizedBox(height: 14),
        SizedBox(
          key: mapKey,
          height: 390,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.r24),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: controller,
                  options: MapOptions(
                    initialCenter: areaCenters[widget.area] ?? gothenburg,
                    initialZoom: areaZoom(widget.area),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'se.goodtogether.app',
                    ),
                    MarkerLayer(
                      markers: [
                        for (final item in widget.opportunities)
                          if (item.latitude != null && item.longitude != null)
                            Marker(
                              point: LatLng(item.latitude!, item.longitude!),
                              width: selectedId == item.id ? 64 : 48,
                              height: selectedId == item.id ? 64 : 48,
                              child: IconButton.filled(
                                tooltip: '${item.title} · ${item.category}',
                                style: IconButton.styleFrom(
                                  backgroundColor: CategoryStyle.forCategory(
                                    item.category,
                                  ).color,
                                  side: selectedId == item.id
                                      ? const BorderSide(
                                          color: AppColors.white,
                                          width: 3,
                                        )
                                      : BorderSide.none,
                                  foregroundColor: AppColors.white,
                                ),
                                onPressed: () {
                                  _select(item);
                                  widget.onOpen(item);
                                },
                                icon: Icon(
                                  CategoryStyle.forCategory(item.category).icon,
                                  size: selectedId == item.id ? 32 : 24,
                                ),
                              ),
                            ),
                        if (userLocation != null)
                          Marker(
                            point: userLocation!,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.my_location,
                              color: AppColors.darkBlue,
                              size: AppIconSizes.s34,
                            ),
                          ),
                      ],
                    ),
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
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s5,
                        vertical: AppSpacing.s2,
                      ),
                      child: Text(
                        '© OpenStreetMap contributors',
                        style: AppTextStyles.captionNavy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${widget.opportunities.length} opportunities',
          style: AppTextStyles.bodyMedium,
        ),
        if (widget.opportunities.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No opportunities match these filters.'),
          ),
        for (final item in widget.opportunities)
          Card(
            child: ListTile(
              selected: selectedId == item.id,
              selectedTileColor: AppColors.paleGreen,
              leading: Icon(
                CategoryStyle.forCategory(item.category).icon,
                color: CategoryStyle.forCategory(item.category).color,
              ),
              title: Text(item.title),
              subtitle: Text(
                '${item.date} · ${item.time}\n${item.place}${item.latitude == null || item.longitude == null ? ' · No map pin' : ''}',
              ),
              isThreeLine: true,
              onTap: () => _select(item),
              trailing: IconButton(
                tooltip: 'View opportunity',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => widget.onOpen(item),
              ),
            ),
          ),
        if (nearby != null)
          ListTile(
            tileColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r18),
            ),
            leading: Icon(nearby.icon, color: AppColors.navy),
            title: Text(
              nearby.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text('Nearest to your location'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => widget.onOpen(nearby),
          )
        else
          const Padding(
            padding: EdgeInsets.all(AppSpacing.s12),
            child: Text(
              'Tap a marker to view an opportunity, or use the location button to find the closest one.',
            ),
          ),
      ],
    );
  }
}
