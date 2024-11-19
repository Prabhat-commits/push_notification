import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String channelCountdownId = "countdown_channel_id";
  static const String channelCountdownName = "Countdown Channel";
  static const String channelCountdownDescription = "Receiving Countdown Notifications";

  final AndroidNotificationChannel _countdownNotificationChannel = const AndroidNotificationChannel(
    channelCountdownId,
    channelCountdownName,
    description: channelCountdownDescription,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_countdownNotificationChannel);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
          onDidReceiveNotificationResponse: notificationTapBackground);

      print("Notification Initialized Successfully!");
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse notificationResponse) {
    log(notificationResponse.actionId ?? "");
  }

  Future<void> showCountdownNotification({required int seconds}) async {
    final AndroidNotificationDetails androidNotificationDetailsChronotmeter = AndroidNotificationDetails(
      channelCountdownId,
      channelCountdownName,
      channelDescription: channelCountdownDescription,
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,
      when: DateTime.now().millisecondsSinceEpoch + (seconds * 1000),
      usesChronometer: true,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      chronometerCountDown: true,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      actions: const [
        AndroidNotificationAction('pause', 'PAUSE', cancelNotification: false,allowGeneratedReplies: true),
        AndroidNotificationAction('stop', 'STOP', cancelNotification: true),
      ],
    );
    flutterLocalNotificationsPlugin.show(
      0,
      "Timer Notification",
      "Timer Notification Counting ...",
      NotificationDetails(android: androidNotificationDetailsChronotmeter),
    );
  }
}