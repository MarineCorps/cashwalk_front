class FriendRequestResult {
  final int requestId;
  final int userId;
  final String nickname;
  final String? profileImage;
  final bool sentByMe;
  final DateTime createdAt;

  FriendRequestResult({
    required this.requestId,
    required this.userId,
    required this.nickname,
    required this.profileImage,
    required this.sentByMe,
    required this.createdAt,
  });

  factory FriendRequestResult.fromJson(Map<String, dynamic> json) {
    return FriendRequestResult(
      requestId: json['requestId'],
      userId: json['userId'],
      nickname: json['nickname'],
      profileImage: json['profileImage'],
      sentByMe: json['sentByMe'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
