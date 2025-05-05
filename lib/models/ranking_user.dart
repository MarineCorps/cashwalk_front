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
      userId: json['userId'],
      nickname: json['nickname'],
      profileImage: json['profileImage'],
      stepCount: json['stepCount'],
      isMe: json['isMe'],
    );
  }
}
