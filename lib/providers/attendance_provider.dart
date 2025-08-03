import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/attendance_service.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  final attendanceService = AttendanceService();
  final supabaseService = ref.watch(supabaseServiceProvider);
  attendanceService.initialize(supabaseService);
  return attendanceService;
});

class AttendanceData {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int totalMinutesLate;
  final double totalWorkHours;
  final double averageWorkHours;

  AttendanceData({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.totalMinutesLate,
    required this.totalWorkHours,
    required this.averageWorkHours,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      totalMinutesLate: json['total_minutes_late'] ?? 0,
      totalWorkHours: (json['total_work_hours'] ?? 0).toDouble(),
      averageWorkHours: (json['average_work_hours'] ?? 0).toDouble(),
    );
  }

  // Calculate attendance percentage
  double get attendancePercentage {
    if (totalDays == 0) return 0;
    return (presentDays / totalDays) * 100;
  }

  // Format late time
  String get formattedLateTime {
    if (totalMinutesLate == 0) return '0m';
    final hours = totalMinutesLate ~/ 60;
    final minutes = totalMinutesLate % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Format work hours
  String get formattedWorkHours {
    return '${totalWorkHours.toStringAsFixed(1)}h';
  }

  // Format average work hours
  String get formattedAverageWorkHours {
    return '${averageWorkHours.toStringAsFixed(1)}h';
  }
}

class AttendanceNotifier extends StateNotifier<AsyncValue<AttendanceData?>> {
  final AttendanceService _attendanceService;

  AttendanceNotifier(this._attendanceService)
    : super(const AsyncValue.data(null));

  Future<void> loadCurrentMonthAttendance() async {
    try {
      state = const AsyncValue.loading();
      final data = await _attendanceService.getCurrentMonthAttendance();
      final attendanceData = AttendanceData.fromJson(data);
      state = AsyncValue.data(attendanceData);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  Future<void> markCheckIn({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await _attendanceService.markCheckIn(
        latitude: latitude,
        longitude: longitude,
      );

      // Reload attendance data after check-in
      await loadCurrentMonthAttendance();

      print('✅ AttendanceNotifier: Check-in marked successfully');
    } catch (error) {
      print('❌ AttendanceNotifier: Error marking check-in: $error');
      rethrow;
    }
  }

  Future<void> markCheckOut({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await _attendanceService.markCheckOut(
        latitude: latitude,
        longitude: longitude,
      );

      // Reload attendance data after check-out
      await loadCurrentMonthAttendance();

      print('✅ AttendanceNotifier: Check-out marked successfully');
    } catch (error) {
      print('❌ AttendanceNotifier: Error marking check-out: $error');
      rethrow;
    }
  }

  Future<bool> hasCheckedInToday() async {
    return await _attendanceService.hasCheckedInToday();
  }

  Future<bool> hasCheckedOutToday() async {
    return await _attendanceService.hasCheckedOutToday();
  }

  Future<Map<String, dynamic>?> getTodayAttendance() async {
    return await _attendanceService.getTodayAttendance();
  }
}

final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AsyncValue<AttendanceData?>>((
      ref,
    ) {
      final attendanceService = ref.watch(attendanceServiceProvider);
      return AttendanceNotifier(attendanceService);
    });
