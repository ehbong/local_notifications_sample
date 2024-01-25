import 'package:flutter/material.dart';

import 'notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalNotification.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // 3초 후 권한 요청
    Future.delayed(const Duration(seconds: 3),
        FlutterLocalNotification.requestNotificationPermission());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => FlutterLocalNotification.showNotification(),
              child: const Text("알림 보내기"),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () => notificationCallback(null),
              child: const Text("알림 소리 멈추기"),
            ),
          ],
        ),
      ),
    );
  }
}
