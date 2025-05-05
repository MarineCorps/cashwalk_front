class ChatMessage {
  final String messageId;
  final int senderId;
  final String roomId;
  final String content;
  final String? fileUrl;
  final String type;
  final String? createdAt;

  // ✅ 행운캐시 메시지 상태
  final bool? opened;
  final bool? expired;

  final bool isSending;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.roomId,
    required this.content,
    this.fileUrl,
    required this.type,
    this.createdAt,
    this.opened,
    this.expired,
    this.isSending = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    if (json['messageId'] == null || json['messageId'].toString().isEmpty) {
      throw Exception('🚨 메시지 ID가 누락된 메시지 수신!');
    }
    return ChatMessage(
      messageId: json['messageId'] ?? '',
      senderId: json['senderId'],
      roomId: json['roomId'],
      content: json['content'],
      fileUrl: json['fileUrl'],
      type: json['type'],
      createdAt: json['createdAt'],
      opened: json['opened']==true,
      expired: json['expired']==true,
      isSending: json['isSending'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'roomId': roomId,
      'content': content,
      'fileUrl': fileUrl,
      'type': type,
      'createdAt': createdAt,
      'opened': opened,
      'expired': expired,
      'isSending': isSending,
    };
  }

  ChatMessage copyWith({
    String? messageId,
    String? content,
    String? fileUrl,
    String? createdAt,
    bool? opened,
    bool? expired,
    bool? isSending,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      senderId: senderId,
      roomId: roomId,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      type: type,
      createdAt: createdAt ?? this.createdAt,
      opened: opened ?? this.opened,
      expired: expired ?? this.expired,
      isSending: isSending ?? this.isSending,
    );
  }
}
