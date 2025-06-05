import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cashwalk/services/firebase_service.dart'; // 푸시 알림용

final FlutterTts _tts = FlutterTts();
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// 사용자에게 알림을 보냄 (포그라운드 시 TTS, 백그라운드 시 푸시)
Future<void> alertUser(
    String message, {
      bool isForeground = true,
      bool voiceEnabled = true, // ✅ TTS 설정 반영
    }) async {
  if (isForeground && voiceEnabled) {
    await _speakTTS(message);
  } else {
    _sendPushNotification('⚠️ 이상 보행 감지', message);
  }
}

/// TTS로 음성 안내
Future<void> _speakTTS(String message) async {
  await _tts.setLanguage('ko-KR');
  await _tts.setPitch(1.0);
  await _tts.setSpeechRate(0.45);
  await _tts.speak(message);
}

/// 로컬 푸시 알림 표시
void _sendPushNotification(String title, String body) {
  FirebaseService.showFlutterNotification(
    title: title,
    body: body,
  );
}
