import 'package:latlong2/latlong.dart';

/// Type of nearby pet service provider.
enum ServiceType { vet, groomer }

/// Represents a single pet service location on the map.
class NearbyService {
  final String id;
  final String name;
  final String address;
  final ServiceType type;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final LatLng position;
  final String? phone;
  final List<String> availableSlots;

  const NearbyService({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.position,
    this.phone,
    required this.availableSlots,
  });

  /// Human-readable type label.
  String get typeLabel => type == ServiceType.vet ? 'Veterinary Clinic' : 'Pet Groomer';
}
