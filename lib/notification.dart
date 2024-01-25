import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:isar/isar.dart';

import 'isar_instance.dart';
import 'notificationSwitch.dart';

// flutterLocalNotificationsPlugin.initialize 에서
// 콜백 함수는 최상위 함수로만 가능
void notificationCallback(_) {
  notificationUpdate(false);
  FlutterRingtonePlayer.stop().then((_) {});
}

/// isar 에서 알림 스위치 값을 변경하는 함수
/// flutter_background_service 가 다른 isolate 에서 동작하므로
/// 값 등을 공유하지 않아서 알림을 제어할 수 없음
/// 별도의 파일을 생성해서 관리할수 있지만, isar 를 통해 하도록 함
/// shared_preferences 를 사용하면 캐시를 사용해서 변경된 값이 다른 isolate 에서
/// 바로 적용되지 않음
void notificationUpdate(bool tf) async {
  final Isar isar = await isarInstance;
  isar.writeTxn(() async {
    final notificationSwitch =
        await isar.notificationSwitchs.where().anyId().findFirst();
    final notification = NotificationSwitch();
    if (notificationSwitch != null) {
      notification.id = notificationSwitch.id;
    }
    notification.isOn = tf;
    await isar.notificationSwitchs.put(notification);
  }).then((_) {});
}

class FlutterLocalNotification {
  // 이 클래스는 싱글톤 패턴을 사용합니다. 이 패턴은 클래스의 인스턴스가 하나만 생성되도록 보장합니다.
  FlutterLocalNotification._();

  // FlutterLocalNotificationsPlugin 객체를 생성합니다. 이 객체는 알림을 보내는데 사용됩니다.
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 알림 플러그인을 초기화하는 메소드입니다. Android와 iOS 각각에 대한 설정을 지정합니다.
  static init() async {
    final service = FlutterBackgroundService();
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
    // 위에서 정의한 설정을 사용하여 알림 플러그인을 초기화합니다.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: notificationCallback,
        onDidReceiveBackgroundNotificationResponse: notificationCallback);
    await service.configure(
        iosConfiguration: IosConfiguration(onForeground: onStart),
        androidConfiguration: AndroidConfiguration(
            autoStartOnBoot: true,
            onStart: onStart,
            isForegroundMode: true,
            autoStart: true));
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

  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

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
    // 위에서 정의한 설정을 사용하여 알림 플러그인을 초기화합니다.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: notificationCallback,
        onDidReceiveBackgroundNotificationResponse: notificationCallback);

    await Future.delayed(const Duration(seconds: 10));
    await showNotification();
    // 주기적 반복을 만들어 낼 떄
    // Timer.periodic(const Duration(seconds: 30), (timer) async {
    //   await showNotification();
    // });
  }

  /// 알림을 보내는 메소드입니다.
  static Future<void> showNotification() async {
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
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(presentSound: false, badgeNumber: 1));

    // 알림을 보냅니다.
    await flutterLocalNotificationsPlugin.show(
      0, // 알림의 ID입니다.
      'Hello, world!', // 알림의 제목입니다.
      'This is a test notification', // 알림의 본문입니다.
      platformChannelSpecifics, // 알림의 설정입니다.
    );

    // FlutterRingtonePlayer 통해서 밸소리 또는 알람음을 알림 소리로 사용
    await FlutterRingtonePlayer.playAlarm();

    // isar 에 알림 스위치 값을 변경
    notificationUpdate(true);

    // isar 에서 값을 가져오기 위한 인스턴스
    Isar isar = await isarInstance;
    // iOS 에서는 반복이 되지 않으므로 반복하도록 설정
    if (Platform.isIOS) {
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 2));
        NotificationSwitch? ns = await isar.notificationSwitchs.get(1);
        if (!ns!.isOn) {
          break;
        }
        await FlutterRingtonePlayer.playAlarm();
      }
    } else {
      // 안드로이드에서 백그라운드에서 알림 실행 시
      // notificationCallback 의 FlutterRingtonePlayer 다른 객체를 가르켜 stop이 동작하지 않음
      // isar에 값을 저장하고, 해당 값을 통해 알림 소리를 끄도록 개발
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(seconds: 1));
        NotificationSwitch? ns = await isar.notificationSwitchs.get(1);
        if (!ns!.isOn) {
          await FlutterRingtonePlayer.stop();
          break;
        }
      }
      await FlutterRingtonePlayer.stop();
    }
  }
}
