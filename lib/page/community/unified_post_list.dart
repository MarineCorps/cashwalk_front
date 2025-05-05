import 'package:flutter/material.dart';
import 'package:cashwalk/services/community_service.dart';
import 'package:cashwalk/widgets/post_card.dart';

/// 📌 공통 게시글 리스트 위젯 (전체, 인기글, 공지 등 통합)
class UnifiedPostList extends StatelessWidget {
  final String? boardType; // 예: FREE, NOTICE, null
  final String? postCategory; // 예: BESTLIVE, LEGEND, null
  final bool isPreview;
  final Function(Map<String, dynamic>)? onPostTap;

  const UnifiedPostList({
    super.key,
    this.boardType,
    this.postCategory,
    this.isPreview = false,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: CommunityService.searchPosts(
        boardType: boardType,
        postCategory: postCategory, // ❗ null이면 전체 카테고리 포함됨
        page: 0,
        size: isPreview ? 3 : 10,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('게시글을 불러오는 데 실패했습니다.'));
        }

        final posts = snapshot.data!;
        if (posts.isEmpty) {
          return const Center(child: Text('게시글이 없습니다.'));
        }

        return Column(
          children: posts.map((post) {
            return GestureDetector(
              onTap: () => onPostTap?.call(post),
              child: PostCard(post: post),
            );
          }).toList(),
        );
      },
    );
  }
}
