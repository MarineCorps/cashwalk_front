class FriendSearchResult {
  final int id;
  final String nickname;
  final String? profileImage;
  final String inviteCode;

  FriendSearchResult({
    required this.id,
    required this.nickname,
    required this.profileImage,
    required this.inviteCode,
  });

  factory FriendSearchResult.fromJson(Map<String, dynamic> json) {
    return FriendSearchResult(
      id: json['id'],
      nickname: json['nickname'],
      profileImage: json['profileImage'],
      inviteCode: json['inviteCode'],
    );
  }
}
