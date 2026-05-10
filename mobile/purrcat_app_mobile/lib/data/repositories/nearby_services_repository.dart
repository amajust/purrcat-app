import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../models/nearby_service_model.dart';

/// Simulates GET /v1/services/nearby?lat={lat}&long={lng}
///
/// In production, replace the body of [fetchNearbyServices] with a
/// real HTTP call using Dio or http package.
class NearbyServicesRepository {
  static final NearbyServicesRepository _instance =
      NearbyServicesRepository._internal();
  factory NearbyServicesRepository() => _instance;
  NearbyServicesRepository._internal();

  /// Generates mock services within ~5 km of [userLat],[userLng].
  Future<List<NearbyService>> fetchNearbyServices({
    required double userLat,
    required double userLng,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 900));

    final rng = Random(42); // deterministic seed for consistent mock data

    final mockData = <Map<String, dynamic>>[
      {
        'name': 'Paws Clinic',
        'address': 'Jl. Sudirman No.12, Jakarta',
        'type': ServiceType.vet,
        'rating': 4.9,
        'reviews': 124,
        'dLat': 0.012,
        'dLng': -0.018,
        'phone': '+62 21 555-0101',
        'slots': ['09:00', '10:30', '14:00', '16:00'],
      },
      {
        'name': 'MeowWell Animal Hospital',
        'address': 'Jl. Thamrin No.5, Jakarta',
        'type': ServiceType.vet,
        'rating': 4.7,
        'reviews': 89,
        'dLat': -0.021,
        'dLng': 0.009,
        'phone': '+62 21 555-0202',
        'slots': ['08:30', '11:00', '13:30'],
      },
      {
        'name': 'Fluff & Buff Grooming',
        'address': 'Jl. Gatot Subroto No.3, Jakarta',
        'type': ServiceType.groomer,
        'rating': 4.8,
        'reviews': 211,
        'dLat': 0.031,
        'dLng': 0.024,
        'phone': '+62 21 555-0303',
        'slots': ['10:00', '12:00', '15:00', '17:30'],
      },
      {
        'name': 'Kitty Spa & Groom',
        'address': 'Jl. Kebon Jeruk No.8, Jakarta',
        'type': ServiceType.groomer,
        'rating': 4.5,
        'reviews': 67,
        'dLat': -0.038,
        'dLng': -0.012,
        'phone': '+62 21 555-0404',
        'slots': ['09:30', '11:30', '14:30'],
      },
      {
        'name': 'CatCare Veterinary',
        'address': 'Jl. Kuningan No.17, Jakarta',
        'type': ServiceType.vet,
        'rating': 4.6,
        'reviews': 52,
        'dLat': 0.025,
        'dLng': -0.033,
        'phone': '+62 21 555-0505',
        'slots': ['08:00', '10:00', '13:00', '15:30'],
      },
      {
        'name': 'PurrFect Grooming Salon',
        'address': 'Jl. MT Haryono No.2, Jakarta',
        'type': ServiceType.groomer,
        'rating': 4.9,
        'reviews': 178,
        'dLat': -0.014,
        'dLng': 0.041,
        'phone': '+62 21 555-0606',
        'slots': ['10:30', '13:00', '16:30'],
      },
      {
        'name': 'Dr. Whiskers Animal Clinic',
        'address': 'Jl. Casablanca No.9, Jakarta',
        'type': ServiceType.vet,
        'rating': 4.4,
        'reviews': 34,
        'dLat': -0.044,
        'dLng': 0.028,
        'phone': '+62 21 555-0707',
        'slots': ['09:00', '11:30', '14:00'],
      },
    ];

    return mockData.asMap().entries.map((entry) {
      final i = entry.key;
      final m = entry.value;

      // Add tiny random jitter so markers don't overlap perfectly
      final jitterLat = (rng.nextDouble() - 0.5) * 0.003;
      final jitterLng = (rng.nextDouble() - 0.5) * 0.003;

      // Calculate approximate distance
      final lat = userLat + (m['dLat'] as double) + jitterLat;
      final lng = userLng + (m['dLng'] as double) + jitterLng;
      final dist = _haversineKm(userLat, userLng, lat, lng);

      return NearbyService(
        id: 'svc_$i',
        name: m['name'] as String,
        address: m['address'] as String,
        type: m['type'] as ServiceType,
        rating: m['rating'] as double,
        reviewCount: m['reviews'] as int,
        distanceKm: double.parse(dist.toStringAsFixed(1)),
        position: LatLng(lat, lng),
        phone: m['phone'] as String?,
        availableSlots: List<String>.from(m['slots'] as List),
      );
    }).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  /// Simple Haversine formula to compute distance in km.
  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;
}
