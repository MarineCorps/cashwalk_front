import 'package:flutter/material.dart';
import 'package:cashwalk/services/friend_service.dart';
import 'package:cashwalk/services/chat_service.dart';
import 'package:cashwalk/models/friend_user.dart'; // ✅ 교체
import 'package:cashwalk/page/cashtalk/chat_room_screen.dart';

class MyFriendTab extends StatefulWidget {
  const MyFriendTab({super.key});

  @override
  State<MyFriendTab> createState() => _MyFriendTabState();
}

class _MyFriendTabState extends State<MyFriendTab> {
  List<FriendUser> _friends = []; // ✅ 모델 타입 교체
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _showFriendProfileModal(FriendUser friend) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: friend.profileImage.isNotEmpty
                    ? NetworkImage(friend.profileImage)
                    : null,
                backgroundColor: Colors.grey[300],
                child: friend.profileImage.isEmpty ? const Icon(Icons.person, size: 40) : null,
              ),
              const SizedBox(height: 12),
              Text(
                String.fromCharCodes(friend.nickname.runes),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final roomId = await ChatService.getOrCreateChatRoom(friend.id); // 채팅방 ID 받아오기
                      Navigator.pop(context); // 모달 닫기
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            chatRoomId: roomId,
                            friendUserId: friend.id,         // ✅ 추가
                            friendNickname: friend.nickname,
                          ),
                        ),
                      );
                    } catch (e) {
                      print('채팅방 생성 실패: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('채팅방 생성에 실패했습니다.')),
                      );
                    }
                  },
                  child: const Text('응원 & 채팅하기'),
                ),

              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _removeFriend(int friendId) async {
    try {
      await FriendService.deleteFriend(friendId);
      await _loadFriends(); // 삭제 후 목록 새로고침
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구를 끊었습니다.')),
      );
    } catch (e) {
      print('친구 삭제 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구 삭제에 실패했습니다.')),
      );
    }
  }


  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    try {
      final results = await FriendService.getMyFriends(query: _searchQuery);
      setState(() => _friends = results);
    } catch (e) {
      print('친구 목록 불러오기 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: '친구 이름 검색하기',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _friends.isEmpty
              ? const Center(child: Text('친구가 없습니다.'))
              : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _friends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = _friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.profileImage.isNotEmpty
                      ? NetworkImage(user.profileImage)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: user.profileImage.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(user.nickname),
                trailing: TextButton(
                  onPressed: () => _removeFriend(user.id), // ✅ 친구삭제 호출
                  child: const Text('친구끊기', style: TextStyle(color: Colors.red)),
                ),
                onTap: () {
                  _showFriendProfileModal(user);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
