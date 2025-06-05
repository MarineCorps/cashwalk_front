import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cashwalk/firebase_options.dart';
import 'package:cashwalk/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ✅ AlertDialog에 context 접근 위해 navigatorKey 사용
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ✅ Flutter 로컬 푸시 알림용 플러그인 인스턴스
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 백그라운드 메시지 수신: ${message.messageId}');
}

class FirebaseService {
  /// ✅ Firebase + FCM 초기화
  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final messaging = FirebaseMessaging.instance;

    // ✅ 포그라운드 수신 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📥 포그라운드 메시지 수신: ${message.notification?.title} - ${message.notification?.body}');
      final ctx = navigatorKey.currentContext;

      if (ctx != null && message.notification != null) {
        showDialog(
          context: ctx,
          builder: (_) => AlertDialog(
            title: Text(message.notification?.title ?? '알림'),
            content: Text(message.notification?.body ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('확인'),
              )
            ],
          ),
        );
      }
    });

    // ✅ 로컬 푸시 초기화 (Android 채널 포함)
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // 🔥 FCM 토큰 가져오기 및 서버 등록
    String? token = await messaging.getToken();
    print('📲 FCM Token: $token');

    String? jwt = await JwtStorage.getToken();
    if (token == null || jwt == null) return;

    final url = Uri.parse('${HttpService.baseUrl}/api/push/register');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: json.encode({'token': token}),
    );

    if (response.statusCode == 200) {
      print('✅ 푸시 토큰 등록 성공');
    } else {
      print('❌ 푸시 토큰 등록 실패: ${response.statusCode}');
    }
  }

  /// ✅ 테스트용 로컬 푸시 알림 띄우기
  static Future<void> showFlutterNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel', // 채널 ID
      '기본 채널', // 채널 이름
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // notification ID
      title,
      body,
      notificationDetails,
    );
  }
}
