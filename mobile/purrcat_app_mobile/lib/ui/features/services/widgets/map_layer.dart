import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../ui/core/theme.dart';

class MapLayer extends StatelessWidget {
  const MapLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Placeholder Map ──
        Container(
          color: const Color(0xFFE8F0FE),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 48, color: Color(0xFFB0BEC5)),
                SizedBox(height: 8),
                Text(
                  'Map View\n(Google Maps / Mapbox)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF90A4AE),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Custom Marker: Paws Clinic ──
        Positioned(
          left: 60,
          top: 40,
          child: _CustomMarker(
            label: 'PAWS',
            subLabel: 'CLINIC',
            icon: Icons.medical_services,
            color: const Color(0xFF8B1A4A), // Dark Pink/Maroon
          ),
        ),

        // ── Custom Marker: Fluff & Buff ──
        Positioned(
          right: 100,
          bottom: 80,
          child: _CustomMarker(
            label: 'FLUFF',
            subLabel: '& BUFF',
            icon: Icons.content_cut,
            color: brandPink,
          ),
        ),

        // ── My Location FAB ──
        Positioned(
          right: 16,
          bottom: 16,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location,
                color: brandPink,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomMarker extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final Color color;

  const _CustomMarker({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pin icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        // Label
        Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              subLabel,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
