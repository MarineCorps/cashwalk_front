class BlockedUser {
  final int userId;
  final String nickname;
  final String? profileImage;

  BlockedUser({
    required this.userId,
    required this.nickname,
    required this.profileImage,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      userId: json['id'],
      nickname: json['nickname'],
      profileImage: json['profileImage'],
    );
  }
}
