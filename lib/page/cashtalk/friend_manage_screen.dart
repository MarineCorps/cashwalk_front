import 'package:flutter/material.dart';
import 'package:cashwalk/page/cashtalk/my_friend_tab.dart';
import 'package:cashwalk/page/cashtalk/new_friend_search_tab.dart';
import 'package:cashwalk/page/cashtalk/friend_request_page.dart';
import 'package:cashwalk/page/cashtalk/recommended_friends_page.dart';
import 'package:cashwalk/page/cashtalk/invite_friends_page.dart';
import 'package:cashwalk/page/cashtalk/chat_block_manage_page.dart';

/// 친구 관리 전체 화면 (탭: 내 친구 / 새 친구 찾기)
class FriendManageScreen extends StatefulWidget {
  final int initialTabIndex; // ⬅️ 탭 인덱스를 외부에서 받을 수 있도록

  const FriendManageScreen({super.key, this.initialTabIndex = 0});

  @override
  State<FriendManageScreen> createState() => _FriendManageScreenState();
}

class _FriendManageScreenState extends State<FriendManageScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text('친구 관리'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'request':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FriendRequestPage()),
                  );
                  break;
                case 'recommend':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecommendedFriendsPage()),
                  );
                  break;
                case 'invite':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InviteFriendsPage()),
                  );
                  break;
                case 'block':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatBlockManagePage()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'request', child: Text('친구 요청 관리')),
              const PopupMenuItem(value: 'recommend', child: Text('추천 친구')),
              const PopupMenuItem(value: 'invite', child: Text('친구 초대')),
              const PopupMenuItem(value: 'block', child: Text('채팅 차단 관리')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: '내 친구'),
            Tab(text: '새 친구 찾기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MyFriendTab(),
          NewFriendSearchTab(),
        ],
      ),
    );
  }
}
