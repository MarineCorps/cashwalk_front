import 'package:flutter/material.dart';
import 'package:cashwalk/screen/tabs/home_tab.dart';
import 'package:cashwalk/screen/tabs/cash_talk_tab.dart';
import 'package:cashwalk/screen/tabs/benefit_tab.dart';
import 'package:cashwalk/screen/tabs/coupon_tab.dart';
import 'package:cashwalk/screen/tabs/settings_tab.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0}); // 기본값은 홈탭

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex; // ✅ 초기화는 initState에서 처리

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // ✅ 전달받은 index로 초기화
  }

  final List<Widget> _tabs = [
    HomeTab(),         // 홈 콘텐츠
    CashTalkTab(),     // 캐시톡
    BenefitTab(),      // 혜택
    CouponTab(),       // 교환권
    SettingsTab(),     // 설정
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: _currentIndex == 1
          ? null // ✅ 캐시톡 탭일 때는 BottomNavigationBar 숨김
          : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.yellow[700],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '캐시톡'),
          BottomNavigationBarItem(icon: Icon(Icons.cached), label: '혜택'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: '교환권'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
