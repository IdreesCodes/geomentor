import '../services/supabase_service.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  late final SupabaseService _supabaseService;

  void initialize(SupabaseService supabaseService) {
    _supabaseService = supabaseService;
  }

  // Mark check-in
  Future<Map<String, dynamic>> markCheckIn({
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('📝 AttendanceService: ==========================================');
      print('📝 AttendanceService: 🚀 MANUAL CHECK-IN API CALL');
      print('📝 AttendanceService: 📍 Location: ($latitude, $longitude)');
      print('📝 AttendanceService: ⏰ Time: ${DateTime.now()}');
      print('📝 AttendanceService: ==========================================');

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      print('👤 AttendanceService: User ID: ${currentUser.id}');
      print('📞 AttendanceService: Calling Supabase API: mark_check_in()');

      final response = await _supabaseService.client.rpc(
        'mark_check_in',
        params: {
          'user_uuid': currentUser.id,
          'check_in_lat': latitude,
          'check_in_lng': longitude,
          'device_check_in_time': DateTime.now().toIso8601String(),
        },
      );

      print('✅ AttendanceService: ==========================================');
      print('✅ AttendanceService: 🎉 MANUAL CHECK-IN SUCCESSFUL!');
      print('✅ AttendanceService: 📊 Response: $response');
      print('✅ AttendanceService: ==========================================');
      return response;
    } catch (error) {
      print('❌ AttendanceService: ==========================================');
      print('❌ AttendanceService: 🚨 MANUAL CHECK-IN FAILED!');
      print('❌ AttendanceService: Error: $error');
      print('❌ AttendanceService: ==========================================');
      rethrow;
    }
  }

  // Mark check-out
  Future<Map<String, dynamic>> markCheckOut({
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('📝 AttendanceService: ==========================================');
      print('📝 AttendanceService: 🚀 MANUAL CHECK-OUT API CALL');
      print('📝 AttendanceService: 📍 Location: ($latitude, $longitude)');
      print('📝 AttendanceService: ⏰ Time: ${DateTime.now()}');
      print('📝 AttendanceService: ==========================================');

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      print('👤 AttendanceService: User ID: ${currentUser.id}');
      print('📞 AttendanceService: Calling Supabase API: mark_check_out()');

      final response = await _supabaseService.client.rpc(
        'mark_check_out',
        params: {
          'user_uuid': currentUser.id,
          'check_out_lat': latitude,
          'check_out_lng': longitude,
          'device_check_out_time': DateTime.now().toIso8601String(),
        },
      );

      print('✅ AttendanceService: ==========================================');
      print('✅ AttendanceService: 🎉 MANUAL CHECK-OUT SUCCESSFUL!');
      print('✅ AttendanceService: 📊 Response: $response');
      print('✅ AttendanceService: ==========================================');
      return response;
    } catch (error) {
      print('❌ AttendanceService: ==========================================');
      print('❌ AttendanceService: 🚨 MANUAL CHECK-OUT FAILED!');
      print('❌ AttendanceService: Error: $error');
      print('❌ AttendanceService: ==========================================');
      rethrow;
    }
  }

  // Get current month attendance summary
  Future<Map<String, dynamic>> getCurrentMonthAttendance() async {
    try {
      print('📊 AttendanceService: Getting current month attendance...');

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get current month and year
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      // Query attendance records for current month
      final records = await _supabaseService.client
          .from('attendance')
          .select('*')
          .eq('user_id', currentUser.id)
          .gte('date', startOfMonth.toIso8601String().split('T')[0])
          .lte('date', endOfMonth.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      // Calculate attendance statistics
      int totalDays = 0;
      int presentDays = 0;
      int absentDays = 0;
      int lateDays = 0;
      int totalMinutesLate = 0;
      double totalWorkHours = 0.0;

      for (final record in records) {
        totalDays++;

        if (record['check_in_time'] != null) {
          presentDays++;

          // Calculate lateness (after 8:00 AM)
          final checkInTime = DateTime.parse(record['check_in_time']);
          final targetTime = DateTime(
            checkInTime.year,
            checkInTime.month,
            checkInTime.day,
            8,
            0,
          );

          // Use server-calculated lateness from database
          final serverLateMinutes = (record['minutes_late'] ?? 0) as int;
          if (serverLateMinutes > 0) {
            lateDays++;
            totalMinutesLate += serverLateMinutes;
          }

          // Calculate work hours if check-out is available
          if (record['check_out_time'] != null) {
            final checkOutTime = DateTime.parse(record['check_out_time']);
            final workHours =
                checkOutTime.difference(checkInTime).inMinutes / 60.0;
            totalWorkHours += workHours;
          }
        } else {
          absentDays++;
        }
      }

      final response = {
        'total_days': totalDays,
        'present_days': presentDays,
        'absent_days': absentDays,
        'late_days': lateDays,
        'total_minutes_late': totalMinutesLate,
        'total_work_hours': totalWorkHours,
        'average_work_hours': totalDays > 0 ? totalWorkHours / totalDays : 0.0,
      };

      print('✅ AttendanceService: Attendance data calculated: $response');
      return response;
    } catch (error) {
      print('❌ AttendanceService: Error getting attendance: $error');
      rethrow;
    }
  }

  // Get monthly attendance summary
  Future<Map<String, dynamic>> getMonthlyAttendance({
    required int month,
    required int year,
  }) async {
    try {
      print(
        '📊 AttendanceService: Getting monthly attendance for $month/$year...',
      );

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.client.rpc(
        'get_monthly_attendance_summary',
        params: {
          'user_uuid': currentUser.id,
          'target_month': month,
          'target_year': year,
        },
      );

      print(
        '✅ AttendanceService: Monthly attendance data retrieved: $response',
      );
      return response;
    } catch (error) {
      print('❌ AttendanceService: Error getting monthly attendance: $error');
      rethrow;
    }
  }

  // Get today's attendance record
  Future<Map<String, dynamic>?> getTodayAttendance() async {
    try {
      print('📝 AttendanceService: Getting today\'s attendance...');

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Compute local day boundaries and query by check_in_time for TZ safety
      final nowLocal = DateTime.now().toLocal();
      final startLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
      final endLocal = startLocal.add(const Duration(days: 1));
      final startUtc = startLocal.toUtc().toIso8601String();
      final endUtc = endLocal.toUtc().toIso8601String();

      final todayList = await _supabaseService.client
          .from('attendance')
          .select('*')
          .eq('user_id', currentUser.id)
          .gte('check_in_time', startUtc)
          .lt('check_in_time', endUtc)
          .order('check_in_time', ascending: false)
          .limit(1);

      if (todayList.isNotEmpty) {
        final today = Map<String, dynamic>.from(todayList.first);
        print('✅ AttendanceService: Today (TZ-safe) attendance: $today');
        return today;
      }

      print('✅ AttendanceService: Today\'s attendance: null');
      return null;
    } catch (error) {
      print('❌ AttendanceService: Error getting today\'s attendance: $error');
      return null;
    }
  }

  // Get attendance records for a specific date range
  Future<List<Map<String, dynamic>>> getAttendanceRecords({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      print(
        '📊 AttendanceService: Getting attendance records from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}...',
      );

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.client
          .from('attendance')
          .select('*')
          .eq('user_id', currentUser.id)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      print(
        '✅ AttendanceService: Attendance records retrieved: ${response.length} records',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('❌ AttendanceService: Error getting attendance records: $error');
      rethrow;
    }
  }

  // Check if user has already checked in today
  Future<bool> hasCheckedInToday() async {
    try {
      final todayAttendance = await getTodayAttendance();
      return todayAttendance != null &&
          todayAttendance['check_in_time'] != null;
    } catch (error) {
      print('❌ AttendanceService: Error checking today\'s check-in: $error');
      return false;
    }
  }

  // Check if user has already checked out today
  Future<bool> hasCheckedOutToday() async {
    try {
      final todayAttendance = await getTodayAttendance();
      return todayAttendance != null &&
          todayAttendance['check_out_time'] != null;
    } catch (error) {
      print('❌ AttendanceService: Error checking today\'s check-out: $error');
      return false;
    }
  }

  // Get attendance for a specific date
  Future<Map<String, dynamic>?> getAttendanceForDate(String date) async {
    try {
      print('📝 AttendanceService: Getting attendance for date: $date');

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // First, let's see what's actually in the database
      final allRecords = await _supabaseService.client
          .from('attendance')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('date', ascending: false)
          .limit(5);

      print('🔍 All attendance records for user: $allRecords');

      // Now try to get the specific date
      final response = await _supabaseService.client
          .from('attendance')
          .select('*')
          .eq('user_id', currentUser.id)
          .eq('date', date)
          .maybeSingle();

      if (response != null) {
        print('✅ AttendanceService: Attendance for $date: $response');
        return response;
      }

      print('📝 AttendanceService: No attendance record for $date');
      return null;
    } catch (error) {
      if (error.toString().contains('No rows returned')) {
        print('📝 AttendanceService: No attendance record for $date');
        return null;
      }
      print('❌ AttendanceService: Error getting attendance for $date: $error');
      rethrow;
    }
  }

  // Get recent attendance records
  Future<List<Map<String, dynamic>>> getRecentAttendanceRecords() async {
    try {
      print('📝 AttendanceService: Getting recent attendance records...');

      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.client
          .from('attendance')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('date', ascending: false)
          .limit(10);

      print('✅ AttendanceService: Recent attendance records: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print(
        '❌ AttendanceService: Error getting recent attendance records: $error',
      );
      rethrow;
    }
  }
}
