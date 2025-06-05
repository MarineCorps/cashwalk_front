import 'package:flutter/material.dart';
import 'package:cashwalk/services/user_service.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/screen/tutorial_page.dart'; 

class ProfileSettingPage extends StatefulWidget {
  const ProfileSettingPage({super.key});

  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  UserProfile? userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final profile = await UserService.fetchMyProfile();
    setState(() {
      userInfo = profile;
    });
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

  Widget buildItem(String title, String? value, VoidCallback? onTap) {
    return ListTile(
      title: Text(title),
      trailing: Text(value ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필설정'),
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ 프로필 헤더
          Row(
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userInfo!.nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${userInfo!.points ?? 0} 캐시", style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // ✅ 설정 항목
          buildItem("이름 및 사진", userInfo!.nickname, () => _editTextField("nickname", "닉네임")),
          buildItem("추천코드", userInfo!.inviteCode, null),
          buildItem("제휴코드 등록", "", () => _showPlaceholderDialog("제휴코드 등록")),
          buildItem("키", userInfo!.height != null ? "${userInfo!.height}cm" : null, () => _editNumberField("height", "키")),
          buildItem("몸무게", userInfo!.weight != null ? "${userInfo!.weight}kg" : null, () => _editNumberField("weight", "몸무게")),
          buildItem("거주지역", userInfo!.region, () => _editTextField("region", "거주지역")),
          buildItem("성별", userInfo!.gender, () => _editGenderField("gender")),
          buildItem("생년월일", userInfo!.birthDate, () => _editDateField("birthDate")),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text("로그아웃"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  void _editTextField(String key, String label) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label 수정'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: '$label 입력'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              final token = await JwtStorage.getToken();
              if (token == null) return;

              await UserService.updateProfileField(token,
                nickname: key == 'nickname' ? value : null,
                region: key == 'region' ? value : null,
              );

              Navigator.pop(context);
              _loadUserInfo();
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _editNumberField(String key, String label) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label 수정'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '$label 입력'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text.trim());
              if (value == null) return;
              final token = await JwtStorage.getToken();
              if (token == null) return;

              await UserService.updateProfileField(token,
                height: key == 'height' ? value : null,
                weight: key == 'weight' ? value : null,
              );

              Navigator.pop(context);
              _loadUserInfo();
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _editGenderField(String key) {
    String? selected = userInfo?.gender ?? '남';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("성별 선택"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('남'),
              value: '남',
              groupValue: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
            RadioListTile<String>(
              title: const Text('여'),
              value: '여',
              groupValue: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final token = await JwtStorage.getToken();
              if (token == null || selected == null) return;
              await UserService.updateProfileField(token, gender: selected);
              Navigator.pop(context);
              _loadUserInfo();
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _editDateField(String key) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null) {
      final token = await JwtStorage.getToken();
      if (token == null) return;

      final formatted = "${picked.year.toString().padLeft(4, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.day.toString().padLeft(2, '0')}";

      await UserService.updateProfileField(token, birthDate: formatted);
      _loadUserInfo();
    }
  }

  void _showPlaceholderDialog(String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: const Text("기능이 아직 구현되지 않았습니다."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인"))],
      ),
    );
  }
}
