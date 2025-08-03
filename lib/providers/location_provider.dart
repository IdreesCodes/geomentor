import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationNotifier extends StateNotifier<AsyncValue<bool>> {
  final LocationService _locationService;
  Function(String)? _onAttendanceMarked;

  LocationNotifier(this._locationService) : super(const AsyncValue.data(false));

  void setAttendanceCallback(Function(String) callback) {
    _onAttendanceMarked = callback;
    _locationService.setAttendanceCallback(callback);
  }

  Future<void> initializeLocation() async {
    try {
      print('📍 LocationProvider: Initializing location...');
      state = const AsyncValue.loading();
      await _locationService.initialize();
      print('📍 LocationProvider: Location initialization completed');
      state = const AsyncValue.data(true);
    } catch (error) {
      print('❌ LocationProvider: Location initialization failed - $error');
      state = AsyncValue.error(error, StackTrace.current);

      // If it's a permission error, we should show a dialog
      if (error.toString().contains('permission')) {
        print(
          '📍 LocationProvider: Permission error detected - should show settings dialog',
        );
      }
    }
  }

  void startMonitoring() {
    print('📍 LocationProvider: Starting location monitoring...');
    _locationService.startLocationMonitoring();
    print('📍 LocationProvider: Location monitoring started');
  }

  void stopMonitoring() {
    _locationService.stopLocationMonitoring();
  }

  Future<void> checkAttendanceManually() async {
    try {
      await _locationService.checkAttendanceManually();
    } catch (error) {
      print('❌ LocationProvider: Manual attendance check failed - $error');
      rethrow;
    }
  }

  bool get isAtCollege => _locationService.isAtCollege;
  bool get isMonitoring => _locationService.isMonitoring;
}

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<bool>>((ref) {
      final locationService = ref.watch(locationServiceProvider);
      return LocationNotifier(locationService);
    });
