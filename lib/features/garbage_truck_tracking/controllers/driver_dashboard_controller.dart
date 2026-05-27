import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../routes/app_routes.dart';
import '../models/driver_route_model.dart';
import '../repositories/driver_repository.dart';

enum DriverAuthState { initial, loading, authenticated, error }

enum DriverShiftState { idle, loading, active, ended, error }

enum DriverRouteState { initial, loading, loaded, error }

class DriverDashboardController extends GetxController {
  final DriverRepository _repository;

  DriverDashboardController(this._repository);

  // ── Auth State ────────────────────────────────
  final authState = DriverAuthState.initial.obs;
  final isLoggedIn = false.obs;
  final driverName = RxnString();
  final loginError = RxnString();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;

  // ── Shift State ───────────────────────────────
  final shiftState = DriverShiftState.idle.obs;
  final shiftStartTime = Rxn<DateTime>();
  final shiftData = Rxn<DriverShiftData>();
  final truckNumber = RxnString();
  final errorMessage = RxnString();

  // ── GPS Location State ────────────────────────
  final currentLatitude = Rxn<double>();
  final currentLongitude = Rxn<double>();
  final currentSpeed = 0.0.obs;
  final currentHeading = Rxn<double>();
  final currentAltitude = Rxn<double>();
  final currentAccuracy = Rxn<double>();
  final isSendingLocation = false.obs;
  final totalLocationsSent = 0.obs;
  final lastLocationSentAt = Rxn<DateTime>();
  Function(double, double)? onLocationUpdate;

  // ── Route State ───────────────────────────────
  final routeState = DriverRouteState.initial.obs;
  final routeData = Rxn<DriverRouteData>();

  // ── Timers ────────────────────────────────────
  Timer? _gpsTimer;
  Timer? _durationTimer;

  // ── Getters ───────────────────────────────────
  bool get isOnShift => shiftState.value == DriverShiftState.active;

  String get shiftDuration {
    if (shiftStartTime.value == null) return '00:00:00';
    final elapsed = DateTime.now().difference(shiftStartTime.value!);
    final h = elapsed.inHours.toString().padLeft(2, '0');
    final m = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  @override
  void onClose() {
    _gpsTimer?.cancel();
    _durationTimer?.cancel();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ── Auth ──────────────────────────────────────

  Future<void> _checkAuth() async {
    final token = await SecureStorageService.to.getToken();
    final role = await SecureStorageService.to.getRole();
    if (token != null && token.isNotEmpty && role == 'driver') {
      authState.value = DriverAuthState.authenticated;
      isLoggedIn.value = true;
      final userData = await SecureStorageService.to.getUserData();
      driverName.value = userData?['name'] ?? 'Driver';
      loadDriverRoute();
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty || phone.length < 10) {
      CustomSnackbar.showError('Please enter a valid 10-digit phone number');
      return;
    }
    if (password.length < 4) {
      CustomSnackbar.showError('Password must be at least 4 characters');
      return;
    }

    authState.value = DriverAuthState.loading;
    try {
      final response = await _repository.login(phone, password);
      if (response.status && response.token != null) {
        await SecureStorageService.to.saveToken(response.token!);
        await SecureStorageService.to.saveRole('driver');
        if (response.driverName != null) {
          await SecureStorageService.to.saveUserData({
            'name': response.driverName,
            'phone': phone,
          });
        }
        driverName.value = response.driverName ?? 'Driver';
        authState.value = DriverAuthState.authenticated;
        isLoggedIn.value = true;
        phoneController.clear();
        passwordController.clear();
        CustomSnackbar.showSuccess('Login successful');
        loadDriverRoute();
      } else {
        loginError.value = response.message;
        authState.value = DriverAuthState.error;
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      loginError.value = e.toString();
      authState.value = DriverAuthState.error;
      CustomSnackbar.showError('Login failed. Please try again.');
    }
  }

  Future<void> logout() async {
    _gpsTimer?.cancel();
    _durationTimer?.cancel();
    _gpsTimer = null;
    _durationTimer = null;

    await SecureStorageService.to.clearAll();

    authState.value = DriverAuthState.initial;
    isLoggedIn.value = false;
    driverName.value = null;
    shiftState.value = DriverShiftState.idle;
    shiftStartTime.value = null;
    shiftData.value = null;
    routeData.value = null;
    routeState.value = DriverRouteState.initial;
    currentLatitude.value = null;
    currentLongitude.value = null;
    currentSpeed.value = 0.0;
    currentHeading.value = null;
    currentAltitude.value = null;
    currentAccuracy.value = null;
    totalLocationsSent.value = 0;
    lastLocationSentAt.value = null;
    truckNumber.value = null;
    errorMessage.value = null;

    Get.offAllNamed(AppRoutes.login);
  }

  // ── Shift ─────────────────────────────────────

  Future<void> startShift() async {
    shiftState.value = DriverShiftState.loading;
    try {
      final position = await _fetchCurrentLocation();
      if (position == null) {
        shiftState.value = DriverShiftState.idle;
        CustomSnackbar.showError(
          'Unable to get location. Please enable GPS.',
        );
        return;
      }

      final res = await _repository.startShift(
        position.latitude,
        position.longitude,
      );

      if (res['status'] == true) {
        shiftState.value = DriverShiftState.active;
        shiftStartTime.value = DateTime.now();
        totalLocationsSent.value = 0;
        _startLocationUpdates();
        _startDurationTimer();
        CustomSnackbar.showSuccess('Shift started successfully');
      } else {
        shiftState.value = DriverShiftState.idle;
        CustomSnackbar.showError(res['message'] ?? 'Failed to start shift');
      }
    } catch (e) {
      shiftState.value = DriverShiftState.error;
      errorMessage.value = e.toString();
      CustomSnackbar.showError('Failed to start shift: ${e.toString()}');
    }
  }

  Future<void> endShift() async {
    shiftState.value = DriverShiftState.loading;
    try {
      final position = await _fetchCurrentLocation();

      _gpsTimer?.cancel();
      _durationTimer?.cancel();
      _gpsTimer = null;
      _durationTimer = null;

      final res = await _repository.endShift(
        position?.latitude ?? 0.0,
        position?.longitude ?? 0.0,
      );

      if (res['status'] == true) {
        shiftState.value = DriverShiftState.ended;
        final data = res['data'];
        if (data != null) {
          shiftData.value = DriverShiftData.fromJson(data);
        }
        CustomSnackbar.showSuccess('Shift ended successfully');
      } else {
        shiftState.value = DriverShiftState.idle;
        CustomSnackbar.showError(res['message'] ?? 'Failed to end shift');
      }
    } catch (e) {
      shiftState.value = DriverShiftState.error;
      errorMessage.value = e.toString();
      CustomSnackbar.showError('Failed to end shift: ${e.toString()}');
    }
  }

  void resetShiftState() {
    shiftState.value = DriverShiftState.idle;
    shiftData.value = null;
    shiftStartTime.value = null;
  }

  // ── GPS & Location ────────────────────────────

  Future<Position?> _fetchCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          CustomSnackbar.showError('Location permission denied');
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        CustomSnackbar.showError(
          'Location permission permanently denied. Please enable in Settings.',
        );
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        CustomSnackbar.showError('GPS service is disabled. Please enable it.');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;
      currentSpeed.value = position.speed * 3.6; // m/s → km/h
      currentHeading.value = position.heading;
      currentAltitude.value = position.altitude;
      currentAccuracy.value = position.accuracy;

      return position;
    } catch (e) {
      CustomSnackbar.showError('Failed to get location: ${e.toString()}');
      return null;
    }
  }

  void _startLocationUpdates() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      await sendLocationUpdate();
    });
  }

  Future<void> sendManualLocationUpdate() async {
    if (!isOnShift) {
      CustomSnackbar.showError('Start your shift first');
      return;
    }
    await sendLocationUpdate();
    CustomSnackbar.showSuccess('Location sent manually');
  }

  Future<void> sendLocationUpdate() async {
    if (isSendingLocation.value) return;
    isSendingLocation.value = true;
    try {
      final position = await _fetchCurrentLocation();
      if (position == null) {
        isSendingLocation.value = false;
        return;
      }

      await _repository.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed * 3.6,
        heading: position.heading,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now().toUtc().toIso8601String(),
      );

      totalLocationsSent.value++;
      lastLocationSentAt.value = DateTime.now();
      onLocationUpdate?.call(position.latitude, position.longitude);
    } catch (e) {
      // Location update failure is logged but not shown to user to avoid spam
      debugPrint('Location update failed: $e');
    } finally {
      isSendingLocation.value = false;
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Force UI rebuild for shift duration
      shiftStartTime.refresh();
    });
  }

  // ── Route ─────────────────────────────────────

  Future<void> loadDriverRoute() async {
    routeState.value = DriverRouteState.loading;
    try {
      final data = await _repository.getAssignedRoute();
      routeData.value = data;
      truckNumber.value = data.truck?.truckNumber;
      routeState.value = DriverRouteState.loaded;
    } catch (e) {
      routeState.value = DriverRouteState.error;
      CustomSnackbar.showError('Failed to load route');
    }
  }
}