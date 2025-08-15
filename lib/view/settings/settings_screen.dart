import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
// removed unused provider import
import '../../services/location_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBackgroundMonitoringActive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBackgroundMonitoringStatus();
  }

  Future<void> _checkBackgroundMonitoringStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationService = LocationService();
      final isActive = await locationService.isBackgroundMonitoringActive();
      setState(() {
        _isBackgroundMonitoringActive = isActive;
      });
    } catch (error) {
      print('❌ Settings: Error checking background monitoring status: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBackgroundMonitoring(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationService = LocationService();

      if (value) {
        await locationService.startBackgroundMonitoring();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Background monitoring started'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await locationService.stopBackgroundMonitoring();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Background monitoring stopped'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      setState(() {
        _isBackgroundMonitoringActive = value;
      });
    } catch (error) {
      print('❌ Settings: Error toggling background monitoring: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headline.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Background Monitoring Section
            _buildSectionHeader('Location & Attendance'),

            _buildSettingCard(
              title: 'Background Location Monitoring',
              subtitle: 'Automatically mark attendance when you reach college',
              icon: Icons.location_on,
              trailing: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Switch(
                      value: _isBackgroundMonitoringActive,
                      onChanged: _toggleBackgroundMonitoring,
                      activeColor: AppColors.secondary,
                    ),
            ),

            SizedBox(height: 16),

            // Information Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: AppTextStyles.subhead.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Monitors your location every 15 minutes\n'
                    '• Automatically marks check-in when you reach college\n'
                    '• Works even when the app is closed\n'
                    '• Requires location permissions',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // College Location Section
            _buildSectionHeader('College Location'),

            _buildSettingCard(
              title: 'College Coordinates',
              subtitle: 'Lat: 32.2886175, Lng: 72.2773874',
              icon: Icons.school,
              trailing: Icon(Icons.info_outline, color: Colors.grey, size: 20),
            ),

            _buildSettingCard(
              title: 'Attendance Radius',
              subtitle: '100 meters from college location',
              icon: Icons.radio_button_checked,
              trailing: Icon(Icons.info_outline, color: Colors.grey, size: 20),
            ),

            SizedBox(height: 32),

            // Permissions Section
            _buildSectionHeader('Permissions'),

            _buildSettingCard(
              title: 'Location Permission',
              subtitle: 'Required for attendance marking',
              icon: Icons.location_on,
              trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
            ),

            _buildSettingCard(
              title: 'Notification Permission',
              subtitle: 'Required for attendance notifications',
              icon: Icons.notifications,
              trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTextStyles.subhead.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subhead.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
