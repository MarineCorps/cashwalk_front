import 'package:flutter/material.dart';
import 'package:cashwalk/services/user_service.dart';
import 'package:cashwalk/page/community/mypage.dart';
import 'package:flutter/services.dart';

class UserProfileBlock extends StatelessWidget {
  final VoidCallback onWritePost;

  const UserProfileBlock({super.key, required this.onWritePost});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: UserService.fetchMyProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final user = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ✅ 프로필 이미지
                FutureBuilder<String>(
                  future: UserService.getProfileImageUrl(),
                  builder: (context, imgSnap) {
                    final imageProvider = (imgSnap.hasData && imgSnap.data != null)
                        ? (imgSnap.data!.startsWith('http')
                        ? NetworkImage(imgSnap.data!)
                        : AssetImage(imgSnap.data!) as ImageProvider)
                        : const AssetImage('assets/images/woobin.png');

                    return CircleAvatar(
                      radius: 24,
                      backgroundImage: imageProvider,
                    );
                  },
                ),

                const SizedBox(width: 12),

                /// ✅ 닉네임 & 추천코드
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.nickname, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('추천인 코드 ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(user.inviteCode, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: user.inviteCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('추천인 코드가 복사되었습니다.')),
                              );
                            },
                            child: const Icon(Icons.copy, size: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// ✅ 설정 버튼
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pop(context); // 드로워 닫기
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPage()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ✅ 2x2 통계 영역
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.5,
                children: const [
                  _StatTile(label: '쪽지', count: 0),
                  _StatTile(label: '알림', count: 0),
                  _StatTile(label: '스크랩', count: 1),
                  _StatTile(label: '작성글 보기', count: null),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int? count;

  const _StatTile({required this.label, this.count});

  @override
  Widget build(BuildContext context) {
    final countText = count != null ? count.toString() : '';
    final highlight = count != null && count! > 0;


    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            countText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.orange : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }
}
