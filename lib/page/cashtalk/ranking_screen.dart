import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/models/ranking_user.dart';
import 'package:cashwalk/page/cashtalk/chat_room_screen.dart'; // ✅ 채팅 화면 import

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  Future<List<RankingUser>> fetchRanking() async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/ranking/daily'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => RankingUser.fromJson(e)).toList();
    } else {
      throw Exception('랭킹 조회 실패');
    }
  }

  void _startChatWithUser(int friendUserId, String nickname) async {
    final token = await JwtStorage.getToken();

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/chat/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({"friendUserId": friendUserId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final chatRoomId = data['chatRoomId'];
      final friendName = data['friendNickname'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            chatRoomId: chatRoomId,
            friendUserId: friendUserId,      // ✅ 추가
            friendNickname: friendName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$nickname님과 채팅방을 여는 데 실패했습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 걸음 수 랭킹'),
        backgroundColor: Colors.yellow[700],
      ),
      body: FutureBuilder<List<RankingUser>>(
        future: fetchRanking(),
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

          return Column(
            children: [
              const SizedBox(height: 12),

              // 🥇 상단 고정 1등
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.orange, size: 32),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${firstUser.nickname}${firstUser.isMe ? " (나)" : ""}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text('${firstUser.stepCount} 걸음'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _startChatWithUser(firstUser.userId, firstUser.nickname),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                      ),
                      child: const Text('응원하기'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 나머지 랭킹 리스트
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: otherUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = otherUsers[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          '${user.nickname}${user.isMe ? " (나)" : ""}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${user.stepCount} 걸음'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${index + 2}위', style: const TextStyle(fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () => _startChatWithUser(user.userId, user.nickname),
                              child: const Text('응원', style: TextStyle(color: Colors.orange)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
