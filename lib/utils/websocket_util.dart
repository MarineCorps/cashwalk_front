import 'dart:convert';

Map<String, dynamic> decodeWebSocketMessage(String rawMessage) {
  try {
    final decoded = utf8.decode(rawMessage.codeUnits); // ✅ 핵심: UTF-8 디코딩
    return json.decode(decoded);
  } catch (e) {
    print('❌ WebSocket 메시지 디코딩 실패: $e');
    return {};
  }
}
