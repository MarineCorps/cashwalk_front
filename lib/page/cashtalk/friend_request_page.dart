import 'package:flutter/material.dart';
import 'package:cashwalk/services/friend_service.dart';
import 'package:cashwalk/models/friend_request_result.dart';
import 'package:cashwalk/utils/font_service.dart'; // ✅ HttpService 활용

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage({super.key});

  @override
  State<FriendRequestPage> createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    FriendService.refreshFriendRequests(); // ✅ 자동 처리
  }

  Future<void> _accept(int senderId) async {
    final success = await FriendService.acceptFriendRequest(senderId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('친구 추가 완료')));
    }
  }

  Future<void> _reject(int senderId) async {
    final success = await FriendService.rejectFriendRequest(senderId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('요청 거절 완료')));
    }
  }

  Widget _buildRequestTile(FriendRequestResult request, {bool isReceived = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(request.nickname),
        subtitle: Text('${request.createdAt.toLocal()}'),
        trailing: isReceived
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _accept(request.userId),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _reject(request.userId),
            ),
          ],
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 요청 관리'),
        backgroundColor: Colors.yellow[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          tabs: const [
            Tab(text: '받은 요청'),
            Tab(text: '보낸 요청'),
          ],
        ),
      ),
      body: StreamBuilder<List<FriendRequestResult>>(
        stream: FriendService.friendRequestStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final received = all.where((r) => !r.sentByMe).toList();
          final sent = all.where((r) => r.sentByMe).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              ListView(children: received.map((r) => _buildRequestTile(r, isReceived: true)).toList()),
              ListView(children: sent.map((r) => _buildRequestTile(r)).toList()),
            ],
          );
        },
      ),
    );
  }
}
