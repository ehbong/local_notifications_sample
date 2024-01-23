import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/android_sounds.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

bool _iOSNotificationLoop = false;

void notificationCallback(_) {
  _iOSNotificationLoop = false;
  FlutterRingtonePlayer.stop().then((_) {});
}

class FlutterLocalNotification {
  // 이 클래스는 싱글톤 패턴을 사용합니다. 이 패턴은 클래스의 인스턴스가 하나만 생성되도록 보장합니다.
  FlutterLocalNotification._();

  static late final NotificationDetails _platformChannelSpecifics;

  // FlutterLocalNotificationsPlugin 객체를 생성합니다. 이 객체는 알림을 보내는데 사용됩니다.
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 알림 플러그인을 초기화하는 메소드입니다. Android와 iOS 각각에 대한 설정을 지정합니다.
  static init() async {
    // Android에서 알림을 초기화하는 설정입니다. 'mipmap/ic_launcher'는 알림 아이콘으로 사용됩니다.
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    // iOS에서 알림을 초기화하는 설정입니다. 각 권한 요청은 기본적으로 false로 설정되어 있습니다.
    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Android와 iOS 설정을 모두 포함하는 초기화 설정입니다.
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Android에서 알림을 보내는데 필요한 설정입니다.
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id', // 알림 채널의 ID입니다.
      'channel_name', // 알림 채널의 이름입니다.
      channelDescription: 'channel_description', // 알림 채널의 설명입니다.
      importance: Importance.max, // 알림의 중요도입니다.
      priority: Priority.high, // 알림의 우선순위입니다.
      showWhen: true, // 알림이 표시될 시간을 보여줄지 여부입니다.
      playSound: false, // 별도의 알림 소리 사용을 위해 소리를 끕니다.
    );

    // Android와 iOS 각각에 대한 알림 설정을 포함하는 객체입니다.
    _platformChannelSpecifics = const NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(
            presentSound: false, badgeNumber: 1)); // iOS에서 알림 배지의 숫자를 설정합니다.

    // 위에서 정의한 설정을 사용하여 알림 플러그인을 초기화합니다.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: notificationCallback,
        onDidReceiveBackgroundNotificationResponse: notificationCallback);
  }

  // iOS에서 알림 권한을 요청하는 메소드입니다. Android에서는 이 메소드가 필요 없습니다.
  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true, // 알림 권한을 요청합니다.
          badge: true, // 배지 권한을 요청합니다.
          sound: true, // 사운드 권한을 요청합니다.
        );
  }

  // 알림을 보내는 메소드입니다.
  static Future<void> showNotification() async {
    // 알림을 보냅니다.
    await flutterLocalNotificationsPlugin.show(
      0, // 알림의 ID입니다.
      'Hello, world!', // 알림의 제목입니다.
      'This is a test notification', // 알림의 본문입니다.
      _platformChannelSpecifics, // 알림의 설정입니다.
    );
    await FlutterRingtonePlayer.playRingtone();
    // iOS 에서는 반복이 되지 않으므로 반복하도록 설정
    if (Platform.isIOS) {
      _iOSNotificationLoop = true;
      for (int i = 0; i < 10; i++) {
        if (!_iOSNotificationLoop) {
          break;
        }
        await Future.delayed(const Duration(seconds: 2));
        await FlutterRingtonePlayer.playRingtone();
      }
    }
  }
}
