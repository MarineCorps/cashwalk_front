import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cashwalk/services/user_service.dart';

import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/screen/tutorial_page.dart';


class ProfileSetting extends StatefulWidget {
  @override
  State<ProfileSetting> createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  String? _userInfo;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    _loadProfileImage();
  }

  Future<void> _loadUserInfo() async {
    final token = await JwtStorage.getToken();
    if (token == null) {
      setState(() {
        _userInfo = '로그인이 필요합니다.';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() {
        _userInfo = '닉네임: ${decoded['nickname']}\n포인트: ${decoded['point']}P';
      });
    } else {
      setState(() {
        _userInfo = '사용자 정보를 불러올 수 없습니다.';
      });
    }
  }

  Future<void> _logout() async {
    await JwtStorage.deleteToken();
    UserService.clearCache();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TutorialPage()),
          (route) => false,
    );
  }

  Future<void> _loadProfileImage() async {
    final url = await UserService.getProfileImageUrl();
    if (mounted) {
      setState(() {
        profileImageUrl = url;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('👤 내 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(_userInfo ?? '불러오는 중...', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
