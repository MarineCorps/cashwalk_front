import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cashwalk/services/firebase_service.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 🔊 TTS 추가

class PushTestPage extends StatelessWidget {
  PushTestPage({super.key});

  final FlutterTts _tts = FlutterTts(); // 🔊 TTS 인스턴스

  // ✅ 즉시 푸시 알림
  void _sendImmediateNotification(String title, String body) {
    FirebaseService.showFlutterNotification(title: title, body: body);
  }

  // ✅ 딜레이 후 푸시 알림
  void _sendDelayedNotification(String title, String body, Duration delay) async {
    await Future.delayed(delay);
    FirebaseService.showFlutterNotification(title: title, body: body);
  }

  // ✅ 푸시 알림 끄기
  void _cancelNotification({bool all = false}) {
    final plugin = FlutterLocalNotificationsPlugin();
    if (all) {
      plugin.cancelAll();
    } else {
      plugin.cancel(0);
    }
  }

  // ✅ (추가) 음성 메시지 안내 껍데기
  Future<void> _speakGaitWarning(String message) async {
    await _tts.setLanguage("ko-KR");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Push + TTS Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 알림 박스
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text("알림 제목 · now 🕓", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text("알림 바디 메시지"),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () => _sendImmediateNotification("일반 푸시 알림 제목", "일반 푸시 알림 바디"),
              child: const Text("일반 푸시 알림"),
            ),
            ElevatedButton(
              onPressed: () => _sendDelayedNotification(
                  "주기 푸시 알림 제목", "주기 푸시 알림 바디", const Duration(seconds: 10)),
              child: const Text("주기 푸시 알림"),
            ),
            ElevatedButton(
              onPressed: () => _sendImmediateNotification("스케줄 푸시 알림 제목", "스케줄 푸시 알림 바디"),
              child: const Text("스케줄 푸시 알림"),
            ),

            const SizedBox(height: 24),

            // 🧠 걸음 패턴 음성 피드백 (예시용)
            ElevatedButton(
              onPressed: () => _speakGaitWarning("왼쪽으로 치우쳐 걷고 있습니다. 중심을 잡아주세요."),
              child: const Text("🧠 걸음 피드백 TTS"),
            ),

            const SizedBox(height: 16),

            // 알림 끄기
            TextButton(
              onPressed: () => _cancelNotification(),
              child: const Text("주기 푸시 알림 끄기", style: TextStyle(color: Colors.purple)),
            ),
            TextButton(
              onPressed: () => _cancelNotification(all: true),
              child: const Text("전체 푸시 알림 끄기", style: TextStyle(color: Colors.purple)),
            ),
          ],
        ),
      ),
    );
  }
}
