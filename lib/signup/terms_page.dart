import 'package:flutter/material.dart';
import 'profile_page.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool agreeAll = false;
  bool agree1 = false;
  bool agree2 = false;
  bool agree3 = false;
  bool agree4 = false;
  bool agree5 = false;

  void updateAgreeAll(bool? value) {
    setState(() {
      agreeAll = value ?? false;
      agree1 = agreeAll;
      agree2 = agreeAll;
      agree3 = agreeAll;
      agree4 = agreeAll;
      agree5 = agreeAll;
    });
  }

  bool get isConfirmEnabled => agree1 && agree2 && agree5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이용약관동의'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '선택 항목에 동의하지 않은 경우도 회원가입 및\n일반적인 서비스를 이용할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CheckboxListTile(
              value: agreeAll,
              onChanged: updateAgreeAll,
              title: const Text('전체 동의합니다.'),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildCheckItem('이용약관 동의 (필수)', agree1, (v) => setState(() => agree1 = v)),
                _buildCheckItem('개인정보 수집 · 이용 동의 (필수)', agree2, (v) => setState(() => agree2 = v)),
                _buildCheckItem('개인정보 수집 · 이용 동의 (선택)', agree3, (v) => setState(() => agree3 = v)),
                _buildCheckItem('광고성 목적의 개인정보 수집 · 이용 동의 (선택)', agree4, (v) => setState(() => agree4 = v)),
                _buildCheckItem('본인은 만 14세 이상입니다. (필수)', agree5, (v) => setState(() => agree5 = v)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: isConfirmEnabled
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
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
    );
  }

  Widget _buildCheckItem(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(label),
      ),
    );
  }
}
