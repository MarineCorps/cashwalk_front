import 'package:flutter/material.dart';
import 'package:cashwalk/services/friend_service.dart';
import 'package:cashwalk/models/friend_search_result.dart';

class NewFriendSearchTab extends StatefulWidget {
  const NewFriendSearchTab({super.key});

  @override
  State<NewFriendSearchTab> createState() => _NewFriendSearchTabState();
}

class _NewFriendSearchTabState extends State<NewFriendSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  FriendSearchResult? _searchedUser;
  String? _errorMessage;

  Future<void> _search() async {
    final code = _searchController.text.trim().toUpperCase();
    setState(() {
      _errorMessage = null;
      _searchedUser = null;
    });

    try {
      final user = await FriendService.searchUserByInviteCode(code);
      if (user == null) {
        setState(() => _errorMessage = '해당 추천코드를 가진 사용자를 찾을 수 없습니다.');
      } else {
        setState(() => _searchedUser = user);
      }
    } catch (e) {
      setState(() => _errorMessage = '검색 실패: ${e.toString()}');
    }
  }

  Future<void> _sendRequest() async {
    if (_searchedUser == null) return;

    final success = await FriendService.sendFriendRequest(_searchedUser!.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구 요청을 보냈습니다')),
      );
      setState(() {
        _searchedUser = null;
        _searchController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('요청 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '추천 코드 입력',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _search,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (_searchedUser != null)
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(_searchedUser!.nickname),
              subtitle: Text('추천코드: ${_searchedUser!.inviteCode}'),
              trailing: ElevatedButton(
                onPressed: _sendRequest,
                child: const Text('친구 추가'),
              ),
            ),
          ),
      ],
    );
  }
}
