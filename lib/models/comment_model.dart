// 📄 lib/models/comment_model.dart
class CommentModel {
  final int id;
  final int userId;
  final String nickname;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final int dislikeCount;
  final bool likedByMe;
  final bool dislikedByMe;
  final int? parentId;
  final bool isMine;

  CommentModel({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.dislikeCount,
    required this.likedByMe,
    required this.dislikedByMe,
    required this.parentId,
    required this.isMine,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      userId: json['userId'],
      nickname: json['nickname'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      likeCount: json['likeCount'],
      dislikeCount: json['dislikeCount'],
      likedByMe: json['likedByMe'],
      dislikedByMe: json['dislikedByMe'],
      parentId: json['parentId'],
      isMine: json['isMine'],
    );
  }
}
