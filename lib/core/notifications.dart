import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

notificationInit() {
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  notifications.initialize(initSettings);
}

final androidDetails = AndroidNotificationDetails(
  '0',
  "TimatoDefaultChannel",
  'default notification channel for Timato',
  importance: Importance.Max,
  priority: Priority.High,
  enableVibration: true,
);
final iosDetails = IOSNotificationDetails();
final notificationDetails = NotificationDetails(androidDetails, iosDetails);

final androidOngoingDetails = AndroidNotificationDetails(
  '0',
  'TimatoDefaultChannel',
  'default notification channel for Timato',
  importance: Importance.None,
  priority: Priority.Low,
//  ongoing: true,
  enableVibration: false,
);
final countdownNotificationDetails = NotificationDetails(androidOngoingDetails, iosDetails);