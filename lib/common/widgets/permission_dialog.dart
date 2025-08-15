import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  static Future<void> showLocationPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: 'Location Permission Required',
        message:
            'This app needs location access to automatically mark your attendance when you arrive at or leave college. Please grant location permission to continue.',
        onRetry: () async {
          Navigator.of(context).pop();
          await _handleLocationPermission(context);
        },
      ),
    );
  }

  static Future<void> showSimpleLocationPermissionDialog(
    BuildContext context,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This app needs location access to automatically mark your attendance.',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Location Access',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('• Mark attendance automatically'),
            Text('• Track when you arrive/leave'),
            Text('• Works in background'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static Future<void> _handleLocationPermission(BuildContext context) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        // Show dialog to enable location services
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text('Enable Location Services'),
              content: Text(
                'Please enable location services in your device settings to use this feature.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Geolocator.openLocationSettings();
                  },
                  child: Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Request permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.locationWhenInUse,
        Permission.locationAlways,
      ].request();

      if (statuses[Permission.location] != PermissionStatus.granted) {
        // Show dialog to open app settings
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text('Permission Denied'),
              content: Text(
                'Location permission was denied. Please enable it in app settings to use attendance features.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    openAppSettings();
                  },
                  child: Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      }
    } catch (error) {
      print('❌ PermissionDialog: Error handling location permission - $error');
      // If there's an error, just open app settings directly
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Permission Setup'),
            content: Text(
              'Please enable location permissions in your device settings to use attendance features.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  openAppSettings();
                },
                child: Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Location Access',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('• Mark attendance automatically'),
          Text('• Track when you arrive/leave'),
          Text('• Works in background'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: onRetry, child: Text('Grant Permission')),
      ],
    );
  }
}
