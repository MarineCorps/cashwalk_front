import 'package:flutter/material.dart';
import 'package:cashwalk/screen/settings/profile_setting.dart';
import 'package:cashwalk/page/cashtalk/invite_friends_page.dart';
class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool isDoubleAuth = false;
  bool isLockScreen = false;
  bool isEffectSound = false;
  bool isVibration = false;
  bool isNewsVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text('설정', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.smartphone, color: Colors.black),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('현재 버전 2.0.6'),
                    Text('최신 버전 2.0.6'),
                  ],
                ),
                Text('최신 버전 사용 중', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // 내정보
          _buildSectionTitle('내정보'),
          _buildNavTile(
            '프로필설정',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>ProfileSettingPage()),
              );
            },
          ),
          _buildNavTile('캐시적립내역'),
          _buildNavTile('캐시웨어'),
          _buildNavTile(
            '친구초대',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>InviteFriendsPage()),
              );
            },
          ),
          _buildToggleTile('이중인증', isDoubleAuth, (v) => setState(() => isDoubleAuth = v)),

          // 잠금화면 관리
          _buildSectionTitle('잠금화면 관리'),
          _buildNavTile('배경사진 바꾸기'),
          _buildNavTile('상단 아이콘 편집하기'),
          _buildToggleTile('잠금화면 사용하기', isLockScreen, (v) => setState(() => isLockScreen = v)),

          // 기타 기능
          _buildToggleTile('효과음', isEffectSound, (v) => setState(() => isEffectSound = v)),
          _buildToggleTile('진동', isVibration, (v) => setState(() => isVibration = v)),
          _buildToggleTile('뉴스 컨텐츠 보기', isNewsVisible, (v) => setState(() => isNewsVisible = v)),

          // 알림
          _buildSectionTitle('알림'),
          _buildNavTile('푸시 알림설정'),

          // 앱 정보
          _buildSectionTitle('앱정보'),
          _buildNavTile('자주하는질문'),
          _buildNavTile('불편사항 신고하기'),
          _buildNavTile('이용약관동의'),
          _buildNavTile('개인정보처리방침'),
          _buildNavTile('위치기반 서비스 이용약관'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildNavTile(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},  // onTap이 없으면 빈 함수
    );
  }


  Widget _buildToggleTile(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: value ? Colors.grey : Colors.grey[300],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
