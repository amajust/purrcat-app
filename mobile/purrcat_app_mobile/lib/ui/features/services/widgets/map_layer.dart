import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/nearby_service_model.dart';
import '../../../../ui/core/theme.dart';
import '../view_models/services_location_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MapLayer — full-screen interactive map
// ─────────────────────────────────────────────────────────────────────────────

class MapLayer extends StatefulWidget {
  const MapLayer({super.key});

  @override
  State<MapLayer> createState() => MapLayerState();
}

class MapLayerState extends State<MapLayer> with TickerProviderStateMixin {
  final MapController mapController = MapController();

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // ── Pulsing animation for the blue user-dot ───────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── KEY FIX: Register the map-move callback on the provider ──────────
    // When the provider gets a real GPS fix it calls this function directly
    // instead of relying on the next build() cycle — this guarantees the
    // camera snaps to the user's position even before a repaint is triggered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ServicesLocationProvider>().mapMoveCallback =
          (LatLng pos, double zoom) {
        if (!mounted) return;
        // Use MapController.move() for an instant snap (no animation).
        // The recenter FAB uses animateTo() for the smooth fly-in.
        mapController.move(pos, zoom);
      };
    });
  }

  @override
  void dispose() {
    // Clear the callback so the provider doesn't call into a dead widget.
    if (mounted) {
      try {
        context.read<ServicesLocationProvider>().mapMoveCallback = null;
      } catch (_) {}
    }
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Public: smooth animated fly-to (used by the recenter FAB) ────────────
  void animateTo(LatLng target, {double zoom = 15}) {
    final begin = mapController.camera.center;
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final latAnim =
        Tween<double>(begin: begin.latitude, end: target.latitude).animate(
      CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
    );
    final lngAnim =
        Tween<double>(begin: begin.longitude, end: target.longitude).animate(
      CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
    );
    final zoomAnim =
        Tween<double>(begin: mapController.camera.zoom, end: zoom).animate(
      CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
    );

    ctrl.addListener(() {
      mapController.move(
        LatLng(latAnim.value, lngAnim.value),
        zoomAnim.value,
      );
    });
    ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed || s == AnimationStatus.dismissed) {
        ctrl.dispose();
      }
    });
    ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<ServicesLocationProvider>();

    return Stack(
      children: [
        // ── FlutterMap ────────────────────────────────────────────────────
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            // Always start at kDefaultCenter; the mapMoveCallback snaps it
            // to the real position once GPS resolves.
            initialCenter: kDefaultCenter,
            initialZoom: 13,
            minZoom: 10,
            maxZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onTap: (pos, point) => loc.selectService(null),
          ),
          children: [
            // ── OSM tile layer (zero-cost, no API key) ────────────────────
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.purrcat.app',
              maxNativeZoom: 19,
            ),

            // ── Nearby service markers ─────────────────────────────────────
            MarkerLayer(
              markers: loc.nearbyServices
                  .map<Marker>((svc) => _buildServiceMarker(svc, loc))
                  .toList(),
            ),

            // ── User blue dot — only shown when we have real GPS ──────────
            if (loc.hasRealLocation)
              MarkerLayer(
                markers: [
                  Marker(
                    point: loc.userPosition,
                    width: 60,
                    height: 60,
                    child: _UserDot(pulseAnim: _pulseAnim),
                  ),
                ],
              ),

            // ── OSM attribution (required by tile policy) ─────────────────
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),

        // ── Full-screen GPS loading overlay ───────────────────────────────
        // Shown while we're waiting for the permission dialog / GPS fix.
        // This prevents the user seeing a blank Jakarta map before GPS resolves.
        if (loc.isLocating) const _GpsLoadingOverlay(),
      ],
    );
  }

  Marker _buildServiceMarker(NearbyService svc, ServicesLocationProvider loc) {
    final isSelected = loc.selectedService?.id == svc.id;
    final color =
        svc.type == ServiceType.vet ? const Color(0xFF8B1A4A) : brandPink;
    final icon = svc.type == ServiceType.vet
        ? Icons.medical_services_rounded
        : Icons.content_cut_rounded;

    return Marker(
      point: svc.position,
      width: 120,
      height: 90,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          loc.selectService(isSelected ? null : svc);
        },
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: _ServiceMarker(
            label: svc.name,
            icon: icon,
            color: color,
            isSelected: isSelected,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GPS Loading Overlay
// ─────────────────────────────────────────────────────────────────────────────

/// Semi-transparent full-screen overlay shown while the GPS fix is pending.
/// Prevents the user seeing the Jakarta default map before their position loads.
class _GpsLoadingOverlay extends StatelessWidget {
  const _GpsLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: brandPink,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Finding your location…',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Waiting for GPS signal',
                style: TextStyle(
                  fontSize: 12,
                  color: bodyColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User position blue dot
// ─────────────────────────────────────────────────────────────────────────────

class _UserDot extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _UserDot({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (ctx, child) => Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36 * pulseAnim.value,
              height: 36 * pulseAnim.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4285F4).withValues(alpha: 0.25),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service pin marker
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceMarker extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;

  const _ServiceMarker({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.85,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : color,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _PinTailPainter(color: color),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter old) => old.color != color;
}
