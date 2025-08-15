import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Removed dotted_line import as timeline is simplified
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../common/widgets/attendance_popup.dart';
// import '../../common/widgets/permission_dialog.dart';
import '../../services/background_location_service.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:math' as math;
import 'dart:async';
import '../../utils/date_time_utils.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user profile when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(userProfileNotifierProvider.notifier).refreshProfile();
      // Initialize location service
      await ref.read(locationNotifierProvider.notifier).initializeLocation();
      // Start location monitoring after initialization
      ref.read(locationNotifierProvider.notifier).startMonitoring();
      // Load attendance data
      ref
          .read(attendanceNotifierProvider.notifier)
          .loadCurrentMonthAttendance();

      // Set up attendance popup callback
      ref.read(locationNotifierProvider.notifier).setAttendanceCallback((
        message,
      ) {
        AttendancePopup.show(context, message);
        // Refresh attendance data after check-in
        ref
            .read(attendanceNotifierProvider.notifier)
            .loadCurrentMonthAttendance();
        // Force rebuild of the widget
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height; // unused

    // Get user profile
    final userProfileAsync = ref.watch(userProfileNotifierProvider);

    // Get greeting based on time of day
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Morning';
      } else if (hour < 17) {
        return 'Afternoon';
      } else {
        return 'Evening';
      }
    }

    // Get user's first name or fallback
    String getUserName() {
      return userProfileAsync.when(
        data: (profile) {
          print('👤 Dashboard: User profile loaded - ${profile?.fullName}');
          if (profile?.fullName != null && profile!.fullName!.isNotEmpty) {
            // Get first name only
            final firstName = profile.fullName!.split(' ').first;
            print('👤 Dashboard: Using first name - $firstName');
            return firstName;
          }
          print('👤 Dashboard: No full name found, using fallback');
          return 'User';
        },
        loading: () {
          print('👤 Dashboard: User profile loading...');
          return 'User';
        },
        error: (error, stack) {
          print('👤 Dashboard: User profile error - $error');
          return 'User';
        },
      );
    }

    // Removed unused date helpers

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Black header
            Container(
              color: Colors.black,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/star.svg',
                        width: 32,
                        height: 32,
                        color: Color(0xFF8F5BFF),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.settings,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  userProfileAsync.when(
                    data: (profile) => Text(
                      '${getGreeting()}, ${getUserName()}',
                      style: AppTextStyles.headline.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    loading: () => Text(
                      '${getGreeting()}, User',
                      style: AppTextStyles.headline.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    error: (_, __) => Text(
                      '${getGreeting()}, User',
                      style: AppTextStyles.headline.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let's be productive today!",
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Background Monitoring Status
                ],
              ),
            ),
            // White content with rounded top corners
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview title and date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time Tracker',
                          style: AppTextStyles.subhead.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to full time tracker view
                          },
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status Cards Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Check-in and Working Time Row
                          _TimeTrackerWidget(),
                          const SizedBox(height: 20),
                          // Action Buttons Row
                          Row(
                            children: [
                              // BREAK Button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement break functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Break functionality coming soon!',
                                        ),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF601AE9),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'BREAK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // CHECKOUT Button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      // Pause background monitoring temporarily to prevent auto check-in
                                      final backgroundService =
                                          BackgroundLocationService();
                                      await backgroundService
                                          .pauseBackgroundMonitoring();

                                      await ref
                                          .read(
                                            attendanceNotifierProvider.notifier,
                                          )
                                          .markCheckOut(
                                            latitude: 32.2886175,
                                            longitude: 72.2773874,
                                          );

                                      // Resume background monitoring after 5 minutes
                                      Future.delayed(
                                        Duration(minutes: 5),
                                        () async {
                                          await backgroundService
                                              .resumeBackgroundMonitoring();
                                        },
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Check-out marked successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (error) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: ${error.toString()}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF601AE9),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'CHECKOUT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Time Tracker Cards
                    Consumer(
                      builder: (context, ref, child) {
                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: _getRecentAttendanceData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Column(
                                children: List.generate(
                                  3,
                                  (index) => _TimeTrackerCard(
                                    date: 'Loading...',
                                    checkinTime: '--:--:--',
                                    checkoutTime: '--:--:--',
                                    isLoading: true,
                                    isLastCard:
                                        index ==
                                        2, // 3 items, so last index is 2
                                  ),
                                ),
                              );
                            }

                            final attendanceList = snapshot.data ?? [];

                            if (attendanceList.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'No attendance records yet',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final limitedList = attendanceList; // show all
                            return Column(
                              children: List.generate(limitedList.length, (
                                index,
                              ) {
                                final attendance = limitedList[index];

                                // Debug: Print the attendance data structure
                                print('🔍 Attendance data: $attendance');

                                final checkInTime =
                                    attendance['check_in_time'] != null
                                    ? _formatTime(
                                        DateTime.parse(
                                          attendance['check_in_time'],
                                        ),
                                      )
                                    : '--:--:--';
                                final checkOutTime =
                                    attendance['check_out_time'] != null
                                    ? _formatTime(
                                        DateTime.parse(
                                          attendance['check_out_time'],
                                        ),
                                      )
                                    : '--:--:--';
                                final date = attendance['date'] != null
                                    ? _getFormattedDate(
                                        DateTime.parse(attendance['date']),
                                      )
                                    : _getFormattedDate(DateTime.now());

                                print('🕐 Check-in time: $checkInTime');
                                print('🕐 Check-out time: $checkOutTime');
                                print('📅 Date: $date');

                                return _TimeTrackerCard(
                                  date: date,
                                  checkinTime: checkInTime,
                                  checkoutTime: checkOutTime,
                                  isLoading: false,
                                  isLastCard: index == limitedList.length - 1,
                                );
                              }),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) => DateTimeUtils.formatDayMonth(date);

  String _formatTime(DateTime time) => DateTimeUtils.formatTime12h(time);

  Future<List<Map<String, dynamic>>> _getRecentAttendanceData() async {
    try {
      // Get recent attendance records directly
      final attendanceList = await ref
          .read(attendanceNotifierProvider.notifier)
          .getRecentAttendanceRecords();

      print('📊 Total attendance records found: ${attendanceList.length}');
      return attendanceList;
    } catch (error) {
      print('Error fetching recent attendance data: $error');
      return [];
    }
  }
}

class _TimeTrackerWidget extends ConsumerStatefulWidget {
  const _TimeTrackerWidget();

  @override
  _TimeTrackerWidgetState createState() => _TimeTrackerWidgetState();
}

class _TimeTrackerWidgetState extends ConsumerState<_TimeTrackerWidget> {
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Initial load of attendance data
    _loadAttendanceData();

    // Set up timer to update attendance data every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _loadAttendanceData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAttendanceData() async {
    try {
      // Always prefer authoritative today's attendance first
      final today = await ref
          .read(attendanceNotifierProvider.notifier)
          .getTodayAttendance();

      DateTime? checkIn;
      DateTime? checkOut;

      if (today != null && today['check_in_time'] != null) {
        checkIn = DateTime.parse(today['check_in_time']).toLocal();
        if (today['check_out_time'] != null) {
          checkOut = DateTime.parse(today['check_out_time']).toLocal();
        }
      } else {
        // Fallback to recent records and filter to TODAY only
        final recent = await ref
            .read(attendanceNotifierProvider.notifier)
            .getRecentAttendanceRecords();

        // 1) Look for latest active session for TODAY (no checkout yet)
        final String todayStr = DateTime.now()
            .toLocal()
            .toIso8601String()
            .split('T')[0];
        for (final rec in recent) {
          if (rec['check_in_time'] != null && rec['check_out_time'] == null) {
            final DateTime ciLocal = DateTime.parse(
              rec['check_in_time'],
            ).toLocal();
            final String ciDateStr = ciLocal.toIso8601String().split('T')[0];
            if (ciDateStr == todayStr) {
              checkIn = ciLocal;
              checkOut = null;
              break;
            }
          }
        }

        // 2) If none active, pick today's by date (local)
        if (checkIn == null) {
          final String todayStr = DateTime.now()
              .toLocal()
              .toIso8601String()
              .split('T')[0];
          for (final rec in recent) {
            if (rec['check_in_time'] != null) {
              final DateTime ciLocal = DateTime.parse(
                rec['check_in_time'],
              ).toLocal();
              final String ciDateStr = ciLocal.toIso8601String().split('T')[0];
              if (ciDateStr == todayStr) {
                checkIn = ciLocal;
                if (rec['check_out_time'] != null) {
                  checkOut = DateTime.parse(rec['check_out_time']).toLocal();
                }
                break;
              }
            }
          }
        }
      }

      _checkInTime = checkIn;
      _checkOutTime = checkOut;
    } catch (e) {
      // Keep safe defaults on error
      _checkInTime = null;
      _checkOutTime = null;
    }
    setState(() {});
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    int hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final hh = hour12.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final String checkInText = _checkInTime != null
        ? _formatTime(_checkInTime!)
        : '--:--:--';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Check-in Time
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Check in',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              checkInText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Working Time
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Working Time',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            StreamBuilder<DateTime>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => DateTime.now(),
              ),
              builder: (context, _) {
                String workingText = '00:00:00';
                if (_checkInTime != null) {
                  final DateTime endTime = _checkOutTime ?? DateTime.now();
                  Duration diff = endTime.difference(_checkInTime!);
                  if (diff.isNegative) diff = Duration.zero;
                  final String hours = diff.inHours.toString().padLeft(2, '0');
                  final String minutes = (diff.inMinutes % 60)
                      .toString()
                      .padLeft(2, '0');
                  final String seconds = (diff.inSeconds % 60)
                      .toString()
                      .padLeft(2, '0');
                  workingText = '$hours:$minutes:$seconds';
                }
                return Text(
                  workingText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeTrackerCard extends StatelessWidget {
  final String date;
  final String checkinTime;
  final String checkoutTime;
  final bool isLoading;
  final bool isLastCard;

  const _TimeTrackerCard({
    required this.date,
    required this.checkinTime,
    required this.checkoutTime,
    this.isLoading = false,
    this.isLastCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLastCard ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Text(
                  'Present',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Check-in and Check-out Row
          Row(
            children: [
              // Check-in Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Checkin',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkinTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Check-out Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Checkout',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkoutTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Removed unused _StatColumn

// Removed unused _VerticalDivider

class _Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<_Timeline> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every minute to show current time position
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simplified timeline without dotted line or animated marker
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      child: Column(
        children: [
          // Main timeline container with dotted line
          Container(
            child: Stack(
              children: [
                // Removed dotted vertical line and marker for simplicity
                // Timeline items
                Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: ref
                              .read(attendanceNotifierProvider.notifier)
                              .getTodayAttendance(),
                          builder: (context, snapshot) {
                            final todayAttendance = snapshot.data;
                            String checkInTime = 'Not Checked In';
                            String status = '';
                            Color statusColor = Colors.grey;
                            // lateness handled via server minutes
                            int lateMinutes = 0;

                            if (todayAttendance != null &&
                                todayAttendance['check_in_time'] != null) {
                              final checkInDateTime = DateTime.parse(
                                todayAttendance['check_in_time'],
                              );
                              // Convert to local time (assuming UTC from database)
                              final localCheckInTime = checkInDateTime
                                  .toLocal();
                              checkInTime =
                                  '${localCheckInTime.hour.toString().padLeft(2, '0')}:${localCheckInTime.minute.toString().padLeft(2, '0')} ${localCheckInTime.hour >= 12 ? 'PM' : 'AM'}';

                              // Use server-calculated lateness from database
                              final serverLateMinutes =
                                  todayAttendance['minutes_late'] ?? 0;
                              if (serverLateMinutes > 0) {
                                lateMinutes = serverLateMinutes;
                                status = 'Late: $lateMinutes Minutes';
                                statusColor = Colors.red;
                              } else {
                                status = 'On Time';
                                statusColor = Colors.green;
                              }
                            } else {
                              status = 'Not Checked In';
                              statusColor = Colors.grey;
                            }

                            return _TimelineItem(
                              time: checkInTime,
                              title: 'Check In',
                              subtitle:
                                  todayAttendance != null &&
                                      todayAttendance['check_in_time'] != null
                                  ? 'Actual Check in'
                                  : 'Not Checked In',
                              status: status,
                              statusColor: statusColor,
                              svg: 'assets/svg/location.svg',
                              isCurrentTime: _isCurrentTime(
                                checkInTime,
                                currentTime,
                              ),
                              isActive: _isCurrentActive(checkInTime, now),
                            );
                          },
                        );
                      },
                    ),
                    _TimelineItem(
                      time: '12:05 PM',
                      title: 'Break',
                      subtitle: 'Start 12:05 PM',
                      status: 'On Going...',
                      statusColor: AppColors.secondary,
                      svg: 'assets/svg/coffee_cup.svg',
                      statusBg: Color(0xFF8F5BFF),
                      statusTextColor: Colors.white,
                      isCurrentTime: _isCurrentTime('12:05 PM', currentTime),
                      isActive: _isCurrentActive('12:05 PM', now),
                    ),
                    _TimelineItem(
                      time: '13:00 PM',
                      title: 'After Break',
                      subtitle: 'After schedule',
                      svg: 'assets/svg/heartbreak.svg',
                      extraDetail: 'It is now 12:35 PM',
                      isCurrentTime: _isCurrentTime('13:00 PM', currentTime),
                      isActive: _isCurrentActive('13:00 PM', now),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: ref
                              .read(attendanceNotifierProvider.notifier)
                              .getTodayAttendance(),
                          builder: (context, snapshot) {
                            final todayAttendance = snapshot.data;
                            String checkOutTime = 'Not Checked Out';
                            String status = 'Not Checked Out';
                            Color statusColor = Colors.grey;

                            if (todayAttendance != null &&
                                todayAttendance['check_out_time'] != null) {
                              final checkOutDateTime = DateTime.parse(
                                todayAttendance['check_out_time'],
                              );
                              // Convert to local time (assuming UTC from database)
                              final localCheckOutTime = checkOutDateTime
                                  .toLocal();
                              checkOutTime =
                                  '${localCheckOutTime.hour.toString().padLeft(2, '0')}:${localCheckOutTime.minute.toString().padLeft(2, '0')} ${localCheckOutTime.hour >= 12 ? 'PM' : 'AM'}';
                              status = 'Checked Out';
                              statusColor = Colors.green;

                              // Debug logging
                              print(
                                '🕐 Check-out time found: ${todayAttendance['check_out_time']}',
                              );
                              print('🕐 Local check-out time: $checkOutTime');
                            } else {
                              // Debug logging
                              print(
                                '❌ No check-out time found in attendance data',
                              );
                              if (todayAttendance != null) {
                                print(
                                  '📊 Today\'s attendance data: $todayAttendance',
                                );
                              }
                            }

                            return _TimelineItem(
                              time: checkOutTime,
                              title: 'Check Out',
                              subtitle:
                                  todayAttendance != null &&
                                      todayAttendance['check_out_time'] != null
                                  ? 'Actual Check out'
                                  : 'Not Checked Out',
                              status: status,
                              statusColor: statusColor,
                              svg: 'assets/svg/cart.svg',
                              isCurrentTime: _isCurrentTime(
                                checkOutTime,
                                currentTime,
                              ),
                              isActive: _isCurrentActive('17:00 PM', now),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentTime(String timeStr, String currentTime) {
    // Convert time strings to comparable format
    final time = timeStr.replaceAll(' AM', '').replaceAll(' PM', '');
    final current = currentTime;

    // Simple comparison - you might want to add more sophisticated time parsing
    return time == current;
  }

  bool _isCurrentActive(String timeStr, DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;

    // Define time ranges for each timeline item
    final timeRanges = [
      {
        'start': 8 * 60 + 10,
        'end': 12 * 60 + 5,
        'time': '08:10 AM',
      }, // Check In: 8:10 AM - 12:05 PM
      {
        'start': 12 * 60 + 5,
        'end': 13 * 60 + 0,
        'time': '12:05 PM',
      }, // Break: 12:05 PM - 13:00 PM
      {
        'start': 13 * 60 + 0,
        'end': 17 * 60 + 0,
        'time': '13:00 PM',
      }, // After Break: 13:00 PM - 17:00 PM
      {
        'start': 17 * 60 + 0,
        'end': 24 * 60,
        'time': '17:00 PM',
      }, // Check Out: 17:00 PM - 23:59
    ];

    // Find the range that matches this timeline item
    for (final range in timeRanges) {
      if (range['time'] == timeStr) {
        final start = range['start'] as int;
        final end = range['end'] as int;
        final isActive = currentMinutes >= start && currentMinutes < end;

        // Debug: Print current state
        print(
          'Time: $timeStr, Current: ${now.hour}:${now.minute}, Minutes: $currentMinutes, Start: $start, End: $end, Active: $isActive',
        );

        return isActive;
      }
    }

    return false;
  }

  // int _timeStrToMinutes(String timeStr) {
  //   // Convert "08:10 AM" or "12:05 PM" to minutes
  //   final parts = timeStr.split(' ');
  //   final timeParts = parts[0].split(':');
  //   final hours = int.parse(timeParts[0]);
  //   final minutes = int.parse(timeParts[1]);
  //   final period = parts[1];
  //
  //   if (period == 'PM' && hours != 12) {
  //     return (hours + 12) * 60 + minutes;
  //   } else if (period == 'AM' && hours == 12) {
  //     return minutes;
  //   } else {
  //     return hours * 60 + minutes;
  //   }
  // }

  // Removed position calculation helper and dotted line usage
}

class _TimelineItem extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final String? status;
  final Color? statusColor;
  final String svg;
  final bool isActive;
  final Color? statusBg;
  final Color? statusTextColor;
  // Removed unused property trailingSvg to reduce API surface
  final String? extraDetail;
  final bool isCurrentTime;

  const _TimelineItem({
    required this.time,
    required this.title,
    required this.subtitle,
    this.status,
    this.statusColor,
    required this.svg,
    this.isActive = false,
    this.statusBg,
    this.statusTextColor,
    this.extraDetail,
    this.isCurrentTime = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBreak = title == 'Break';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left group: dot/line and time/subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dot and vertical line
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isCurrentTime
                          ? Colors.orange
                          : (isActive
                                ? AppColors.secondary
                                : AppColors.background),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrentTime ? Colors.orange : Colors.white,
                        width: isCurrentTime ? 3 : 2,
                      ),
                    ),
                    child: isCurrentTime
                        ? Icon(Icons.access_time, size: 8, color: Colors.white)
                        : null,
                  ),
                  // Remove the individual dotted line since we have a continuous one
                ],
              ),
              const SizedBox(width: 8),
              // Time and subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: AppTextStyles.subhead.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          Container(
            width: 170, // Increased width
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: (isActive || isCurrentTime)
                  ? AppColors.secondary
                  : Colors
                        .white, // Purple when active or current time, white otherwise
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subhead.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: (isActive || isCurrentTime)
                            ? Colors.white
                            : Colors
                                  .black, // White text when active or current time
                      ),
                    ),
                    if (extraDetail != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          extraDetail!,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    if (status != null)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isBreak
                              ? Colors.white
                              : (statusColor ??
                                    Colors.red), // White chip for Break
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status!,
                          style: TextStyle(
                            color: (isActive || isCurrentTime)
                                ? Colors.white
                                : Colors
                                      .black, // White text when active or current time, black when not
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SvgPicture.asset(
                  svg,
                  width: 18,
                  height: 18,
                  color: (isActive || isCurrentTime)
                      ? Colors.white
                      : Colors
                            .black, // White icon when active or current time, black when not
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
