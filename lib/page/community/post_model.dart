class Post {
  final String title;
  final String nickname;
  final int commentCount;
  final int views;
  final int likes;
  final String time;
  final String content; // 🆕 추가

  Post({
    required this.title,
    required this.nickname,
    required this.commentCount,
    required this.views,
    required this.likes,
    required this.time,
    required this.content, // 🆕 추가
  });

  bool get isPopular => views > 100 || likes > 50;
}
