import 'package:flutter/material.dart';
import 'package:cashwalk/utils/font_service.dart';
import 'package:cashwalk/utils/websocket_util.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/page/cashtalk/chat_room_screen.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _chatRooms = [];
  late StompClient stompClient;
  int? myUserId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userId = await JwtStorage.getUserIdFromToken();
    final token = await JwtStorage.getToken();
    if (userId == null || token == null) return;

    setState(() {
      myUserId = userId;
    });

    await _fetchChatRooms(token);
    _connectWebSocket(token);
  }

  Future<void> _fetchChatRooms(String token) async {
    final headers = {'Authorization': 'Bearer $token'};
    final data = await FontService.getJson(
      'http://10.0.2.2:8080/api/chat/rooms',
      headers: headers,
    );

    setState(() {
      _chatRooms = (data as List).cast<Map<String, dynamic>>();
    });
  }

  void _connectWebSocket(String token) {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws/chat/websocket?token=$token',
        onConnect: _onConnect,
        onWebSocketError: (error) {
          print('❌ WebSocket 에러: $error');
        },
      ),
    );
    stompClient.activate();
  }

  void _onConnect(StompFrame frame) {
    if (myUserId == null) return;
    stompClient.subscribe(
      destination: '/topic/room.$myUserId',
      callback: (frame) {
        final body = decodeWebSocketMessage(frame.body!);
        print('💬 새로운 메시지 도착: $body');

        setState(() {
          final index = _chatRooms.indexWhere((r) => r['roomId'] == body['roomId']);
          if (index != -1) {
            _chatRooms[index]['lastMessage'] = body['content'];
            _chatRooms[index]['lastTime'] = DateTime.now().toIso8601String();
          } else {
            _chatRooms.insert(0, {
              'roomId': body['roomId'],
              'opponentId': body['senderId'],
              'opponentNickname': '새 유저',
              'lastMessage': body['content'],
              'lastTime': DateTime.now().toIso8601String(),
            });
          }
        });
      },
    );
  }

  @override
  void dispose() {
    stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text('채팅 목록'),
      ),
      body: ListView.builder(
        itemCount: _chatRooms.length,
        itemBuilder: (context, index) {
          final room = _chatRooms[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person),
            ),
            title: Text(room['opponentNickname'] ?? ''),
            subtitle: Text(room['lastMessage'] ?? ''),
            trailing: Text(
              room['lastTime'] != null
                  ? room['lastTime'].toString().substring(11, 16)
                  : '',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    chatRoomId: room['roomId'],
                    friendUserId: room['opponentId'],
                    friendNickname: room['opponentNickname'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
