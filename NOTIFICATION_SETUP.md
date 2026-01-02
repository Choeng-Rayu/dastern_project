# Notification Setup Guide

## ✅ What's Been Implemented

The app now uses **native system notifications** that appear on your phone's notification bar using the `flutter_local_notifications` package.

## 📱 How to Test

### 1. Run on a Real Device or Emulator

```bash
flutter run
```

### 2. Add a Medication with Reminders

1. Go to the **Medications** screen
2. Add a new medication
3. Set reminder times (e.g., set one for 2-3 minutes from now for testing)
4. Save the medication

### 3. Test Notification

You can either:
- **Wait for the scheduled time** - The notification will appear on your phone's notification bar
- **Test immediately** - You can add this test button temporarily to the dashboard

### 4. Expected Behavior

- **Notification Title**: "💊 Medication Reminder"
- **Notification Body**: "Time to take [Medication Name] - [Dosage]"
- **Sound**: Yes
- **Vibration**: Yes (Android)
- **Appears**: On lock screen, notification bar, and notification drawer

## 🔧 Permissions

### Android
The following permissions are automatically handled:
- `POST_NOTIFICATIONS` - Show notifications (Android 13+)
- `SCHEDULE_EXACT_ALARM` - Schedule exact time alarms
- `VIBRATE` - Vibrate on notification
- `RECEIVE_BOOT_COMPLETED` - Restore notifications after reboot

### iOS
Permissions are requested automatically on first launch:
- Alert permission
- Badge permission  
- Sound permission

## 🧪 Testing Immediately

To test notifications right away, you can temporarily add this code to your dashboard:

```dart
// Add this to your dashboard imports
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';

// Add this button somewhere in your UI (e.g., in quick actions)
ElevatedButton(
  onPressed: () async {
    final notificationService = Provider.of<NotificationService>(
      context, 
      listen: false
    );
    await notificationService.showNotification(
      title: '💊 Test Notification',
      body: 'This is a test medication reminder!',
    );
  },
  child: Text('Test Notification'),
)
```

## 📋 How It Works

1. **Initialization**: Notification service is initialized in `main.dart`
2. **Scheduling**: When you add a medication with reminders, notifications are automatically scheduled
3. **Today's Reminders**: On app start, all reminders for today are scheduled
4. **Timezone**: Uses your local timezone for accurate scheduling
5. **Persistence**: Notifications persist even if the app is closed

## 🎯 Next Steps

The notifications are now fully functional! When a reminder time arrives:
- A notification will appear on your phone
- You can tap it to open the app
- The notification will stay until dismissed

## 🐛 Troubleshooting

### Notifications not appearing?

1. **Check permissions**: Go to Settings > Apps > DasTern > Notifications (enabled?)
2. **Check battery optimization**: Some phones kill background tasks
3. **Check Do Not Disturb**: Make sure it's not blocking notifications
4. **Restart app**: After adding reminders, restart the app to ensure they're scheduled
5. **Check time**: Reminders only schedule for future times (not past times)

### Android Specific
- On Android 13+, you need to explicitly grant notification permission
- Check if "Exact alarms" permission is granted in app settings

### iOS Specific
- Make sure you allowed notifications when prompted on first launch
- Check Settings > DasTern > Notifications

## 📱 Production Notes

For production release:
- Update notification icon in `android/app/src/main/res/mipmap-*/ic_launcher.png`
- Customize notification sound (optional)
- Test on different Android versions (especially 13+)
- Test on different iOS versions
