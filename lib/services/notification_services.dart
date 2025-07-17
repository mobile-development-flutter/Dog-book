// services/notification_services.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<bool> init() async {
    // Initialize timezone
    await _configureLocalTimeZone();

    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
    );
    
    // Just check permission status directly with permission_handler
    return await Permission.notification.isGranted;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<bool> checkPermission() async {
    return await Permission.notification.isGranted;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> scheduleVaccinationReminder(
      int id, String petName, DateTime vaccineDate) async {
    // Check if permission is granted
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      print('Cannot schedule notification: permission denied');
      return;
    }
    
    final now = DateTime.now();
    final isToday = vaccineDate.year == now.year && 
                    vaccineDate.month == now.month && 
                    vaccineDate.day == now.day;

    try {
      // Handle today's date differently
      if (isToday) {
        if (now.hour < 8) {
          // Schedule for 8 AM today
          final scheduledTime = tz.TZDateTime(
            tz.local,
            vaccineDate.year,
            vaccineDate.month,
            vaccineDate.day,
            8, // 8 AM
            0,
          );

          await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            'Vaccination Reminder',
            'Your pet $petName\'s vaccination day is today!',
            scheduledTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'pet_vaccination_channel',
                'Pet Vaccination Reminders',
                channelDescription: 'Notifications for pet vaccination reminders',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'pet_$id',
          );
          print('Notification scheduled for $petName today at 8:00 AM');
        } else {
          // Show immediately if after 8 AM
          await showImmediateNotification(id, petName);
        }
      } else {
        // Regular future date scheduling
        final scheduledDate = tz.TZDateTime(
          tz.local,
          vaccineDate.year,
          vaccineDate.month,
          vaccineDate.day,
          8, // 8 AM
          0,
        );

        // Check if date is in the past
        if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
          print('Cannot schedule notification for past date');
          return;
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Vaccination Reminder',
          'Your pet $petName\'s vaccination day is today!',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'pet_vaccination_channel',
              'Pet Vaccination Reminders',
              channelDescription: 'Notifications for pet vaccination reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'pet_$id',
        );

        print('Notification scheduled for $petName on ${vaccineDate.toString()} at 8:00 AM');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> showImmediateNotification(int id, String petName) async {
    // Check permission
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      print('Cannot show notification: permission denied');
      return;
    }
    
    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        'Vaccination Reminder',
        'Your pet $petName\'s vaccination day is today!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pet_vaccination_channel',
            'Pet Vaccination Reminders',
            channelDescription: 'Notifications for pet vaccination reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: 'pet_$id',
      );
      print('Immediate notification sent for $petName');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Test function for immediate notification
  Future<void> showTestNotification() async {
    // Check permission
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      print('Cannot show test notification: permission denied');
      return;
    }
    
    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Test Notification',
        'This is a test notification',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pet_vaccination_channel',
            'Pet Vaccination Reminders',
            channelDescription: 'Notifications for pet vaccination reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      print('Test notification sent');
    } catch (e) {
      print('Error showing test notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
  
  // Check current notification permission status
  Future<bool> isNotificationPermissionGranted() async {
    return await Permission.notification.isGranted;
  }
}