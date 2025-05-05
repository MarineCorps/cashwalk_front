import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final TextEditingController _nicknameController = TextEditingController(text: '');

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  int getByteLength(String value) {
    return value.runes.fold(0, (prev, rune) => prev + (rune <= 0x7F ? 1 : 2));
  }

  @override
  Widget build(BuildContext context) {
    final byteLength = getByteLength(_nicknameController.text);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEB00),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('커뮤니티', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {

              Navigator.pop(context);
            },
            child: const Text('저장', style: TextStyle(color: Colors.black)),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),


          Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.settings, size: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_nicknameController.text, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 20),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('닉네임 *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nicknameController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    hintText: '닉네임을 입력하세요',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('최대 한글 10자, 영문 20자, 숫자 혼용 가능',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('$byteLength/20byte',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
