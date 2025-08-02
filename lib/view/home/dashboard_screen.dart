import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_line/dotted_line.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'dart:math' as math;
import 'dart:async';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Black header
            Container(
              color: Colors.black,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 68, 24, 50),
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
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Morning, Shantanu',
                    style: AppTextStyles.headline.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
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
                ],
              ),
            ),
            // White content with rounded top corners
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview title and date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overview',
                          style: AppTextStyles.subhead.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                'July 2025',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatColumn(label: 'Presence', value: '20'),
                        _VerticalDivider(),
                        _StatColumn(label: 'Absence', value: '3'),
                        _VerticalDivider(),
                        _StatColumn(label: 'Lateness', value: '1.5h'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Timeline card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 18,
                          right: 12,
                          left: 12,
                          bottom: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saturday 26 July 2025',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Timeline items
                            _Timeline(),
                            const SizedBox(height: 12),
                            // Overtime card
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF7F7FA),
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Overtime',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Late: 10 Minutes',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      SvgPicture.asset(
                                        'assets/svg/business-time.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.subhead.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 15)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5,
      height: 36,
      color: AppColors.textSecondary.withOpacity(0.15),
    );
  }
}

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
    // Get current time for the marker
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Define timeline times with proper 24-hour format
    final timelineTimes = [
      {'time': '08:10', 'label': '08:10 AM', 'minutes': 8 * 60 + 10},
      {'time': '12:05', 'label': '12:05 PM', 'minutes': 12 * 60 + 5},
      {'time': '13:00', 'label': '13:00 PM', 'minutes': 13 * 60 + 0},
      {'time': '17:00', 'label': '17:00 PM', 'minutes': 17 * 60 + 0},
    ];

    // Calculate current position on timeline
    final currentPosition = _getCurrentPosition(now, timelineTimes);
    final currentTimeLabel =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      child: Column(
        children: [
          // Main timeline container with dotted line
          Container(
            child: Stack(
              children: [
                // Dotted line that spans the entire timeline
                Positioned(
                  left: 6, // Align with the dots
                  top: 0,
                  bottom: 0,
                  child: DottedLine(
                    direction: Axis.vertical,
                    lineLength: double.infinity,
                    lineThickness: 2,
                    dashLength: 4,
                    dashColor: Colors.grey[300]!,
                    dashRadius: 0,
                    dashGapLength: 4,
                    dashGapColor: Colors.transparent,
                    dashGapRadius: 0,
                  ),
                ),
                // Current time indicator
                if (currentPosition != null)
                  Positioned(
                    left: 0,
                    top: currentPosition,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.access_time,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                // Timeline items
                Column(
                  children: [
                    _TimelineItem(
                      time: '08:10 AM',
                      title: 'Check In',
                      subtitle: 'Actual Check in',
                      status: 'Late: 10 Minutes',
                      statusColor: Colors.red,
                      svg: 'assets/svg/location.svg',
                      isCurrentTime: _isCurrentTime('08:10 AM', currentTime),
                      isActive: _isCurrentActive('08:10 AM', now),
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
                    _TimelineItem(
                      time: '17:00 PM',
                      title: 'Check Out',
                      subtitle: 'Check Schedule',
                      svg: 'assets/svg/cart.svg',
                      extraDetail: 'It is now 12:35 PM',
                      isCurrentTime: _isCurrentTime('17:00 PM', currentTime),
                      isActive: _isCurrentActive('17:00 PM', now),
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

  int _timeStrToMinutes(String timeStr) {
    // Convert "08:10 AM" or "12:05 PM" to minutes
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    final hours = int.parse(timeParts[0]);
    final minutes = int.parse(timeParts[1]);
    final period = parts[1];

    if (period == 'PM' && hours != 12) {
      return (hours + 12) * 60 + minutes;
    } else if (period == 'AM' && hours == 12) {
      return minutes;
    } else {
      return hours * 60 + minutes;
    }
  }

  double? _getCurrentPosition(
    DateTime now,
    List<Map<String, dynamic>> timelineTimes,
  ) {
    final currentMinutes = now.hour * 60 + now.minute;

    // Find the two closest timeline points for interpolation
    int? beforeIndex;
    int? afterIndex;

    for (int i = 0; i < timelineTimes.length; i++) {
      final timelineMinutes = timelineTimes[i]['minutes'] as int;

      if (timelineMinutes <= currentMinutes) {
        beforeIndex = i;
      } else {
        afterIndex = i;
        break;
      }
    }

    // If current time is before first timeline point
    if (beforeIndex == null) {
      return 0.0;
    }

    // If current time is after last timeline point
    if (afterIndex == null) {
      return (timelineTimes.length - 1) * 80.0;
    }

    // Interpolate position between two timeline points
    final beforeMinutes = timelineTimes[beforeIndex]['minutes'] as int;
    final afterMinutes = timelineTimes[afterIndex]['minutes'] as int;

    final progress =
        (currentMinutes - beforeMinutes) / (afterMinutes - beforeMinutes);
    final position = (beforeIndex + progress) * 80.0;

    return position;
  }
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
  final String? trailingSvg;
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
    this.trailingSvg,
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
              color: isActive
                  ? AppColors.secondary
                  : Colors.white, // Purple when active, white otherwise
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
                        color: isActive
                            ? Colors.white
                            : Colors.black, // White text when active
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
                            color: isActive
                                ? Colors.white
                                : Colors
                                      .black, // White text when active, black when not
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
                  color: isActive
                      ? Colors.white
                      : Colors.black, // White icon when active, black when not
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
