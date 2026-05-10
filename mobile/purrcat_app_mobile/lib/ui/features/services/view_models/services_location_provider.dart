import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../data/models/nearby_service_model.dart';
import '../../../../data/repositories/nearby_services_repository.dart';

// ── Fallback city centre (Jakarta) ───────────────────────────────────────────
const LatLng kDefaultCenter = LatLng(-6.2000, 106.8166);

/// All possible states of the location + data fetch pipeline.
enum LocationStatus {
  idle,              // Initial — nothing started yet
  requesting,        // Waiting for OS permission dialog / GPS fix
  granted,           // Real GPS position obtained  ← triggers map move
  denied,            // User denied permission (can retry)
  permanentlyDenied, // User denied forever → must open App Settings
  serviceDisabled,   // Device GPS is switched off
  gpuTimeout,        // GPS timed out (emulator with no mock location)
  error,             // Unexpected error
}

/// Full state for the Services & Nearby screen.
///
/// Key design decisions:
///   • [initialise()] is idempotent — safe to call multiple times.
///   • Services are ONLY loaded AFTER a valid [userPosition] is confirmed.
///   • [mapMoveCallback] is set by MapLayerState so the provider can push
///     the camera to the real coordinates without a separate listener.
///   • A [gpuTimeout] state is emitted when GPS times out so the screen
///     can show a specific "GPS Timeout" dialog (distinct from generic error).
class ServicesLocationProvider extends ChangeNotifier {
  // ── Dependencies ──────────────────────────────────────────────────────────
  final _repo = NearbyServicesRepository();

  // ── State fields ──────────────────────────────────────────────────────────
  LocationStatus _status = LocationStatus.idle;
  LatLng _userPosition = kDefaultCenter; // starts at fallback
  List<NearbyService> _nearbyServices = [];
  NearbyService? _selectedService;
  bool _loadingServices = false;
  String? _errorMessage;

  // ── Callback injected by MapLayerState ────────────────────────────────────
  /// Set by MapLayerState.initState so we can push a MapController.move()
  /// call the moment we have real coordinates — no polling needed.
  void Function(LatLng position, double zoom)? mapMoveCallback;

  // ── Getters ───────────────────────────────────────────────────────────────
  LocationStatus get status => _status;
  LatLng get userPosition => _userPosition;
  List<NearbyService> get nearbyServices => _nearbyServices;
  NearbyService? get selectedService => _selectedService;
  bool get loadingServices => _loadingServices;
  String? get errorMessage => _errorMessage;

  bool get isLocating => _status == LocationStatus.requesting;
  bool get hasRealLocation => _status == LocationStatus.granted;
  bool get isGpsTimeout => _status == LocationStatus.gpuTimeout;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Entry point — call from initState (inside addPostFrameCallback).
  /// Guards against duplicate calls via [_status] == idle check.
  Future<void> initialise() async {
    if (_status != LocationStatus.idle) return;
    await _checkPermissionAndFetch();
  }

  /// Retry after denial, service-disabled, or timeout.
  Future<void> retry() async {
    _status = LocationStatus.idle;
    _errorMessage = null;
    _nearbyServices = [];
    notifyListeners();
    await _checkPermissionAndFetch();
  }

  /// Opens the native App Settings page (for permanently denied).
  Future<void> openSettings() => Geolocator.openAppSettings();

  /// Select / deselect a marker → drives the mini-card.
  void selectService(NearbyService? service) {
    _selectedService = service;
    notifyListeners();
  }

  // ── Private — permission + GPS flow ──────────────────────────────────────

  Future<void> _checkPermissionAndFetch() async {
    _setStatus(LocationStatus.requesting);

    // ── Step 1: Is the device GPS service enabled? ────────────────────────
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setStatus(
        LocationStatus.serviceDisabled,
        error: 'Location services are turned off. '
            'Enable GPS in your device Settings, then tap Retry.',
      );
      // Load services at fallback so the map is not empty
      await _loadServices(_userPosition);
      return;
    }

    // ── Step 2: Check current permission level ────────────────────────────
    LocationPermission permission = await Geolocator.checkPermission();

    // ── Step 3: Show OS dialog if not yet decided ─────────────────────────
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // ── Step 4: Permanently denied → guide to settings ───────────────────
    if (permission == LocationPermission.deniedForever) {
      _setStatus(
        LocationStatus.permanentlyDenied,
        error: 'Location permission is permanently blocked. '
            'Open App Settings → Permissions → Location.',
      );
      await _loadServices(_userPosition);
      return;
    }

    // ── Step 5: Still denied after dialog ─────────────────────────────────
    if (permission == LocationPermission.denied) {
      _setStatus(
        LocationStatus.denied,
        error: 'Location permission denied — showing city centre services.',
      );
      await _loadServices(_userPosition);
      return;
    }

    // ── Step 6: Permission granted — fetch real GPS coordinates ──────────
    //   We use a 20-second timeout so emulators with no mock location
    //   produce a specific [gpuTimeout] state rather than hanging forever.
    await _fetchPositionAndLoad();
  }

  Future<void> _fetchPositionAndLoad() async {
    try {
      final Position pos = await Geolocator.getCurrentPosition(
        // AndroidSettings + AppleSettings give fine-grained control.
        // For max emulator compatibility we also accept MEDIUM accuracy.
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      // ✅ Real coordinates obtained
      _userPosition = LatLng(pos.latitude, pos.longitude);
      _setStatus(LocationStatus.granted); // notifyListeners() inside

      // Push camera to user position immediately via the injected callback.
      // This is the KEY fix: we call mapController.move() from the provider
      // the instant we have coordinates, not on the next build() call.
      mapMoveCallback?.call(_userPosition, 15.0);

      // Load services centred on the REAL user position
      await _loadServices(_userPosition);
    } on TimeoutException {
      // GPS timed out — specific state so the UI can show a targeted dialog
      _setStatus(
        LocationStatus.gpuTimeout,
        error: 'GPS timed out. '
            'Make sure Location is enabled and your emulator has '
            'Mock Location configured (Extended Controls → Location).',
      );
      await _loadServices(_userPosition); // still show fallback markers
    } catch (e) {
      _setStatus(
        LocationStatus.error,
        error: 'Location error: ${e.toString()}. Showing city centre.',
      );
      await _loadServices(_userPosition);
    }
  }

  // ── Private — data fetching ───────────────────────────────────────────────

  /// Load nearby services for [pos]. Called ONLY after position is resolved.
  Future<void> _loadServices(LatLng pos) async {
    _loadingServices = true;
    notifyListeners();
    try {
      _nearbyServices = await _repo.fetchNearbyServices(
        userLat: pos.latitude,
        userLng: pos.longitude,
      );
    } catch (_) {
      _nearbyServices = [];
    } finally {
      _loadingServices = false;
      notifyListeners();
    }
  }

  void _setStatus(LocationStatus s, {String? error}) {
    _status = s;
    _errorMessage = error;
    notifyListeners();
  }
}
