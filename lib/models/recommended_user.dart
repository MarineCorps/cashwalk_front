class RecommendedUser {
  final int userId;
  final String nickname;
  final String? profileImage;

  RecommendedUser({
    required this.userId,
    required this.nickname,
    required this.profileImage,
  });

  factory RecommendedUser.fromJson(Map<String, dynamic> json) {
    return RecommendedUser(
      userId: json['id'],
      nickname: json['nickname'],
      profileImage: json['profileImage'],
    );
  }
}
