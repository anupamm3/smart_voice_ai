import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/reminder.dart';
import 'database_service.dart';
import 'dart:math';

class ReminderService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final DatabaseService _databaseService = DatabaseService();
  static bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request notification permissions
    await _requestPermissions();

    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();
    
    // For Android 13+, request exact alarm permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<String> setReminder(String reminderText, {DateTime? scheduledTime}) async {
    try {
      await initialize();

      final now = DateTime.now();
      final scheduled = scheduledTime ?? now.add(const Duration(hours: 1)); // Default to 1 hour from now

      final reminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Reminder',
        description: reminderText,
        scheduledTime: scheduled,
        createdAt: now,
      );

      // Save to database
      await _databaseService.saveReminder(reminder);

      // Schedule notification
      await _scheduleNotification(reminder);

      final timeStr = _formatTime(scheduled);
      return 'Reminder set for $timeStr: $reminderText';
    } catch (e) {
      return 'Sorry, I couldn\'t set the reminder. Error: $e';
    }
  }

  Future<String> setTimer(int minutes) async {
    try {
      await initialize();

      final now = DateTime.now();
      final scheduledTime = now.add(Duration(minutes: minutes));

      final reminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Timer',
        description: 'Timer for $minutes minute${minutes > 1 ? 's' : ''} is up!',
        scheduledTime: scheduledTime,
        createdAt: now,
      );

      // Save to database
      await _databaseService.saveReminder(reminder);

      // Schedule notification
      await _scheduleNotification(reminder);

      return 'Timer set for $minutes minute${minutes > 1 ? 's' : ''}!';
    } catch (e) {
      return 'Sorry, I couldn\'t set the timer. Error: $e';
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    final id = int.tryParse(reminder.id) ?? Random().nextInt(100000);

    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Reminders',
      channelDescription: 'Smart Voice AI Reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      reminder.title,
      reminder.description,
      _convertToTZDateTime(reminder.scheduledTime),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: reminder.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Convert DateTime to TZDateTime (timezone-aware)
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // For simplicity, we'll use the system timezone
    // In a real app, you might want to use the timezone package
    return dateTime;
  }

  Future<List<Reminder>> getAllReminders() async {
    return await _databaseService.getAllReminders();
  }

  Future<List<Reminder>> getUpcomingReminders() async {
    final allReminders = await getAllReminders();
    final now = DateTime.now();
    
    return allReminders
        .where((reminder) => reminder.scheduledTime.isAfter(now) && !reminder.isCompleted)
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  Future<void> completeReminder(String reminderId) async {
    try {
      await _databaseService.completeReminder(reminderId);
      
      // Cancel the notification
      final id = int.tryParse(reminderId) ?? 0;
      await _notifications.cancel(id);
    } catch (e) {
      print('Error completing reminder: $e');
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _databaseService.deleteReminder(reminderId);
      
      // Cancel the notification
      final id = int.tryParse(reminderId) ?? 0;
      await _notifications.cancel(id);
    } catch (e) {
      print('Error deleting reminder: $e');
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
      await _databaseService.deleteAllReminders();
    } catch (e) {
      print('Error canceling all reminders: $e');
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} from now';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} from now';
    } else {
      return 'now';
    }
  }

  // Parse natural language time expressions
  DateTime? parseTimeExpression(String expression) {
    final now = DateTime.now();
    final lowerExpression = expression.toLowerCase();

    // Handle relative time expressions
    if (lowerExpression.contains('minute')) {
      final match = RegExp(r'(\d+)\s*minute').firstMatch(lowerExpression);
      if (match != null) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        return now.add(Duration(minutes: minutes));
      }
    } else if (lowerExpression.contains('hour')) {
      final match = RegExp(r'(\d+)\s*hour').firstMatch(lowerExpression);
      if (match != null) {
        final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
        return now.add(Duration(hours: hours));
      }
    } else if (lowerExpression.contains('tomorrow')) {
      return DateTime(now.year, now.month, now.day + 1, 9); // 9 AM tomorrow
    } else if (lowerExpression.contains('next week')) {
      return now.add(const Duration(days: 7));
    }

    return null;
  }
}
