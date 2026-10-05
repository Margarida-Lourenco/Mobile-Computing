import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import 'map_screen.dart';

class PickLocationScreen extends StatefulWidget {
  final LatLng? initialPoint;
  const PickLocationScreen({super.key, this.initialPoint});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  final mapController = MapController();
  LatLng? point;
  Offset? pointerDown;

  @override
  void initState() {
    super.initState();
    point = widget.initialPoint;
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place map pin')),
      body: SafeArea(
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
                'Tap the meeting point on the map so volunteers can find it.'),
          ),
          Expanded(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) => pointerDown = event.localPosition,
              onPointerUp: (event) {
                final start = pointerDown;
                pointerDown = null;
                if (start != null &&
                    (event.localPosition - start).distance < 12) {
                  setState(() => point = mapController.camera
                      .screenOffsetToLatLng(event.localPosition));
                }
              },
              child: Stack(children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                      initialCenter: point ?? gothenburg, initialZoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'se.goodtogether.app',
                    ),
                    if (point != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: point!,
                          width: 48,
                          height: 48,
                          child: const Icon(Icons.location_pin,
                              size: 44, color: AppColors.navy),
                        ),
                      ]),
                  ],
                ),
                Positioned(
                  left: 8,
                  bottom: 6,
                  child: IgnorePointer(
                      child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      child: Text('© OpenStreetMap contributors',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.navy)),
                    ),
                  )),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    point == null ? null : () => Navigator.pop(context, point),
                child: const Text('Use this location'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
