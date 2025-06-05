import 'package:flutter/material.dart';
import 'package:cashwalk/page/cashtalk/cash_talk_friend.dart';
import 'package:cashwalk/page/cashtalk/chat_list_screen.dart';
import 'package:cashwalk/page/cashtalk/ranking_screen.dart';
import 'package:cashwalk/screen/home_screen.dart';

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

  final List<String> _titles = [
    '친구 목록',
    '채팅방',
    '랭킹',
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const Color yellow = Color(0xFFFFD400); // ✅ 캐시워크 대표색

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: yellow, // ✅ 상단 AppBar 색상 통일
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const HomePage(initialIndex: 0),
              ),
                  (route) => false,
            );
          },
        ),
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _tabs[_selectedIndex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: yellow, // ✅ 하단 색상도 동일하게
        currentIndex: _selectedIndex,
        onTap: _onTap,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: '친구',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: '랭킹',
          ),
        ],
      ),
    );
  }
}
