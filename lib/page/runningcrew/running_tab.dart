import 'package:flutter/material.dart';
import 'goal_setting_page.dart'; // ✅ 목표 설정 모달
import 'free_running.dart';     // ✅ 자유러닝 import 추가

class RunningTab extends StatefulWidget {
  const RunningTab({super.key});

  @override
  State<RunningTab> createState() => _RunningTabState();
}

class _RunningTabState extends State<RunningTab> {
  bool isUnlimitedMode = true; // 무제한 러닝 or 목표 러닝
  bool isDistanceMode = true;  // 거리 모드 or 시간 모드

  double distanceGoal = 0.0;   // 목표 거리
  Duration timeGoal = Duration.zero; // 목표 시간

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // 무제한 러닝 / 목표 러닝 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTopModeButton('무제한 러닝', true),
            const SizedBox(width: 8),
            _buildTopModeButton('목표 러닝', false),
          ],
        ),

        const SizedBox(height: 20),

        // 거리 / 시간 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton('거리', true),
            const SizedBox(width: 12),
            _buildModeButton('시간', false),
          ],
        ),

        const SizedBox(height: 32),

        // 메인 화면
        if (isUnlimitedMode)
          _buildUnlimitedRunning()
        else
          _buildGoalRunning(),

        const Spacer(),

        // 운동 시작 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FreeRunning(
                      isUnlimited: isUnlimitedMode,
                      isDistanceMode: isDistanceMode,
                      distanceGoal: distanceGoal,
                      timeGoal: timeGoal,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '운동 시작',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 무제한 러닝 화면
  Widget _buildUnlimitedRunning() {
    return Column(
      children: [
        Text(
          isDistanceMode ? '무제한 거리 러닝' : '무제한 시간 러닝',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '별도의 목표 없이 자유롭게 달려볼까요?\n내가 달린만큼 러닝기록이 저장돼요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        Icon(
          isDistanceMode ? Icons.directions_run : Icons.timer,
          size: 120,
          color: Colors.deepOrange,
        ),
      ],
    );
  }

  // 목표 러닝 화면
  Widget _buildGoalRunning() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoalSettingPage(
                  isDistanceMode: isDistanceMode,
                  initialDistance: distanceGoal,
                  initialDuration: timeGoal,
                ),
              ),
            );

            if (result != null) {
              if (isDistanceMode) {
                setState(() {
                  distanceGoal = result as double;
                });
              } else {
                setState(() {
                  timeGoal = result as Duration;
                });
              }
            }
          },
          child: Column(
            children: [
              Text(
                isDistanceMode
                    ? distanceGoal.toStringAsFixed(1)
                    : _formatDuration(timeGoal),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Divider(
                color: Colors.deepOrange,
                thickness: 3,
                indent: 80,
                endIndent: 80,
              ),
              Text(
                isDistanceMode ? 'km' : '시:분:초',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '숫자 영역을 터치해서 러닝 목표를\n자유롭게 설정해보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Widget _buildTopModeButton(String text, bool unlimitedMode) {
    final bool isSelected = isUnlimitedMode == unlimitedMode;
    return GestureDetector(
      onTap: () {
        setState(() {
          isUnlimitedMode = unlimitedMode;
        });
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 90, minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, bool distanceMode) {
    final bool isSelected = isDistanceMode == distanceMode;
    return GestureDetector(
      onTap: () {
        setState(() {
          isDistanceMode = distanceMode;
        });
      },
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.deepOrange, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.deepOrange : Colors.black54,
          ),
        ),
      ),
    );
  }
}
