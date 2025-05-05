import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cashwalk/services/step_api_service.dart';
import 'package:cashwalk/widgets/treasure_box_widget.dart';
/// ✅ 잠금화면에 표시되는 걸음 수 및 시간/날짜 위젯 (백엔드 연동 포함)
class LockScreenStepWidget extends StatefulWidget {
  const LockScreenStepWidget({super.key});

  @override
  State<LockScreenStepWidget> createState() => _LockScreenStepWidgetState();
}

class _LockScreenStepWidgetState extends State<LockScreenStepWidget> {
  int steps = 0;
  double calories = 0;
  double distanceKm = 0;

  @override
  void initState() {
    super.initState();
    _fetchStepsData();
  }

  /// 🛰 서버에서 오늘 걸음 수 가져오기
  Future<void> _fetchStepsData() async {
    final data = await StepApiService.fetchTodaySteps();
    if (data != null) {
      final int stepCount = data['stepCount'] ?? 0;
      setState(() {
        steps = stepCount;
        calories = stepCount * 0.033;
        distanceKm = stepCount * 0.0008;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('M월 d일 (E)', 'ko').format(now);
    final timeStr = DateFormat('HH:mm').format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 📅 날짜 & 시간
          Text(
            timeStr,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          Text(
            dateStr,
            style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 잠금 해제 후 동네산책 페이지로 이동
              print("동네산책으로 이동");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("동네 산책", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 24),

          // 👣 걸음 수 원형 그래프
          CircularPercentIndicator(
            radius: 120,
            lineWidth: 12.0,
            percent: (steps.clamp(0, 10000)) / 10000,
            animation: true,
            backgroundColor: Colors.grey.shade700,
            progressColor: Colors.yellowAccent,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("하루 만보 걷기", style: TextStyle(fontSize: 14, color: Colors.white)),
                Text(
                  "$steps",
                  style: const TextStyle(fontSize: 42, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Text("걸음", style: TextStyle(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  "${calories.toStringAsFixed(0)} kcal | ${distanceKm.toStringAsFixed(1)} km",
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                )
              ],
            ),
          ),

          // CircularPercentIndicator 아래에 추가
          const SizedBox(height: 24),
          const TreasureBoxWidget(),

          const SizedBox(height: 24),

          // 🔘 오른쪽 상단 아이콘 가이드 (위치 전용)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.search, color: Colors.white70),
              const SizedBox(width: 8),
              Icon(Icons.shopping_cart, color: Colors.white70),
              const SizedBox(width: 8),
              Icon(Icons.settings, color: Colors.white70),
            ],
          )
        ],
      ),
    );
  }
}