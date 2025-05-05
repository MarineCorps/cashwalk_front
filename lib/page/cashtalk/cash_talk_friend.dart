import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashwalk/services/friend_service.dart'; // 친구 관리 기능
import 'package:cashwalk/models/friend_user.dart';      // 친구 모델
import 'package:cashwalk/utils/font_service.dart';      // HttpService 사용
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/page/cashtalk/friend_manage_screen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cashwalk/services/http_service.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/models/friend_user.dart';
import 'package:cashwalk/page/cashtalk/chat_room_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:cashwalk/services/chat_api_service.dart'; // ✅ 추가
class CashTalkHome extends StatefulWidget {
  const CashTalkHome({super.key});

  @override
  State<CashTalkHome> createState() => _CashTalkHomeState();
}

class _CashTalkHomeState extends State<CashTalkHome> {
  String? nickname;
  String? inviteCode;
  String? profileImageUrl;
  String? myRole;
  Set<int> sentToday = {};

  List<FriendUser> myFriends = [];
  bool isLoadingFriends = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchMyFriends();
  }

  Future<void> _fetchUserInfo() async {
    final token = await JwtStorage.getToken();
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await HttpService.getFromServer('/api/users/me', headers: headers);
      setState(() {
        nickname = response['nickname'];
        inviteCode = response['inviteCode'];
        profileImageUrl = response['profileImageUrl'];
        myRole = response['role'];
      });
    } catch (e) {
      debugPrint('내 정보 불러오기 실패: $e');
    }
  }

  Future<void> _sendLuckyCash(int receiverId, String nickname) async {
    final generatedMessageId = const Uuid().v4(); // ✅ messageId 생성

    try {
      final roomId = await ChatApiService.sendLuckyCash(
        receiverId: receiverId,
        messageId: generatedMessageId,
      );

      if (myRole != 'ROLE_ADMIN') {
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

  void _copyCode() {
    if (inviteCode != null) {
      Clipboard.setData(ClipboardData(text: inviteCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추천 코드가 복사되었습니다')),
      );
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('캐시톡', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.yellow[700],
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

          // 광고 배너
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🧃 광고 배너')),
          ),

          // 검색창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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

          ListTile(
            leading: CircleAvatar(
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            title: Text(nickname ?? '닉네임'),
            subtitle: Text('내 추천코드: ${inviteCode ?? '불러오는 중...'}'),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyCode,
            ),
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
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
                          Text('친구${index + 1}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown[300],
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ✅ 작게
                            ),
                            child: const Text('친구추가', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    )

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
              final bool alreadySent = sentToday.contains(friend.id);
              final bool isAdmin = myRole == 'ROLE_ADMIN';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend.profileImage.isNotEmpty
                      ? NetworkImage(friend.profileImage)
                      : const AssetImage('assets/images/woobin.png') as ImageProvider,
                ),
                title: Text(friend.nickname),
                subtitle: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
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

                onTap: () {},
              );
            }).toList(),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

}
