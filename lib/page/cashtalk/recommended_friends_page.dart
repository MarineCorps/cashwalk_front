import 'package:flutter/material.dart';
import 'package:cashwalk/services/friend_service.dart';
import 'package:cashwalk/models/recommended_user.dart';

class RecommendedFriendsPage extends StatefulWidget {
  const RecommendedFriendsPage({super.key});

  @override
  State<RecommendedFriendsPage> createState() => _RecommendedFriendsPageState();
}

class _RecommendedFriendsPageState extends State<RecommendedFriendsPage> {
  List<RecommendedUser> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      final users = await FriendService.getRecommendedFriends();
      setState(() => _users = users);
    } catch (e) {
      debugPrint('추천 친구 조회 실패: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _request(int userId) async {
    final success = await FriendService.sendFriendRequest(userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구 요청을 보냈습니다')),
      );
      _fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 친구'),
        backgroundColor: Colors.yellow[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.nickname),
              trailing: ElevatedButton(
                onPressed: () => _request(user.userId),
                child: const Text('친구 요청'),
              ),
            ),
          );
        },
      ),
    );
  }
}
