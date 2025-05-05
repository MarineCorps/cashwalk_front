import 'package:flutter/material.dart';
import 'package:cashwalk/services/step_api_service.dart';

/// 💎 보물상자 위젯
/// - 수령 가능한 포인트 수를 상단 뱃지로 표시
/// - 하루 최대 100포인트까지 수령 가능
/// - 클릭 시 서버에 포인트 1 적립 + UI 반영
/// - 일정 횟수마다 광고 등장 가능성 포함
class TreasureBoxWidget extends StatefulWidget {
  const TreasureBoxWidget({super.key});

  @override
  State<TreasureBoxWidget> createState() => _TreasureBoxWidgetState();
}

class _TreasureBoxWidgetState extends State<TreasureBoxWidget> {
  int totalSteps = 0;      // 총 걸음 수
  int receivedPoints = 0;  // 이미 받은 포인트
  int unclaimedPoints = 0; // 아직 수령 안 한 포인트
  int claimCount = 0;      // 보물상자 클릭 횟수 (광고 등장용)

  @override
  void initState() {
    super.initState();
    _loadStepData();
  }

  /// 📡 오늘의 걸음 수 및 포인트를 서버에서 불러옴
  Future<void> _loadStepData() async {
    final data = await StepApiService.fetchTodaySteps();
    if (data != null) {
      int steps = data['stepCount'] ?? 0;
      int points = data['points'] ?? 0;

      setState(() {
        totalSteps = steps;
        receivedPoints = points;
        unclaimedPoints = (steps ~/ 100) - points; // 수령 가능 포인트 계산
      });
    }
  }

  /// 📦 보물상자 클릭 시 호출
  Future<void> _claimPoint() async {
    if (unclaimedPoints <= 0) {
      if (totalSteps >= 10000 && receivedPoints >= 100) {
        // ✅ 이미 오늘 최대 적립 완료 시 안내
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("보물상자로 적립할 수 있는 포인트는 하루에 100입니다."),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // ✅ 서버에 포인트 1 적립 요청
    final success = await StepApiService.claimPoint();

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("이미 최대 적립을 완료했어요."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // ✅ 성공 시 로컬 UI 갱신
    setState(() {
      unclaimedPoints--;
      receivedPoints++;
      claimCount++;
    });

    print('🪙 1포인트 수령 완료 (총 수령 $claimCount 회)');

    // 📺 광고 등장 조건 (5회마다)
    if (claimCount % 5 == 0) {
      print('📺 광고 등장!');
      // TODO: 광고 모듈 연동 시 여기에 삽입
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _claimPoint,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Image.asset(
                'assets/images/treasure_box.png',
                width: 100,
                height: 100,
              ),
              if (unclaimedPoints > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$unclaimedPoints',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                )
            ],
          ),
        ),
        const SizedBox(height: 4),
        // ✅ 하단 메시지: 오늘 적립 최대 도달 시 안내
        if (totalSteps >= 10000 && receivedPoints >= 100)
          const Text(
            "보물상자로 적립할 수 있는 포인트는 하루에 100입니다.",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }
}
