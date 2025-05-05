import 'package:flutter/material.dart';
import 'package:cashwalk/models/blocked_user.dart';
import 'package:cashwalk/services/friend_service.dart';

class ChatBlockManagePage extends StatefulWidget {
  const ChatBlockManagePage({super.key});

  @override
  State<ChatBlockManagePage> createState() => _ChatBlockManagePageState();
}

class _ChatBlockManagePageState extends State<ChatBlockManagePage> {
  List<BlockedUser> _blocked = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBlocked();
  }

  Future<void> _fetchBlocked() async {
    try {
      final users = await FriendService.getBlockedUsers();
      setState(() => _blocked = users);
    } catch (e) {
      debugPrint('차단 유저 조회 실패: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _unblock(int userId) async {
    final success = await FriendService.unblockUser(userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차단 해제되었습니다')),
      );
      _fetchBlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('차단 친구 관리'),
        backgroundColor: Colors.yellow[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _blocked.isEmpty
          ? const Center(child: Text('차단한 친구가 없습니다'))
          : ListView.builder(
        itemCount: _blocked.length,
        itemBuilder: (context, index) {
          final user = _blocked[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.person_off),
              title: Text(user.nickname),
              trailing: ElevatedButton(
                onPressed: () => _unblock(user.userId),
                child: const Text('차단 해제'),
              ),
            ),
          );
        },
      ),
    );
  }
}
