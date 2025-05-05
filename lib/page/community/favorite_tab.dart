import 'package:flutter/material.dart';
import 'package:cashwalk/services/community_service.dart';
import 'package:cashwalk/widgets/post_card.dart';

class FavoriteTab extends StatefulWidget {
  final List<String> favoriteBoards; // ex: ["FREE", "BESTLIVE"]
  final Function(String)? onSeeMore;
  final Function(Map<String, dynamic>)? onPostTap;

  const FavoriteTab({
    super.key,
    required this.favoriteBoards,
    this.onSeeMore,
    this.onPostTap,
  });

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  final Map<String, List<Map<String, dynamic>>> _postsByKey = {};
  final Map<String, bool> _loadingStates = {};

  final Set<String> validBoardTypes = {
    'FREE',
    'FRIEND_RECRUIT',
    'BOARD_OPEN_REQUEST',
    'DAILY_CHALLENGE',
    'NOTICE',
    'QNA'
  };

  final Set<String> validPostCategories = {
    'GENERAL',
    'BESTLIVE',
    'LEGEND',
  };

  @override
  void initState() {
    super.initState();
    _loadAllFavorites();
  }

  Future<void> _loadAllFavorites() async {
    for (final key in widget.favoriteBoards) {
      setState(() => _loadingStates[key] = true);

      try {
        List<Map<String, dynamic>> posts = [];

        if (validBoardTypes.contains(key)) {
          final result = await CommunityService.searchPosts(boardType: key, page: 0, size: 3);
          posts = List<Map<String, dynamic>>.from(result);
        } else if (validPostCategories.contains(key)) {
          final result = await CommunityService.searchPosts(postCategory: key, page: 0, size: 3);
          posts = List<Map<String, dynamic>>.from(result);
        } else {
          debugPrint('❌ 유효하지 않은 즐겨찾기 필터: $key');
          continue;
        }

        setState(() => _postsByKey[key] = posts);
      } catch (e) {
        debugPrint('❌ $key 게시글 로딩 실패: $e');
        setState(() => _postsByKey[key] = []);
      } finally {
        setState(() => _loadingStates[key] = false);
      }
    }
  }

  String resolveLabel(String key) {
    switch (key) {
      case 'FREE': return '자유/일상';
      case 'FRIEND_RECRUIT': return '친구모집';
      case 'BOARD_OPEN_REQUEST': return '게시판 오픈 요청';
      case 'DAILY_CHALLENGE': return '6천보 챌린지';
      case 'NOTICE': return '공지사항';
      case 'QNA' : return '공지사항';
      case 'GENERAL': return '전체글';
      case 'BESTLIVE': return '인기글 (실시간)';
      case 'LEGEND': return '명예의 전당';
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredKeys = widget.favoriteBoards.where(
          (key) => validBoardTypes.contains(key) || validPostCategories.contains(key),
    ).toList();

    if (filteredKeys.isEmpty) {
      return const Center(child: Text('즐겨찾기한 게시판이 없습니다.'));
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: filteredKeys.map((key) {
        final posts = _postsByKey[key] ?? [];
        final isLoading = _loadingStates[key] ?? true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(resolveLabel(key), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => widget.onSeeMore?.call(key),
                    child: Row(
                      children: const [
                        Text('더보기', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ...posts.map((post) => GestureDetector(
                onTap: () => widget.onPostTap?.call(post),
                child: PostCard(post: post),
              )),
            const Divider(height: 24),
          ],
        );
      }).toList(),
    );
  }
}
