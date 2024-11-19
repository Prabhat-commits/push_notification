import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await FirebaseApi.instance.setUpFlutterNotifications();
  await FirebaseApi.instance.showNotification(message);
}


class FirebaseApi {
  FirebaseApi._();

  static final FirebaseApi instance=FirebaseApi._();

  final _firebaseMessaging = FirebaseMessaging.instance;
  bool _isFlutterLocalNotificationInitialized = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;



  Future<void> initlize() async {
    await requestPermission();
        await requestPermission();
        await _setUpMessageHandler();

        final token=_firebaseMessaging.getToken();
        _firebaseMessaging.subscribeToTopic("Prabhat");
        print("Token${token}");


  }
  Future<void> requestPermission() async {
    final setting = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false);

    print('Permission status  : ${setting.authorizationStatus}');

    var channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initAndroidSettingAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final initAndroidSettingAndroidDarwin = DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
        android: initAndroidSettingAndroid,
        iOS: initAndroidSettingAndroidDarwin);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {


      },
    );
    _isFlutterLocalNotificationInitialized = true;
  }

  Future<void> setUpFlutterNotifications() async {
    if (_isFlutterLocalNotificationInitialized) {
      return;
    }
  }


  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      showCountdownNotification(seconds: 10, messageData: message);
    }
  }


  Future<void> showCountdownNotification(
      {required int seconds, required RemoteMessage messageData}) async {
    final AndroidNotificationDetails androidNotificationDetailsChronotmeter = AndroidNotificationDetails(
      "'high_importance_channel'",
      "'High Importance Notifications'",
      channelDescription: "This channel is used for important notifications.",
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,

      when: DateTime
          .now()
          .millisecondsSinceEpoch + (seconds * 1000),
      usesChronometer: true,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      chronometerCountDown: true,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      actions: const [
        AndroidNotificationAction('pause', 'PAUSE', cancelNotification: false,
            allowGeneratedReplies: true),
        AndroidNotificationAction('stop', 'STOP', cancelNotification: true),
      ],
    );
    flutterLocalNotificationsPlugin.show(
      messageData.notification?.hashCode ?? 0,
      messageData.notification?.title ?? "",
      messageData.notification?.body ?? "",
      NotificationDetails(android: androidNotificationDetailsChronotmeter),
    );
  }

  Future<void> _setUpMessageHandler() async {
    FirebaseMessaging.onMessage.listen((event) {
      showNotification(event);
    },);


    FirebaseMessaging.onMessageOpenedApp.listen(_hnadleBackgroundMessage);

    //open App
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _hnadleBackgroundMessage(initialMessage);
    }
  }


  void _hnadleBackgroundMessage(RemoteMessage event) {
    if (event.data['type'] == 'chat') {


    }
  }
}
