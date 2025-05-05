import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final String title = post['title'] ?? '';
    final String nickname = post['nickname'] ?? '익명';
    final int views = post['views'] ?? 0;
    final int likeCount = post['likeCount'] ?? 0;
    final int dislikeCount = post['dislikeCount'] ?? 0; //
    final int commentCount = post['commentCount'] ?? 0;
    final String createdAt = (post['createdAt'] ?? '').toString().substring(0, 10);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),

          // 닉네임
          Text(nickname, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),

          // 조회수, 좋아요, 시간
          Row(
            children: [
              const Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('$views', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 12),
              const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('$likeCount', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 12),
              const Icon(Icons.thumb_down_alt_outlined, size: 14, color: Colors.grey), // 👎
              const SizedBox(width: 4),
              Text('$dislikeCount', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(createdAt, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),


          // 댓글 수
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, right: 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$commentCount',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
