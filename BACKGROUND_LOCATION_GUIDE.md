# Background Location Monitoring Guide

## Overview

This feature automatically marks attendance when users reach the college location, even when the app is running in the background or completely closed.

## How It Works

### 1. Background Service Architecture
- **WorkManager**: Handles periodic background tasks (every 15 minutes minimum)
- **Location Monitoring**: Checks user's current location against college coordinates
- **Automatic Check-in**: Marks attendance when user is within 100 meters of college
- **Notifications**: Shows attendance confirmation notifications

### 2. Key Components

#### BackgroundLocationService (`lib/services/background_location_service.dart`)
- Manages background location monitoring
- Handles WorkManager task registration
- Processes location checks and attendance marking
- Manages local notifications

#### LocationService (`lib/services/location_service.dart`)
- Integrates with background service
- Provides manual location checking
- Handles foreground location monitoring

#### SettingsScreen (`lib/view/settings/settings_screen.dart`)
- User interface to control background monitoring
- Shows monitoring status and configuration options

### 3. Configuration

#### College Location
- **Latitude**: 32.2886175
- **Longitude**: 72.2773874
- **Radius**: 100 meters

#### Permissions Required
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`
- `WAKE_LOCK`
- `FOREGROUND_SERVICE`

### 4. Usage Instructions

#### For Users

1. **Enable Background Monitoring**:
   - Open the app
   - Tap the settings icon (⚙️) in the top-right corner
   - Navigate to "Settings"
   - Toggle "Background Location Monitoring" to ON

2. **Grant Permissions**:
   - Allow location permissions when prompted
   - Enable "Allow all the time" for background access
   - Grant notification permissions

3. **Automatic Attendance**:
   - The app will automatically check your location every 15 minutes
   - When you reach college (within 100 meters), attendance is marked automatically
   - You'll receive a notification confirming the check-in

#### For Developers

1. **Testing the Feature**:
   ```dart
   // Start background monitoring
   final locationService = LocationService();
   await locationService.startBackgroundMonitoring();
   
   // Stop background monitoring
   await locationService.stopBackgroundMonitoring();
   
   // Check if monitoring is active
   bool isActive = await locationService.isBackgroundMonitoringActive();
   ```

2. **Manual Location Check**:
   ```dart
   // Trigger immediate location check
   await locationService.checkAttendanceManually();
   ```

### 5. Technical Details

#### WorkManager Implementation
- Uses periodic tasks with 15-minute minimum interval
- Requires network connectivity constraint
- Handles task execution in background isolate

#### Location Accuracy
- Uses high accuracy location (`LocationAccuracy.high`)
- Calculates distance using Haversine formula
- Prevents duplicate check-ins on the same day

#### Error Handling
- Graceful handling of permission denials
- Network connectivity checks
- Location service availability verification

### 6. Platform-Specific Considerations

#### Android
- Requires `ACCESS_BACKGROUND_LOCATION` permission
- Uses WorkManager for reliable background execution
- Foreground service notification for user awareness

#### iOS
- Requires "Always" location permission
- Background app refresh must be enabled
- Limited background execution time

### 7. Troubleshooting

#### Common Issues

1. **Background monitoring not working**:
   - Check if permissions are granted
   - Verify location services are enabled
   - Ensure app is not battery optimized

2. **No attendance notifications**:
   - Check notification permissions
   - Verify notification channels are created
   - Test with manual location check

3. **Battery drain concerns**:
   - Background monitoring uses minimal battery
   - 15-minute intervals reduce power consumption
   - Location accuracy is optimized for efficiency

#### Debug Information
- Check console logs for detailed debugging
- Look for "🔄 BackgroundService" and "🎯 WorkManager" logs
- Verify Supabase connection in background tasks

### 8. Security and Privacy

#### Data Protection
- Location data is only used for attendance marking
- No location history is stored locally
- All data is transmitted securely to Supabase

#### User Control
- Users can disable background monitoring anytime
- Location permissions can be revoked
- Clear privacy policy and usage explanation

### 9. Future Enhancements

#### Planned Features
- Geofencing for more precise location detection
- Customizable attendance radius
- Multiple location support
- Offline attendance caching
- Detailed attendance analytics

#### Performance Optimizations
- Adaptive location check intervals
- Battery-aware scheduling
- Network-aware task execution
- Location accuracy optimization

## Support

For technical support or feature requests, please refer to the project documentation or contact the development team. 