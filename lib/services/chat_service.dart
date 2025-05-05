import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/utils/websocket_util.dart';
import 'package:cashwalk/utils/font_service.dart';
import 'package:cashwalk/utils/env.dart'; // ✅ 추가
import 'package:cashwalk/models/chat_message.dart';

class ChatService {
  StompClient? _stompClient;
  bool _isConnected = false;

  Function(ChatMessage)? onMessageReceived;

  Future<void> connectWebSocket({required int roomId}) async {
    final token = await JwtStorage.getToken();

    if (token == null) {
      print('❌ JWT 토큰 없음');
      return;
    }

    final url = '$wsBaseUrl/ws/chat/websocket?token=$token'; // ✅ 분기 적용

    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (frame) {
          print('✅ WebSocket 연결 성공');
          _isConnected = true;
          _subscribeToRoom(roomId);
        },
        onWebSocketError: (error) {
          print('❌ WebSocket 에러: $error');
        },
      ),
    );
    _stompClient!.activate();
  }

  void _subscribeToRoom(int roomId) {
    final destination = '/topic/room.$roomId';

    _stompClient!.subscribe(
      destination: destination,
      callback: (frame) {
        if (frame.body != null) {
          final data = decodeWebSocketMessage(frame.body!);
          final message = ChatMessage.fromJson(data);
          onMessageReceived?.call(message);
        }
      },
    );

    print('📥 구독 시작: $destination');
  }

  void sendMessage(ChatMessage message) {
    if (_isConnected && _stompClient != null) {
      final jsonMessage = json.encode(message.toJson());
      _stompClient!.send(
        destination: '/app/chat.send',
        body: jsonMessage,
      );
      print('📤 메시지 전송: $jsonMessage');
    } else {
      print('⚠️ 연결되지 않음, 전송 불가');
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
    _isConnected = false;
    print('🔌 연결 해제 완료');
  }

  static Future<int> getOrCreateChatRoom(int friendId) async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final data = await FontService.postJson(
      '$httpBaseUrl/api/chat/room', // ✅ 분기 적용
      headers: headers,
      body: jsonEncode({'userId': friendId}),
    );

    return data['roomId'];
  }
}
