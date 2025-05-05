import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:cashwalk/models/chat_message.dart';
import 'package:cashwalk/services/chat_service.dart';
import 'package:cashwalk/services/chat_api_service.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/widgets/chat_bubble.dart';
import 'package:cashwalk/widgets/lucky_lottery.dart';

class ChatRoomScreen extends StatefulWidget {
  final int chatRoomId;
  final int friendUserId;
  final String friendNickname;


  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.friendUserId,
    required this.friendNickname,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StreamController<List<ChatMessage>> _messageStreamController = StreamController.broadcast();
  final ChatService _chatService = ChatService();

  List<ChatMessage> _messageBuffer = [];
  int? myUserId;
  String? profileImageUrl;
  String? lastDate;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final userId = await JwtStorage.getUserIdFromToken();
    if (userId == null) return;

    setState(() => myUserId = userId);
    await _fetchUserProfile();
    await ChatApiService.markMessagesAsRead(widget.chatRoomId);
    await _fetchPreviousMessages();

    _chatService.onMessageReceived = _handleIncomingMessage;
    _chatService.connectWebSocket(roomId: widget.chatRoomId);
  }

  Future<void> _fetchUserProfile() async {
    final data = await ChatApiService.getUserProfile(widget.friendUserId);
    setState(() {
      profileImageUrl = data['profileImageUrl'];
    });
  }

  Future<void> _fetchPreviousMessages() async {
    final data = await ChatApiService.getMessages(widget.chatRoomId);

    // 🔍 디버깅 로그 추가
    print('📥 서버 응답 메시지 목록:');
    for (var item in data) {
      print(jsonEncode(item)); // 서버에서 받은 원본 그대로 출력
    }

    _messageBuffer = data
        .where((e) => e['messageId'] != null)
        .map((e) {
      try {
        return ChatMessage.fromJson(e);
      } catch (e) {
        print('❌ ChatMessage 파싱 실패: $e');
        return null;
      }
    })
        .whereType<ChatMessage>()
        .toList();

    _messageStreamController.add(List.from(_messageBuffer));
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();
  }



  Future<void> _hideChatRoom() async {
    await ChatApiService.hideChatRoom(widget.chatRoomId);
    if (context.mounted) Navigator.pop(context);
  }

  void _handleIncomingMessage(ChatMessage message) {
    if (_messageBuffer.any((m) => m.messageId == message.messageId)) return;

    _messageBuffer.removeWhere((m) =>
    m.isSending && m.senderId == myUserId && m.content == message.content);

    _messageBuffer.add(message);
    _messageBuffer.sort((a, b) => (a.createdAt ?? '').compareTo(b.createdAt ?? ''));
    _messageStreamController.add(List.from(_messageBuffer));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (myUserId == null || _messageController.text.trim().isEmpty) return;

    final tempId = const Uuid().v4();
    final tempMessage = ChatMessage(
      messageId: tempId,
      senderId: myUserId!,
      roomId: widget.chatRoomId.toString(),
      content: _messageController.text.trim(),
      fileUrl: null,
      type: 'TEXT',
      createdAt: DateTime.now().toIso8601String(),
      isSending: true,
    );

    setState(() {
      _messageBuffer.add(tempMessage);
      _messageStreamController.add(List.from(_messageBuffer));
    });

    _chatService.sendMessage(tempMessage.copyWith(isSending: false));
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || myUserId == null) return;

    try {
      final fileUrl = await ChatApiService.uploadImage(picked.path);

      final imageMessage = ChatMessage(
        messageId: const Uuid().v4(),
        senderId: myUserId!,
        roomId: widget.chatRoomId.toString(),
        content: '사진을 보냈습니다.',
        fileUrl: fileUrl,
        type: 'IMAGE',
        createdAt: DateTime.now().toIso8601String(),
      );

      _chatService.sendMessage(imageMessage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 이미지 업로드 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 8),
            Text(widget.friendNickname),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'hide') _hideChatRoom();
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'hide',
                child: Text('채팅방 숨기기'),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messageStreamController.stream,
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final createdAt = DateTime.tryParse(msg.createdAt ?? '')?.toLocal();
                    final dateStr = createdAt != null
                        ? '${createdAt.year}년 ${createdAt.month}월 ${createdAt.day}일'
                        : '';

                    final showDateHeader = index == 0 || dateStr != lastDate;
                    lastDate = dateStr;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ChatBubble(
                          msg: msg.toJson(),
                          isMe: msg.senderId == myUserId,
                          myUserId: myUserId,
                          onRedeem: (messageId, reward) {
                            final idx = _messageBuffer.indexWhere((m) => m.messageId == messageId);
                            if (idx != -1) {
                              setState(() {
                                _messageBuffer[idx] = _messageBuffer[idx].copyWith(opened: true);
                                _messageStreamController.add(List.from(_messageBuffer));
                              });
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('🎉 $reward 캐시가 적립되었습니다!')),
                            );
                          },
                          onLuckyCashTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => LuckyLotteryDialog(
                                messageId: msg.messageId,
                                onCompleted: (reward) {
                                  final idx = _messageBuffer.indexWhere((m) => m.messageId == msg.messageId);
                                  if (idx != -1) {
                                    setState(() {
                                      _messageBuffer[idx] = _messageBuffer[idx].copyWith(opened: true);
                                      _messageStreamController.add(List.from(_messageBuffer));
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _sendImage,
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: const Icon(Icons.send, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _messageStreamController.close();
    _scrollController.dispose();
    super.dispose();
  }
}
