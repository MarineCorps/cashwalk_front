import 'package:flutter/material.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/models/ranking_user.dart';
import 'package:cashwalk/page/cashtalk/chat_room_screen.dart';
import 'package:cashwalk/services/chat_service.dart';
import 'package:cashwalk/services/http_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  Future<List<RankingUser>> fetchRanking() async {
    final token = await JwtStorage.getToken();
    final response = await HttpService.getFromServer(
      '/api/ranking/daily',
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response is List) {
      return response.map((e) => RankingUser.fromJson(e)).toList();
    } else {
      throw Exception('랭킹 조회 실패');
    }
  }

  void _startChatWithUser(int friendUserId, String nickname) async {
    try {
      final roomId = await ChatService.getOrCreateChatRoom(friendUserId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chatRoomId: roomId,
            friendUserId: friendUserId,
            friendNickname: nickname,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 채팅방 열기 실패: $e')),
      );
    }
  }

  Widget _buildUserTile(RankingUser user, int index) {
    final rankText = '${index + 1}위';
    final isSelf = user.isMe;
    final isTop1 = index == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isTop1 ? Colors.yellow[100] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            rankText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(width: 12),

          // ✅ 순위에 따라 트로피 색상 지정
          if (index == 0)
            const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 24) // 금색
          else if (index == 1)
            const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 24) // 은색
          else if (index == 2)
              const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 24) // 동색
            else
              const SizedBox(width: 0), // 4등 이후는 트로피 없음

          if (index < 3) const SizedBox(width: 12), // 트로피가 있을 경우만 간격 추가

          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.nickname}${isSelf ? " (나)" : ""}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.directions_walk, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${user.stepCount} 걸음',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!isSelf)
            TextButton(
              onPressed: () => _startChatWithUser(user.userId, user.nickname),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
              child: const Text('응원', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),

    );
  }

  Widget _buildBottomCard(RankingUser topUser) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.yellow[700]!, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                topUser.nickname,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.directions_walk, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${topUser.stepCount}',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: FutureBuilder<List<RankingUser>>(
        future: fetchRanking(), // ✅ 안전하게 바로 FutureBuilder에 넣음
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          final rankingList = snapshot.data!;
          final firstUser = rankingList.first;
          final otherUsers = rankingList.sublist(1);

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...rankingList.asMap().entries.map((entry) {
                    return _buildUserTile(entry.value, entry.key);
                  }).toList(),
                ],
              ),
              _buildBottomCard(firstUser),
            ],
          );
        },
      ),
    );
  }
}
