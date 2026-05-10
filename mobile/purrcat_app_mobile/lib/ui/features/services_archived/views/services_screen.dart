import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../ui/core/theme.dart';
import '../view_models/services_location_provider.dart';
import '../widgets/category_list.dart';
import '../widgets/expert_list.dart';
import '../widgets/map_layer.dart';
import '../widgets/service_mini_card.dart';
import '../widgets/services_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Services Screen — entry point
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps the real screen with a scoped [ServicesLocationProvider] so the
/// provider is created AND available before [_ServicesBody.initState] runs.
///
/// Split into two widgets to ensure Provider is in the tree before any
/// context.read/watch calls happen in initState.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ServicesLocationProvider>(
      create: (_) => ServicesLocationProvider(),
      child: const _ServicesBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ServicesBody — the actual screen that reads the provider
// ─────────────────────────────────────────────────────────────────────────────

class _ServicesBody extends StatefulWidget {
  const _ServicesBody();

  @override
  State<_ServicesBody> createState() => _ServicesBodyState();
}

class _ServicesBodyState extends State<_ServicesBody> {
  final _mapKey = GlobalKey<MapLayerState>();

  @override
  void initState() {
    super.initState();
    // addPostFrameCallback guarantees the Provider tree and MapLayer are both
    // mounted before we call initialise() — prevents "null mapController" race.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ServicesLocationProvider>().initialise();
    });
  }

  // ── GPS Timeout dialog ────────────────────────────────────────────────────
  void _showGpsTimeoutDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.gps_off_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('GPS Timeout')),
          ],
        ),
        content: const Text(
          'Could not get a GPS fix within 20 seconds.\n\n'
          'If you are on an emulator:\n'
          '  1. Open Extended Controls (⋯ button)\n'
          '  2. Go to Location tab\n'
          '  3. Set coordinates and tap Send\n\n'
          'Then tap Retry below.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dCtx);
              context.read<ServicesLocationProvider>().retry();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Permanently denied dialog ─────────────────────────────────────────────
  void _showPermanentlyDeniedDialog() {
    showDialog<void>(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_off_rounded, color: brandPink),
            SizedBox(width: 8),
            Expanded(child: Text('Location Required')),
          ],
        ),
        content: const Text(
          'Location permission is permanently denied.\n\n'
          'Open App Settings → Permissions → Location\n'
          'and set it to "Allow while using the app".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dCtx);
              context.read<ServicesLocationProvider>().openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ── Recenter FAB ──────────────────────────────────────────────────────────
  void _recenter() {
    final pos = context.read<ServicesLocationProvider>().userPosition;
    _mapKey.currentState?.animateTo(pos);
  }

  // ── React to provider status changes for dialogs ─────────────────────────
  // We use a listener pattern in build() instead of initState so we have
  // context available when showing dialogs.
  void _onStatusChanged(ServicesLocationProvider loc, LocationStatus prev) {
    if (loc.status == LocationStatus.gpuTimeout && prev != LocationStatus.gpuTimeout) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showGpsTimeoutDialog();
      });
    }
    if (loc.status == LocationStatus.permanentlyDenied &&
        prev != LocationStatus.permanentlyDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showPermanentlyDeniedDialog();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch status to fire dialogs when state transitions happen.
    final loc = context.watch<ServicesLocationProvider>();

    return Scaffold(
      backgroundColor: scaffoldBg,
      floatingActionButton: _RecenterFab(onTap: _recenter),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _StatusListener(
        onStatusChanged: _onStatusChanged,
        child: Stack(
          children: [
            // ── 1. Full-screen map ──────────────────────────────────────
            Positioned.fill(child: MapLayer(key: _mapKey)),

            // ── 2. Top error / info banner ──────────────────────────────
            _LocationBanner(
              onOpenSettings: _showPermanentlyDeniedDialog,
              onRetry: () =>
                  context.read<ServicesLocationProvider>().retry(),
            ),

            // ── 3. Draggable bottom sheet ───────────────────────────────
            _BottomSheet(isLoadingServices: loc.loadingServices),

            // ── 4. Mini-card (marker tap) ───────────────────────────────
            _MiniCardOverlay(selectedService: loc.selectedService),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status listener — fires callbacks on status transitions
// ─────────────────────────────────────────────────────────────────────────────

class _StatusListener extends StatefulWidget {
  final Widget child;
  final void Function(ServicesLocationProvider loc, LocationStatus prev)
      onStatusChanged;

  const _StatusListener({
    required this.child,
    required this.onStatusChanged,
  });

  @override
  State<_StatusListener> createState() => _StatusListenerState();
}

class _StatusListenerState extends State<_StatusListener> {
  LocationStatus _prev = LocationStatus.idle;

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<ServicesLocationProvider>();
    if (loc.status != _prev) {
      final prev = _prev;
      _prev = loc.status;
      // Schedule the callback after this build frame completes.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onStatusChanged(loc, prev);
      });
    }
    return widget.child;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location error banner
// ─────────────────────────────────────────────────────────────────────────────

class _LocationBanner extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  const _LocationBanner({
    required this.onOpenSettings,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        context.select<ServicesLocationProvider, LocationStatus>((l) => l.status);

    final (show, message, isPermanent) = switch (status) {
      LocationStatus.denied => (
          true,
          'Location denied — showing city centre',
          false,
        ),
      LocationStatus.serviceDisabled => (
          true,
          'GPS is off — enable in device Settings',
          false,
        ),
      LocationStatus.permanentlyDenied => (
          true,
          'Location blocked — tap to open Settings',
          true,
        ),
      LocationStatus.gpuTimeout => (
          true,
          'GPS timeout — tap Retry or check emulator settings',
          false,
        ),
      LocationStatus.error => (
          true,
          'Location error — showing city centre',
          false,
        ),
      _ => (false, '', false),
    };

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      top: show ? MediaQuery.of(context).padding.top + 8 : -60,
      left: 16,
      right: 16,
      child: show
          ? GestureDetector(
              onTap: isPermanent ? onOpenSettings : onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_rounded,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPermanent ? 'Fix' : 'Retry',
                      style: const TextStyle(
                        color: brandPink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Draggable bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final bool isLoadingServices;
  const _BottomSheet({required this.isLoadingServices});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.18,
      maxChildSize: 0.92,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: scaffoldBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    const ServicesHeader(),
                    const SizedBox(height: 12),
                    const CategoryList(),
                    const SizedBox(height: 16),
                    if (isLoadingServices)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: brandPink),
                              SizedBox(height: 12),
                              Text(
                                'Finding nearby experts…',
                                style: TextStyle(
                                    fontSize: 13, color: bodyColor),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const ExpertList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini-card overlay (marker tap)
// ─────────────────────────────────────────────────────────────────────────────

class _MiniCardOverlay extends StatelessWidget {
  final dynamic selectedService;
  const _MiniCardOverlay({this.selectedService});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      bottom: selectedService != null
          ? MediaQuery.of(context).size.height * 0.42 + 8
          : -120,
      left: 0,
      right: 0,
      child: selectedService != null
          ? ServiceMiniCard(
              service: selectedService,
              onClose: () =>
                  context.read<ServicesLocationProvider>().selectService(null),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recenter FAB
// ─────────────────────────────────────────────────────────────────────────────

class _RecenterFab extends StatelessWidget {
  final VoidCallback onTap;
  const _RecenterFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.42 + 12,
      ),
      child: FloatingActionButton.small(
        onPressed: onTap,
        backgroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Recenter map',
        child: const Icon(
          Icons.my_location_rounded,
          color: brandPink,
          size: 22,
        ),
      ),
    );
  }
}
