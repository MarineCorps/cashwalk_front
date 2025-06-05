import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashwalk/services/user_service.dart';
import 'mypage.dart';
import 'user_profile_block.dart'; // ✅ 프로필 블록 import

class CommunityDrawer extends StatefulWidget {
  final VoidCallback onWritePost;
  final List<String> favoriteBoards;
  final Function(String) onToggleFavorite;

  const CommunityDrawer({
    super.key,
    required this.onWritePost,
    required this.favoriteBoards,
    required this.onToggleFavorite,
  });

  @override
  State<CommunityDrawer> createState() => _CommunityDrawerState();
}

class _CommunityDrawerState extends State<CommunityDrawer> {
  bool isFavoritesOpen = true;

  final List<String> allBoards = [
    'BEST 인기글 (실시간)',
    'BEST 인기글 (명예의 전당)',
    '캐시톡 친구 추가 모집',
    '하루 6천보 걷기 챌린지',
    '게시판 오픈 신청',
    '공지사항',
    '질문답변',
  ];

  String resolveLabel(String key) {
    switch (key) {
      case 'FRIEND_RECRUIT':
        return '캐시톡 친구 추가 모집';
      case 'BOARD_OPEN_REQUEST':
        return '게시판 오픈 신청';
      case 'NOTICE':
        return '공지사항';
      case 'GENERAL':
        return '전체글';
      case 'BESTLIVE':
        return 'BEST 인기글 (실시간)';
      case 'LEGEND':
        return 'BEST 인기글 (명예의 전당)';
      case 'QNA':
        return '질문답변';
      default:
        return key;
    }
  }

  String? resolveBoardType(String label) {
    switch (label) {
      case '캐시톡 친구 추가 모집':
        return 'FRIEND_RECRUIT';
      case '하루 6천보 걷기 챌린지':
        return 'DAILY_CHALLENGE';
      case '게시판 오픈 신청':
        return 'BOARD_OPEN_REQUEST';
      case '공지사항':
        return 'NOTICE';
      case '전체글':
        return 'GENERAL';
      case '질문답변':
        return 'QNA';
      default:
        return null;
    }
  }

  String? resolvePostCategory(String label) {
    switch (label) {
      case 'BEST 인기글 (실시간)':
        return 'BESTLIVE';
      case 'BEST 인기글 (명예의 전당)':
        return 'LEGEND';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 20),

            /// ✅ 사용자 프로필 블록 (리팩토링된 컴포넌트 사용)
            UserProfileBlock(onWritePost: widget.onWritePost),

            const SizedBox(height: 16),

            /// ✅ 게시글 작성 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onWritePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEB00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('게시글 작성', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),

            /// ✅ 즐겨찾기 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('즐겨찾기', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(isFavoritesOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  onPressed: () {
                    setState(() {
                      isFavoritesOpen = !isFavoritesOpen;
                    });
                  },
                ),
              ],
            ),

            if (isFavoritesOpen)
              widget.favoriteBoards.isEmpty
                  ? Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '게시판 제목의\n아이콘을 선택하면\n즐겨찾기에 추가됩니다.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
                  : Column(
                children: widget.favoriteBoards.map((enumKey) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(resolveLabel(enumKey)),
                    trailing: const Icon(Icons.star, color: Colors.amber),
                    onTap: () => widget.onToggleFavorite(enumKey),
                  );
                }).toList(),
              ),

            const Divider(height: 24),

            /// ✅ 전체글 탭
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('전체글'),
              onTap: () {
                final boardType = resolveBoardType('전체글');
                if (boardType != null) {
                  widget.onToggleFavorite(boardType);
                }
              },
            ),

            const Divider(height: 16),
            const Text('캐시워크 커뮤니티', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            /// ✅ 전체 게시판 리스트
            ...allBoards.map((label) {
              final isFavorited = widget.favoriteBoards.contains(resolveBoardType(label)) ||
                  widget.favoriteBoards.contains(resolvePostCategory(label));
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Text(label),
                    const SizedBox(width: 6),
                    const CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.red,
                      child: Text('N', style: TextStyle(fontSize: 8, color: Colors.white)),
                    ),
                  ],
                ),
                trailing: Icon(
                  isFavorited ? Icons.star : Icons.star_border,
                  color: isFavorited ? Colors.amber : Colors.grey,
                ),
                onTap: () {
                  final boardType = resolveBoardType(label);
                  final postCategory = resolvePostCategory(label);
                  final resolved = boardType ?? postCategory;

                  if (resolved != null) {
                    widget.onToggleFavorite(resolved);
                  } else {
                    debugPrint('❌ 등록 불가 board: $label');
                  }
                },
              );
            }).toList(),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEB00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('게시판 전체보기', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final int count;

  const _InfoBox({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
