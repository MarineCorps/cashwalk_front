import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashwalk/models/invite_stats.dart';
import 'package:cashwalk/services/invite_service.dart';
import 'package:cashwalk/utils/font_service.dart'; // ✅ HttpService 활용

class InviteFriendsPage extends StatefulWidget {
  const InviteFriendsPage({super.key});

  @override
  State<InviteFriendsPage> createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {
  InviteStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await InviteService.getInviteStats();
      setState(() => _stats = stats); // 정상적으로 데이터 처리
    } catch (e) {
      debugPrint('통계 조회 실패: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _copyCode() {
    if (_stats == null) return;
    Clipboard.setData(ClipboardData(text: _stats!.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('추천 코드가 복사되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 초대'),
        backgroundColor: Colors.yellow[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
          ? const Center(child: Text('데이터를 불러오지 못했습니다.'))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('나의 추천 코드',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(_stats!.inviteCode, style: const TextStyle(fontSize: 24)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyCode,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, // 기능은 아직 없음
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('친구초대하기'),
            ),
            const SizedBox(height: 30),
            Text('초대한 친구: ${_stats!.invitedCount}명'),
            Text('나를 초대한 친구: ${_stats!.invitedMeCount}명'),
            Text('받은 총 캐시: ${_stats!.totalCash} 캐시'),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              '친구 초대를 통해 캐시를 더 받을 수 있어요!\n지금 초대하고 최대 보상을 챙기세요.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
