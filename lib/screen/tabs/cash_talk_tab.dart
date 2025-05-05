import 'package:flutter/material.dart';
import 'package:cashwalk/page/cashtalk/cash_talk_friend.dart';
import 'package:cashwalk/page/cashtalk/chat_list_screen.dart';
import 'package:cashwalk/page/cashtalk/ranking_screen.dart';
import 'package:cashwalk/screen/home_screen.dart'; // ✅ 홈 전체 구조

class CashTalkTab extends StatefulWidget {
  const CashTalkTab({super.key});

  @override
  State<CashTalkTab> createState() => _CashTalkTabState();
}

class _CashTalkTabState extends State<CashTalkTab> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    CashTalkHome(),
    ChatListScreen(),
    RankingScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캐시톡'),
        backgroundColor: Colors.yellow[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ✅ 실무 방식: 전체 HomePage로 초기화 + index 0 (HomeTab)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const HomePage(initialIndex: 0),
              ),
                  (route) => false,
            );
          },
        ),
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: '랭킹'),
        ],
      ),
    );
  }
}
