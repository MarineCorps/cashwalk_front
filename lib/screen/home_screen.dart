import 'package:flutter/material.dart';
import 'package:cashwalk/screen/tabs/home_tab.dart';
import 'package:cashwalk/screen/tabs/cash_talk_tab.dart';
import 'package:cashwalk/screen/tabs/benefit_tab.dart';
import 'package:cashwalk/screen/tabs/coupon_tab.dart';
import 'package:cashwalk/screen/tabs/settings_tab.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _tabs = [
    HomeTab(),
    CashTalkTab(),
    BenefitTab(),
    CouponTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFD400); // 통일된 진노랑
    return Scaffold(
      backgroundColor: Colors.white,
      body: _tabs[_currentIndex],
      bottomNavigationBar: _currentIndex == 1
          ? null
          : BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: yellow,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '캐시톡',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: '혜택',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: '교환권',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
