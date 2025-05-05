import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/utils/env.dart'; // ✅ 추가

class ChatListService {
  static StompClient? _client;
  static final StreamController<Map<String, dynamic>> _messageStreamController = StreamController.broadcast();

  static Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;

  static Future<void> connect() async {
    final token = await JwtStorage.getToken();
    if (token == null) {
      print('❌ JWT 토큰 없음');
      return;
    }

    _client = StompClient(
      config: StompConfig(
        url: '$wsBaseUrl/ws/chat', // ✅ 분기 적용
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        onConnect: _onConnect,
        onWebSocketError: (error) => print('❌ WebSocket 에러: $error'),
      ),
    );

    _client!.activate();
  }

  static void _onConnect(StompFrame frame) async {
    final myUserId = await JwtStorage.getUserIdFromToken();
    if (myUserId == null) return;

    _client!.subscribe(
      destination: '/topic/room.$myUserId',
      callback: (frame) {
        final body = json.decode(frame.body!);
        _messageStreamController.add(body);
      },
    );
  }

  static void disconnect() {
    _client?.deactivate();
  }
}
