class RankingUser {
  final int userId;
  final String nickname;
  final String? profileImage;
  final int stepCount;
  final bool isMe;

  RankingUser({
    required this.userId,
    required this.nickname,
    required this.profileImage,
    required this.stepCount,
    required this.isMe,
  });

  factory RankingUser.fromJson(Map<String, dynamic> json) {
    return RankingUser(
      userId: (json['userId'] ?? 0).toInt(), // null 방지
      nickname: json['nickname'] ?? '알 수 없음',
      profileImage: json['profileImage'],   // nullable 허용
      stepCount: (json['steps'] ?? 0).toInt(),
      isMe: json['isMe'] ?? false,
    );
  }
}
