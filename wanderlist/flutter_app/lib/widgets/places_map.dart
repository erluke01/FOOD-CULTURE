import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../models/place.dart';
import '../theme.dart';

class PlacesMap extends StatelessWidget {
  final List<Place> places;
  final double zoom;

  const PlacesMap({super.key, required this.places, this.zoom = 12});

  @override
  Widget build(BuildContext context) {
    final withCoords = places.where((p) => p.lat != null && p.lng != null).toList();
    final center = withCoords.isEmpty
        ? const LatLng(45.4654, 9.1859) // default: Milano
        : _computeCenter(withCoords);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.wanderlist.app',
        ),
        MarkerLayer(
          markers: withCoords.map((p) => Marker(
            point: LatLng(p.lat!, p.lng!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showPopup(context, p),
              child: _MapMarker(type: p.type),
            ),
          )).toList(),
        ),
      ],
    );
  }

  LatLng _computeCenter(List<Place> places) {
    final lats = places.map((p) => p.lat!);
    final lngs = places.map((p) => p.lng!);
    return LatLng(
      (lats.reduce((a, b) => a + b)) / places.length,
      (lngs.reduce((a, b) => a + b)) / places.length,
    );
  }

  void _showPopup(BuildContext context, Place p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            if (p.category != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(p.category!, style: const TextStyle(fontSize: 13, color: AppTheme.inkLight)),
              ),
            if (p.avgScore != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(children: [
                  Icon(Icons.star, size: 16, color: AppTheme.terra),
                  const SizedBox(width: 4),
                  Text(p.avgScore!.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.terra)),
                ]),
              ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(ctx); context.push('/place/${p.id}'); },
                  child: const Text('Vedi dettagli'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final String type;
  const _MapMarker({required this.type});

  @override
  Widget build(BuildContext context) {
    final isFood = type == 'food';
    return Container(
      decoration: BoxDecoration(
        color: isFood ? AppTheme.terra : AppTheme.sage,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Text(isFood ? '🍽' : '🗺', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
