import 'package:flutter/material.dart';
import 'information_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _controller = TextEditingController(text: 'cashwalker');
  String nickname = 'cashwalker';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isValid => nickname.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final nicknameTrimmed = nickname.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '프로필 등록하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '안녕하세요 $nicknameTrimmed님,\n프로필 사진과 이름을 입력해주세요.',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.camera_alt, size: 36, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            Stack(
              children: [
                TextField(
                  controller: _controller,
                  onChanged: (value) {
                    setState(() => nickname = value);
                  },
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    counterText: '',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Text(
                    '${nickname.length}/20',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '이름은 20자까지 사용 가능합니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InformationPage(nickname: nickname.trim()),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
