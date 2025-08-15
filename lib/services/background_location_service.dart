import 'dart:async';
// Removed unused: dart:convert, flutter/material.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'supabase_service.dart';

class BackgroundLocationService {
  static final BackgroundLocationService _instance =
      BackgroundLocationService._internal();
  factory BackgroundLocationService() => _instance;
  BackgroundLocationService._internal();

  static const String _locationTaskName = 'locationTask';

  // College coordinates
  static const double COLLEGE_LAT = 32.2886175;
  static const double COLLEGE_LNG = 72.2773874;
  static const double ATTENDANCE_RADIUS = 100; // 100 meters

  // Notification channels
  static const String _locationChannelId = 'location_channel';
  static const String _attendanceChannelId = 'attendance_channel';

  late FlutterLocalNotificationsPlugin _notifications;
  bool _isInitialized = false;

  // Initialize the background service
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('🔄 BackgroundLocationService: Initializing background service...');

    // Initialize notifications
    await _initializeNotifications();

    // Initialize WorkManager
    await _initializeWorkManager();

    // Request permissions
    await _requestPermissions();

    _isInitialized = true;
    print('✅ BackgroundLocationService: Background service initialized');
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    _notifications = FlutterLocalNotificationsPlugin();

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  // Create notification channels
  Future<void> _createNotificationChannels() async {
    // Location monitoring channel
    const locationChannel = AndroidNotificationChannel(
      _locationChannelId,
      'Location Monitoring',
      description: 'Notifications for location monitoring',
      importance: Importance.low,
    );

    // Attendance channel
    const attendanceChannel = AndroidNotificationChannel(
      _attendanceChannelId,
      'Attendance',
      description: 'Notifications for attendance marking',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(locationChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(attendanceChannel);
  }

  // Initialize WorkManager
  Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    print('🔄 BackgroundLocationService: Requesting permissions...');

    // Request location permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
      Permission.notification,
    ].request();

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Verify permissions
    if (statuses[Permission.location] != PermissionStatus.granted ||
        statuses[Permission.locationAlways] != PermissionStatus.granted) {
      throw Exception(
        'Location permissions are required for background monitoring',
      );
    }

    print('✅ BackgroundLocationService: All permissions granted');
  }

  // Start background location monitoring
  Future<void> startBackgroundMonitoring() async {
    print('🔄 BackgroundLocationService: Starting background monitoring...');

    // Register periodic task
    await Workmanager().registerPeriodicTask(
      _locationTaskName,
      _locationTaskName,
      frequency: Duration(minutes: 15), // Minimum 15 minutes for periodic tasks
      constraints: Constraints(networkType: NetworkType.connected),
    );

    // Show persistent notification
    await _showMonitoringNotification();
  }

  // Stop background location monitoring
  Future<void> stopBackgroundMonitoring() async {
    print('🔄 BackgroundLocationService: Stopping background monitoring...');

    // Cancel the periodic task
    await Workmanager().cancelByUniqueName(_locationTaskName);

    // Cancel persistent notification
    await _notifications.cancel(888);
  }

  // Show monitoring notification
  Future<void> _showMonitoringNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _locationChannelId,
      'Location Monitoring',
      channelDescription: 'Background location monitoring is active',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      888,
      'GeoMentor',
      'Location monitoring active',
      notificationDetails,
    );
  }

  // Show attendance notification
  Future<void> showAttendanceNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _attendanceChannelId,
      'Attendance',
      channelDescription: 'Attendance notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
    );
  }

  // Check if background monitoring is active
  Future<bool> isBackgroundMonitoringActive() async {
    // This is a simplified check - in a real app you'd store this state
    return true; // Assume active if service is initialized
  }

  // Temporarily pause background monitoring (for manual check-out)
  Future<void> pauseBackgroundMonitoring() async {
    print('🔄 BackgroundLocationService: Pausing background monitoring...');
    // Cancel the current task
    await Workmanager().cancelByUniqueName(_locationTaskName);
  }

  // Resume background monitoring
  Future<void> resumeBackgroundMonitoring() async {
    print('🔄 BackgroundLocationService: Resuming background monitoring...');
    // Re-register the periodic task
    await Workmanager().registerPeriodicTask(
      _locationTaskName,
      _locationTaskName,
      frequency: Duration(minutes: 15), // Minimum 15 minutes for periodic tasks
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}

// WorkManager callback function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🔄 WorkManager: Executing task: $task');

    try {
      switch (task) {
        case 'locationTask':
          await _performLocationCheck();
          break;
        default:
          print('🔄 WorkManager: Unknown task: $task');
      }
    } catch (error) {
      print('❌ WorkManager: Error executing task: $error');
    }

    return Future.value(true);
  });
}

// Perform location check
Future<void> _performLocationCheck() async {
  try {
    print('🔄 WorkManager: Performing location check...');

    // Initialize Supabase
    final supabaseService = SupabaseService();
    await supabaseService.initialize();

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print(
      '📍 WorkManager: Current position - Lat: ${position.latitude}, Lng: ${position.longitude}',
    );

    // Calculate distance from college
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      BackgroundLocationService.COLLEGE_LAT,
      BackgroundLocationService.COLLEGE_LNG,
    );

    print(
      '📍 WorkManager: Distance from college: ${distance.toStringAsFixed(2)}m',
    );

    // Get current user
    final currentUser = supabaseService.currentUser;
    if (currentUser == null) {
      print('❌ WorkManager: No user logged in');
      return;
    }

    // Load today's attendance by local-day window (TZ-safe)
    final nowLocal = DateTime.now().toLocal();
    final startLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final endLocal = startLocal.add(const Duration(days: 1));
    final startUtc = startLocal.toUtc().toIso8601String();
    final endUtc = endLocal.toUtc().toIso8601String();

    Map<String, dynamic>? todayAttendance;
    final todayList = await supabaseService.client
        .from('attendance')
        .select('*')
        .eq('user_id', currentUser.id)
        .gte('check_in_time', startUtc)
        .lt('check_in_time', endUtc)
        .order('check_in_time', ascending: false)
        .limit(1);
    if (todayList.isNotEmpty) {
      todayAttendance = Map<String, dynamic>.from(todayList.first);
    }

    final activeList = await supabaseService.client
        .from('attendance')
        .select('*')
        .eq('user_id', currentUser.id)
        .order('updated_at', ascending: false)
        .limit(1);
    Map<String, dynamic>? active;
    if (activeList.isNotEmpty) {
      final candidate = Map<String, dynamic>.from(activeList.first);
      if (candidate['check_in_time'] != null &&
          candidate['check_out_time'] == null) {
        active = candidate;
      }
    }

    final bool hasCheckedIn =
        (todayAttendance != null && todayAttendance['check_in_time'] != null) ||
        active != null;
    final bool hasCheckedOut =
        todayAttendance != null && todayAttendance['check_out_time'] != null;

    // Compute current IST time
    final DateTime nowIst = DateTime.now().toUtc().add(
      const Duration(hours: 5, minutes: 30),
    );

    // If inside radius: ensure check-in; also auto checkout at 4 PM IST if still inside
    if (distance <= BackgroundLocationService.ATTENDANCE_RADIUS) {
      print('🎯 WorkManager: User is at college!');
      if (!hasCheckedIn) {
        print('🎯 WorkManager: No check-in today, marking attendance...');
        await _markAttendance(position);
      } else if (!hasCheckedOut && nowIst.hour >= 16) {
        print(
          '🎯 WorkManager: After 4 PM IST and still at college — auto checkout',
        );
        await _markCheckOut(position);
      } else {
        print(
          '🎯 WorkManager: Attendance state OK (checkedIn: $hasCheckedIn, checkedOut: $hasCheckedOut)',
        );
      }
    } else {
      // Outside radius: if checked in and not checked out, auto-checkout
      print('🎯 WorkManager: User is outside college radius');
      if (hasCheckedIn && !hasCheckedOut) {
        print('🎯 WorkManager: Auto checkout due to leaving radius');
        await _markCheckOut(position);
      }
    }
  } catch (error) {
    print('❌ WorkManager: Error in location check: $error');
  }
}

// Mark attendance from background task
Future<void> _markAttendance(Position position) async {
  try {
    print('🎯 WorkManager: Marking attendance...');

    // Initialize Supabase
    final supabaseService = SupabaseService();
    await supabaseService.initialize();

    // Get current user
    final currentUser = supabaseService.currentUser;
    if (currentUser == null) {
      print('❌ WorkManager: No user logged in');
      return;
    }

    // Check if already checked in today (or any active session)
    final todayStr = DateTime.now().toLocal().toIso8601String().split('T')[0];
    final todayAttendance = await supabaseService.client
        .from('attendance')
        .select('*')
        .eq('user_id', currentUser.id)
        .eq('date', todayStr)
        .maybeSingle();

    if (todayAttendance != null && todayAttendance['check_in_time'] != null) {
      print('📝 WorkManager: Already checked in today');
      if (todayAttendance['check_out_time'] != null) {
        print('📝 WorkManager: Already checked out today, skipping check-in');
      }
      return;
    }

    final latestList = await supabaseService.client
        .from('attendance')
        .select('*')
        .eq('user_id', currentUser.id)
        .order('updated_at', ascending: false)
        .limit(1);
    if (latestList.isNotEmpty) {
      final latest = Map<String, dynamic>.from(latestList.first);
      if (latest['check_in_time'] != null && latest['check_out_time'] == null) {
        print(
          '📝 WorkManager: Active session detected, skipping duplicate check-in',
        );
        return;
      }
    }

    // Mark check-in
    final response = await supabaseService.client.rpc(
      'mark_check_in',
      params: {
        'user_uuid': currentUser.id,
        'check_in_lat': position.latitude,
        'check_in_lng': position.longitude,
      },
    );

    print('✅ WorkManager: Attendance marked successfully: $response');

    // Show notification
    await _showAttendanceNotification();
  } catch (error) {
    print('❌ WorkManager: Error marking attendance: $error');
  }
}

// Mark check-out from background task
Future<void> _markCheckOut(Position position) async {
  try {
    print('🎯 WorkManager: Marking check-out...');

    // Initialize Supabase
    final supabaseService = SupabaseService();
    await supabaseService.initialize();

    // Get current user
    final currentUser = supabaseService.currentUser;
    if (currentUser == null) {
      print('❌ WorkManager: No user logged in');
      return;
    }

    // Check today's attendance status first
    final todayAttendance = await supabaseService.client
        .from('attendance')
        .select('*')
        .eq('user_id', currentUser.id)
        .eq('date', DateTime.now().toIso8601String().split('T')[0])
        .maybeSingle();

    // Only mark check-out if checked in and not yet checked out
    if (todayAttendance == null || todayAttendance['check_in_time'] == null) {
      print('🎯 WorkManager: No check-in today; skipping check-out');
      return;
    }
    if (todayAttendance['check_out_time'] != null) {
      print('🎯 WorkManager: Already checked out; skipping check-out');
      return;
    }

    final response = await supabaseService.client.rpc(
      'mark_check_out',
      params: {
        'user_uuid': currentUser.id,
        'check_out_lat': position.latitude,
        'check_out_lng': position.longitude,
      },
    );

    print('✅ WorkManager: Check-out marked successfully: $response');

    // Show notification
    final notifications = FlutterLocalNotificationsPlugin();
    const androidDetails = AndroidNotificationDetails(
      'attendance_channel',
      'Attendance',
      channelDescription: 'Attendance notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Auto Check-out',
      'You have been automatically checked out.',
      notificationDetails,
    );
  } catch (error) {
    print('❌ WorkManager: Error marking check-out: $error');
  }
}

// Show attendance notification
Future<void> _showAttendanceNotification() async {
  final notifications = FlutterLocalNotificationsPlugin();

  const androidDetails = AndroidNotificationDetails(
    'attendance_channel',
    'Attendance',
    channelDescription: 'Attendance notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  await notifications.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    'Attendance Marked',
    'You have been automatically checked in!',
    notificationDetails,
  );
}
