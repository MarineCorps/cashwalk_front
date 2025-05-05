class FriendUser {
  final int id;
  final String nickname;
  final String profileImage;
  final String inviteCode;

  FriendUser({
    required this.id,
    required this.nickname,
    required this.profileImage,
    required this.inviteCode,
  });

  factory FriendUser.fromJson(Map<String, dynamic> json) {
    return FriendUser(
      id: json['id'],
      nickname: json['nickname'],
      profileImage: json['profileImage'] ?? '',  // null-safe 처리
      inviteCode: json['inviteCode'] ?? '',
    );
  }
}
