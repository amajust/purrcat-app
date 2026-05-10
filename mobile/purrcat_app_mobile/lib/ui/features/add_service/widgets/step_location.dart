import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../view_models/add_service_provider.dart';
import '../../../../data/models/provider_service_model.dart';
import '../../../../ui/core/theme.dart';

class StepLocation extends StatefulWidget {
  const StepLocation({super.key});

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(-6.200000, 106.816666); // Jakarta fallback

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddServiceProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Service Delivery Type', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('On-Site')),
                selected: provider.serviceType == ServiceType.onSite,
                selectedColor: brandPink,
                backgroundColor: Colors.grey.shade100,
                checkmarkColor: Colors.white,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: provider.serviceType == ServiceType.onSite ? Colors.white : bodyColor,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                onSelected: (val) {
                  if (val) provider.setServiceType(ServiceType.onSite);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Home Visit')),
                selected: provider.serviceType == ServiceType.homeVisit,
                selectedColor: brandPink,
                backgroundColor: Colors.grey.shade100,
                checkmarkColor: Colors.white,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: provider.serviceType == ServiceType.homeVisit ? Colors.white : bodyColor,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                onSelected: (val) {
                  if (val) provider.setServiceType(ServiceType.homeVisit);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        if (provider.serviceType == ServiceType.onSite) ...[
          const Text('Pin Location', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tap on the map to set your clinic/shop location.', style: TextStyle(color: bodyColor, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: provider.location != null 
                      ? LatLng(provider.location!.latitude, provider.location!.longitude)
                      : _center,
                  initialZoom: 13.0,
                  onTap: (tapPosition, point) {
                    provider.setLocation(GeoPoint(point.latitude, point.longitude));
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.znitech.purrfect',
                  ),
                  if (provider.location != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(provider.location!.latitude, provider.location!.longitude),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: brandPink, size: 40),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Full Address', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: provider.locationAddressController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Enter complete address details...',
              border: OutlineInputBorder(),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: brandPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: brandPink),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For Home Visits, you do not need to pin a specific location. You will coordinate the address with the client after booking.',
                    style: TextStyle(color: brandPink),
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }
}
