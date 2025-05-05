import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cashwalk/firebase_options.dart';
import 'package:cashwalk/services/http_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 백그라운드 메시지 수신: ${message.messageId}');
}

class FirebaseService {
  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;

    // 🔥 FCM 토큰 가져오기
    String? token = await messaging.getToken();
    print('📲 FCM Token: $token');

    // 🛡️ JWT 가져오기
    String? jwt = await JwtStorage.getToken();
    if (token == null || jwt == null) return;

    // 🔗 백엔드에 푸시 토큰 등록
    final url = Uri.parse('http://10.0.2.2:8080/api/push/register');
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
      print('🔥 FCM Token: $token');
    } else {
      print('❌ 푸시 토큰 등록 실패: ${response.statusCode}');
    }
  }
}
