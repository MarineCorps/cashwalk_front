import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashwalk/services/friend_service.dart';
import 'package:cashwalk/models/friend_user.dart';
import 'package:cashwalk/page/cashtalk/friend_manage_screen.dart';
import 'package:cashwalk/page/cashtalk/chat_room_screen.dart';
import 'package:cashwalk/services/chat_api_service.dart';
import 'package:cashwalk/services/user_service.dart'; // ✅ 핵심
import 'package:uuid/uuid.dart';

class CashTalkHome extends StatefulWidget {
  const CashTalkHome({super.key});

  @override
  State<CashTalkHome> createState() => _CashTalkHomeState();
}

class _CashTalkHomeState extends State<CashTalkHome> {
  Set<int> sentToday = {};
  List<FriendUser> myFriends = [];
  List<Map<String, dynamic>> luckyFriends = [];
  bool isLoadingFriends = true;
  bool isLoadingLucky = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await UserService.fetchMyProfile(); // ✅ 사용자 정보 한번만 불러오고 캐싱
    await Future.wait([
      _fetchMyFriends(),
      _fetchLuckyFriends(),
    ]);
  }

  Future<void> _fetchMyFriends() async {
    try {
      final friends = await FriendService.getMyFriends();
      setState(() {
        myFriends = friends;
        isLoadingFriends = false;
      });
    } catch (e) {
      debugPrint('❌ 친구 목록 불러오기 실패: $e');
      setState(() => isLoadingFriends = false);
    }
  }

  Future<void> _fetchLuckyFriends() async {
    try {
      final result = await ChatApiService.getLuckyFriends();
      setState(() {
        luckyFriends = result;
        isLoadingLucky = false;
      });
    } catch (e) {
      debugPrint('❌ 행운 친구 불러오기 실패: $e');
      setState(() => isLoadingLucky = false);
    }
  }

  Future<void> _sendLuckyCash(int receiverId, String nickname) async {
    final messageId = const Uuid().v4();
    try {
      final roomId = await ChatApiService.sendLuckyCash(
        receiverId: receiverId,
        messageId: messageId,
      );

      if (UserService.currentUser?.id != 'ROLE_ADMIN') {
        sentToday.add(receiverId);
        setState(() {});
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatRoomId: roomId,
              friendUserId: receiverId,
              friendNickname: nickname,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 전송 실패: $e')),
      );
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: UserService.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('추천 코드가 복사되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color cashwalkYellow = Color(0xFFFFD400);
    const Color pageBackground = Color(0xFFF9F9F9);

    return Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          backgroundColor: cashwalkYellow,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FriendManageScreen(initialTabIndex: 1)),
                );
              },
            ),
            const SizedBox(width: 12),
            const Icon(Icons.settings),
            const SizedBox(width: 16),
          ],
        ),

        body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🧃 광고 배너')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendManageScreen(initialTabIndex: 0),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('친구 이름 검색하기', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('내 프로필', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: UserService.getProfileImageUrl(),
            builder: (context, snapshot) {
              final image = snapshot.hasData
                  ? NetworkImage(snapshot.data!)
                  : const AssetImage('assets/images/woobin.png') as ImageProvider;
              return ListTile(
                leading: CircleAvatar(backgroundImage: image),
                title: Text(UserService.nickname),
                subtitle: Text('내 추천코드: ${UserService.inviteCode}'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyCode,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text('추가한 채널', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.verified, color: Colors.yellow),
            ),
            title: const Text('캐시워크', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('캐시워크 공식 채널입니다.'),
          ),
          const SizedBox(height: 24),
          const Text('오늘의 행운 친구 🍀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: isLoadingLucky
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: luckyFriends.length,
              itemBuilder: (context, index) {
                final friend = luckyFriends[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                        const SizedBox(height: 8),
                        Text(friend['nickname'] ?? '닉네임 없음', style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () {
                            // ✅ 아직 친구가 아닌 경우 친구추가 페이지로 유도하거나 API 호출 가능
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[300],
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: const Text('친구추가', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('친구', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          isLoadingFriends
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: myFriends.map((friend) {
              final alreadySent = sentToday.contains(friend.id);
              final isAdmin = UserService.currentUser?.id == 'ROLE_ADMIN';
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend.profileImage.isNotEmpty
                      ? NetworkImage(friend.profileImage)
                      : const AssetImage('assets/images/woobin.png') as ImageProvider,
                ),
                title: Text(friend.nickname),
                subtitle: Wrap(
                  spacing: 8,
                  children: [
                    if (!alreadySent || isAdmin)
                      ElevatedButton(
                        onPressed: () => _sendLuckyCash(friend.id, friend.nickname),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
                        child: const Text('행운캐시 보내기'),
                      )
                    else
                      const Text('✅ 오늘 보냈습니다', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
