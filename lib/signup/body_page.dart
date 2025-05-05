import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/screen/home_screen.dart';

class BodyPage extends StatefulWidget {
  final String nickname;
  final String gender;
  final String birthDate; // yyyy-MM-dd
  final String region;

  const BodyPage({
    super.key,
    required this.nickname,
    required this.gender,
    required this.birthDate,
    required this.region,
  });

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  final TextEditingController _heightController = TextEditingController(text: '165');
  final TextEditingController _weightController = TextEditingController(text: '65');

  bool get isValid =>
      _heightController.text.trim().isNotEmpty &&
          _weightController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitUserInfo() async {
    final token = await JwtStorage.getToken();
    final url = Uri.parse('http://10.0.2.2:8080/api/users/info');

    final body = jsonEncode({
      "gender": widget.gender,
      "birthDate": widget.birthDate,
      "region": widget.region,
      "height": int.tryParse(_heightController.text.trim()),
      "weight": int.tryParse(_weightController.text.trim()),
    });

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: body,
    );

    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
            (route) => false,
      );
    } else {
      print('❌ 사용자 정보 저장 실패: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보 저장에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '키, 몸무게 설정하기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.nickname}님,\n정확한 운동량 측정을 위해 키와 몸무게를 입력해주세요.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text('키', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            const Text('몸무게', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isValid ? _submitUserInfo : null,
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