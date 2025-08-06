import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/supabase_service.dart';
import 'background_location_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Timer? _locationTimer;
  bool _isMonitoring = false;
  bool _isAtCollege = false;

  // Callback for showing popup notifications
  Function(String)? _onAttendanceMarked;

  void setAttendanceCallback(Function(String) callback) {
    _onAttendanceMarked = callback;
  }

  // Replace these with your college coordinates
  static const double COLLEGE_LAT = 32.2886175; // Your college latitude
  static const double COLLEGE_LNG = 72.2773874; // Your college longitude
  static const double ATTENDANCE_RADIUS = 100; // 100 meters radius

  // Initialize location service
  Future<void> initialize() async {
    print('📍 LocationService: Initializing location service...');

    // Request permissions
    await _requestPermissions();

    // Initialize background service
    await _initializeBackgroundService();

    // Check initial location
    await _checkCurrentLocation();
  }

  // Initialize background location service
  Future<void> _initializeBackgroundService() async {
    try {
      final backgroundService = BackgroundLocationService();
      await backgroundService.initialize();
      print('✅ LocationService: Background service initialized');
    } catch (error) {
      print('❌ LocationService: Error initializing background service: $error');
    }
  }

  // Request location permissions
  Future<void> _requestPermissions() async {
    print('📍 LocationService: Requesting location permissions...');

    // First check current permission status
    Map<Permission, PermissionStatus> currentStatuses = {
      Permission.location: await Permission.location.status,
      Permission.locationWhenInUse: await Permission.locationWhenInUse.status,
      Permission.locationAlways: await Permission.locationAlways.status,
    };
    print('📍 LocationService: Current permission statuses: $currentStatuses');

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📍 LocationService: Location services enabled: $serviceEnabled');

    if (!serviceEnabled) {
      print('❌ LocationService: Location services are disabled');
      throw Exception(
        'Please enable location services in your device settings',
      );
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ].request();

    print('📍 LocationService: After request permission statuses: $statuses');

    if (statuses[Permission.location] != PermissionStatus.granted) {
      print('❌ LocationService: Location permission denied');
      throw Exception(
        'Location permission is required for attendance marking. Please grant location permission in app settings.',
      );
    }

    print('✅ LocationService: All location permissions granted');
  }

  // Start monitoring location
  void startLocationMonitoring() {
    if (_isMonitoring) return;

    print('📍 LocationService: Starting location monitoring...');
    _isMonitoring = true;

    // Check location every 2 minutes
    _locationTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      print('📍 LocationService: Timer triggered - checking location...');
      _checkCurrentLocation();
    });

    // Also check immediately when starting
    print('📍 LocationService: Performing initial location check...');
    _checkCurrentLocation();
  }

  // Stop monitoring location
  void stopLocationMonitoring() {
    print('📍 LocationService: Stopping location monitoring...');
    _isMonitoring = false;
    _locationTimer?.cancel();
  }

  // Check current location and mark attendance if at college
  Future<void> _checkCurrentLocation() async {
    try {
      print('📍 LocationService: Checking current location...');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
        '📍 LocationService: Current position - Lat: ${position.latitude}, Lng: ${position.longitude}',
      );

      double distance = _calculateDistance(
        position.latitude,
        position.longitude,
        COLLEGE_LAT,
        COLLEGE_LNG,
      );

      print(
        '📍 LocationService: Distance from college: ${distance.toStringAsFixed(2)}m (Radius: ${ATTENDANCE_RADIUS}m)',
      );

      bool currentlyAtCollege = distance <= ATTENDANCE_RADIUS;
      print('📍 LocationService: Currently at college: $currentlyAtCollege');

      if (currentlyAtCollege && !_isAtCollege) {
        // Just arrived at college
        print('🎯 LocationService: ==========================================');
        print('🎯 LocationService: 🎯 USER ARRIVED AT COLLEGE!');
        print(
          '🎯 LocationService: 📍 Distance: ${distance.toStringAsFixed(2)}m',
        );
        print('🎯 LocationService: 🚀 TRIGGERING API CALL...');
        print('🎯 LocationService: ==========================================');
        await _markAttendance();
        _isAtCollege = true;
      } else if (!currentlyAtCollege && _isAtCollege) {
        // Just left college
        print('🎯 LocationService: ==========================================');
        print('🎯 LocationService: 🎯 USER LEFT COLLEGE!');
        print(
          '🎯 LocationService: 📍 Distance: ${distance.toStringAsFixed(2)}m',
        );
        print('🎯 LocationService: 🚀 TRIGGERING API CALL...');
        print('🎯 LocationService: ==========================================');
        await _markDeparture();
        _isAtCollege = false;
      } else if (currentlyAtCollege) {
        print(
          '📍 LocationService: At college (distance: ${distance.toStringAsFixed(2)}m)',
        );
      } else {
        print(
          '📍 LocationService: Not at college (distance: ${distance.toStringAsFixed(2)}m)',
        );
      }
    } catch (error) {
      print('❌ LocationService: Error checking location: $error');
      // Re-throw the error so it can be handled by the caller
      rethrow;
    }
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  // Mark attendance when arriving at college
  Future<void> _markAttendance() async {
    try {
      print('🎯 LocationService: ==========================================');
      print('🎯 LocationService: 🚀 API CALL TRIGGERED - USER REACHED COLLEGE');
      print(
        '🎯 LocationService: 📍 College Location: ($COLLEGE_LAT, $COLLEGE_LNG)',
      );
      print('🎯 LocationService: ⏰ Time: ${DateTime.now()}');
      print('🎯 LocationService: ==========================================');

      // Get current user
      final supabaseService = SupabaseService();
      final currentUser = supabaseService.currentUser;

      if (currentUser == null) {
        print('❌ LocationService: No user logged in');
        return;
      }

      print('👤 LocationService: User ID: ${currentUser.id}');

      // Check today's attendance first
      final todayAttendance = await supabaseService.client
          .from('attendance')
          .select('*')
          .eq('user_id', currentUser.id)
          .eq('date', DateTime.now().toIso8601String().split('T')[0])
          .maybeSingle();

      // Check if already checked in today
      if (todayAttendance != null && todayAttendance['check_in_time'] != null) {
        print('📝 LocationService: Already checked in today');

        // Also check if user has already checked out today
        if (todayAttendance['check_out_time'] != null) {
          print(
            '📝 LocationService: Already checked out today, skipping check-in',
          );
          return;
        }

        return;
      }

      print('📞 LocationService: Calling Supabase API: mark_check_in()');

      // Mark check-in using the new attendance system
      final response = await supabaseService.client.rpc(
        'mark_check_in',
        params: {
          'user_uuid': currentUser.id,
          'check_in_lat': COLLEGE_LAT,
          'check_in_lng': COLLEGE_LNG,
        },
      );

      print('✅ LocationService: ==========================================');
      print('✅ LocationService: 🎉 API CALL SUCCESSFUL!');
      print('✅ LocationService: 📊 Response: $response');
      print('✅ LocationService: ==========================================');

      // Show notification or update UI
      _showAttendanceNotification('Check-in marked! Welcome to college.');

      // Call the attendance callback to refresh UI
      if (_onAttendanceMarked != null) {
        _onAttendanceMarked!('Check-in marked successfully!');
      }
    } catch (error) {
      print('❌ LocationService: ==========================================');
      print('❌ LocationService: 🚨 API CALL FAILED!');
      print('❌ LocationService: Error: $error');
      print('❌ LocationService: ==========================================');
    }
  }

  // Mark departure when leaving college
  Future<void> _markDeparture() async {
    try {
      print('🎯 LocationService: ==========================================');
      print('🎯 LocationService: 🚀 API CALL TRIGGERED - USER LEFT COLLEGE');
      print(
        '🎯 LocationService: 📍 College Location: ($COLLEGE_LAT, $COLLEGE_LNG)',
      );
      print('🎯 LocationService: ⏰ Time: ${DateTime.now()}');
      print('🎯 LocationService: ==========================================');

      final supabaseService = SupabaseService();
      final currentUser = supabaseService.currentUser;

      if (currentUser == null) {
        print('❌ LocationService: No user logged in');
        return;
      }

      print('👤 LocationService: User ID: ${currentUser.id}');
      print('📞 LocationService: Calling Supabase API: mark_check_out()');

      // Mark check-out using the new attendance system
      final response = await supabaseService.client.rpc(
        'mark_check_out',
        params: {
          'user_uuid': currentUser.id,
          'check_out_lat': COLLEGE_LAT,
          'check_out_lng': COLLEGE_LNG,
        },
      );

      print('✅ LocationService: ==========================================');
      print('✅ LocationService: 🎉 API CALL SUCCESSFUL!');
      print('✅ LocationService: 📊 Response: $response');
      print('✅ LocationService: ==========================================');

      _showAttendanceNotification('Check-out recorded. Have a great day!');

      // Call the attendance callback to refresh UI
      if (_onAttendanceMarked != null) {
        _onAttendanceMarked!('Check-out recorded successfully!');
      }
    } catch (error) {
      print('❌ LocationService: ==========================================');
      print('❌ LocationService: 🚨 API CALL FAILED!');
      print('❌ LocationService: Error: $error');
      print('❌ LocationService: ==========================================');
    }
  }

  // Show notification (you can customize this)
  void _showAttendanceNotification(String message) {
    print('📱 LocationService: $message');
    // Show popup notification
    _showAttendancePopup(message);
  }

  // Show popup notification
  void _showAttendancePopup(String message) {
    // Use the callback to show popup
    if (_onAttendanceMarked != null) {
      _onAttendanceMarked!(message);
    }
  }

  // Manual attendance check
  Future<void> checkAttendanceManually() async {
    print('📍 LocationService: Manual attendance check...');
    await _checkCurrentLocation();
  }

  // Start background location monitoring
  Future<void> startBackgroundMonitoring() async {
    try {
      print('📍 LocationService: Starting background monitoring...');
      final backgroundService = BackgroundLocationService();
      await backgroundService.startBackgroundMonitoring();
      print('✅ LocationService: Background monitoring started');
    } catch (error) {
      print('❌ LocationService: Error starting background monitoring: $error');
      rethrow;
    }
  }

  // Stop background location monitoring
  Future<void> stopBackgroundMonitoring() async {
    try {
      print('📍 LocationService: Stopping background monitoring...');
      final backgroundService = BackgroundLocationService();
      await backgroundService.stopBackgroundMonitoring();
      print('✅ LocationService: Background monitoring stopped');
    } catch (error) {
      print('❌ LocationService: Error stopping background monitoring: $error');
      rethrow;
    }
  }

  // Check if background monitoring is active
  Future<bool> isBackgroundMonitoringActive() async {
    try {
      final backgroundService = BackgroundLocationService();
      return await backgroundService.isBackgroundMonitoringActive();
    } catch (error) {
      print(
        '❌ LocationService: Error checking background monitoring status: $error',
      );
      return false;
    }
  }

  // Get current location status
  bool get isAtCollege => _isAtCollege;
  bool get isMonitoring => _isMonitoring;
}
