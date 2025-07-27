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
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    // Overview
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 32, 15, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Overview',
                                style: AppTextStyles.subhead.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
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
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Stats row with dividers
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
                          const SizedBox(height: 28),
                          // Timeline Card
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
                                top: 15,
                                right: 15,
                                left: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Saturday 26 July 2025',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _Timeline(),
                                  const SizedBox(height: 18),
                                  // Overtime
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7FA),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white,
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
                                        const Text(
                                          'Overtime',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Late: 10 Minutes',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SvgPicture.asset(
                                              'assets/svg/star.svg',
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
          isActive: true,
          statusBg: const Color(0xFFFFE5E5),
          statusTextColor: Colors.red,
          trailingSvg: 'assets/svg/location.svg',
        ),
        _TimelineItem(
          time: '30:00:04',
          title: 'Break',
          subtitle: 'Start 12:05 PM',
          status: 'On Going...',
          statusColor: AppColors.secondary,
          svg: 'assets/svg/heartbreak.svg',
          isActive: true,
          statusBg: Color(0xFF8F5BFF),
          statusTextColor: Colors.white,
          trailingSvg: 'assets/svg/heartbreak.svg',
        ),
        _TimelineItem(
          time: '13:00 PM',
          title: 'After Break',
          subtitle: 'It is now 12:35 PM',
          svg: 'assets/svg/heartbreak.svg',
          trailingSvg: 'assets/svg/heartbreak.svg',
        ),
        _TimelineItem(
          time: '17:00 PM',
          title: 'Check Out',
          subtitle: 'It is now 12:35 PM',
          svg: 'assets/svg/cart.svg',
          trailingSvg: 'assets/svg/cart.svg',
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
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot and line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.secondary : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              Container(width: 2, height: 40, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(width: 12),
          // Time and subtitle
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: AppTextStyles.subhead.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Event card
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.subhead.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        if (status != null)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor ?? Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(svg, width: 24, height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
