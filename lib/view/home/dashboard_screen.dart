import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'dart:math' as math;

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

class _Timeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineItem(
          time: '08:10 AM',
          title: 'Check In',
          subtitle: 'Actual Check in',
          status: 'Late: 10 Minutes',
          statusColor: Colors.red,
          svg: 'assets/svg/location.svg',
        ),
        _TimelineItem(
          time: '30:00:04',
          title: 'Break',
          subtitle: 'Start 12:05 PM',
          status: 'On Going...',
          statusColor: AppColors.secondary,
          svg: 'assets/svg/coffee_cup.svg',
          statusBg: Color(0xFF8F5BFF),
          statusTextColor: Colors.white,
        ),
        _TimelineItem(
          time: '13:00 PM',
          title: 'After Break',
          subtitle: 'After schedule',
          svg: 'assets/svg/heartbreak.svg',
          extraDetail:
              'It is now 12:35 PM', // Add this field to display below the card title
        ),
        _TimelineItem(
          time: '17:00 PM',
          title: 'Check Out',
          subtitle: 'Check Schedule',
          svg: 'assets/svg/cart.svg',
          extraDetail:
              'It is now 12:35 PM', // Add this field to display below the card title
        ),
      ],
    );
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
                      color: isActive
                          ? AppColors.secondary
                          : AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    width: 2,
                    height: 40,
                    color: Colors.grey[300],
                  ),
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
              color: isBreak
                  ? AppColors.secondary
                  : Colors.white, // Purple for Break, white otherwise
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
                        color: isBreak
                            ? Colors.white
                            : Colors.black, // White text for Break
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
                            color: isBreak
                                ? AppColors.secondary
                                : Colors.white, // Purple text for Break
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
                  color: isBreak ? Colors.white : null, // White icon for Break
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
