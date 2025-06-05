import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cashwalk/services/step_service.dart';
import 'package:cashwalk/services/step_api_service.dart';
import 'package:cashwalk/services/user_service.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:cashwalk/page/stats/step_stats_page.dart';
import 'package:cashwalk/page/cashtalk/cash_talk_friend.dart';

class StepDisplayWidget extends StatefulWidget {
  const StepDisplayWidget({super.key});

  @override
  State<StepDisplayWidget> createState() => _StepDisplayWidgetState();
}

class _StepDisplayWidgetState extends State<StepDisplayWidget> with SingleTickerProviderStateMixin {
  final StepService _stepService = StepService();
  int _currentSteps = 0;
  int _claimedCount = 0;
  String? profileImageUrl;

  late final AnimationController _rewardController;
  bool _showRewardAnim = false;

  static const int stepGoal = 10000;

  @override
  void initState() {
    super.initState();
    _stepService.init();
    _loadProfileImage();

    _rewardController =
        AnimationController(vsync: this,
          duration: const Duration(seconds: 1),
        );

    _stepService.stepStream.listen((steps) {
      setState(() {
        _currentSteps = steps;
      });
    }, onError: (e) async {
      print('🚨 센서 실패. 서버 데이터로 대체');
      final todayData = await StepApiService.fetchTodaySteps();
      if (todayData != null && mounted) {
        setState(() {
          _currentSteps = (todayData['steps'] ?? 0) as int;
          _claimedCount = (todayData['claimed'] ?? 0) as int;
        });
      }
    });

    StepApiService.fetchTodaySteps().then((todayData) {
      if (todayData != null && mounted) {
        setState(() {
          _currentSteps = (todayData['steps'] ?? 0) as int;
          _claimedCount = (todayData['claimed'] ?? 0) as int;
        });
      }
    });

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
  void dispose() {
    _stepService.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentSteps / stepGoal).clamp(0.0, 1.0);
    final calories = _currentSteps * 0.033;
    final distanceKm = _currentSteps * 0.0008;
    final durationMin = _currentSteps / 100;
    final formattedSteps = NumberFormat.decimalPattern().format(_currentSteps);

    final totalBoxes = _currentSteps ~/ 100;
    final availableBoxes = totalBoxes - _claimedCount;

    return Stack(
      children: [
        SizedBox(
          height: 420,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.bar_chart, color: Colors.greenAccent, size: 33),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => StepStatsPage()));
                          },
                        ),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.medication, color: Colors.white), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.image, color: Colors.white), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white), onPressed: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ✅ 원형 그래프: 위쪽 여백 확보
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0), // 🔼 상단 여백 추가
                            child: SizedBox(
                              width: 240,
                              height: 240,
                              child: CustomPaint(
                                painter: _CirclePainter(progress),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('하루만보걷기', style: TextStyle(fontSize: 14, color: Colors.white)),
                                    Text(formattedSteps, style: const TextStyle(fontSize: 36, color: Colors.white)),
                                    const Text('걸음', style: TextStyle(fontSize: 14, color: Colors.white)),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${calories.toStringAsFixed(0)} kcal | ${durationMin.toStringAsFixed(0)}분 | ${distanceKm.toStringAsFixed(2)}km',
                                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ✅ 보물상자: 아래 정렬, 약간 위로 띄움
                        if (availableBoxes > 0)
                          Positioned(
                            bottom: -5, // ⬆ 아래 여백 확보
                            child: GestureDetector(
                              onTap: () async {
                                final success = await StepApiService.claimPoint();
                                if (success && mounted) {
                                  setState(() {
                                    _claimedCount += 1;
                                    _showRewardAnim = true;
                                  });
                                  _rewardController.reset();
                                  _rewardController.forward();
                                  await Future.delayed(const Duration(seconds: 2));
                                  if (mounted) setState(() => _showRewardAnim = false);
                                }
                              },
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.asset(
                                    'assets/images/treasurebox.png',
                                    width: 120,
                                    height: 90,
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$availableBoxes',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 5),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CashTalkHome()));
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? NetworkImage(profileImageUrl!)
                              : const AssetImage('assets/images/woobin.png') as ImageProvider,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (_showRewardAnim)
          Center(
            child: Lottie.asset(
              'assets/animations/coin_reward.json',
              controller: _rewardController,
              onLoaded: (comp) {
                _rewardController.duration = comp.duration;
                _rewardController.forward();
              },
              width: 150,
              height: 150,
              repeat: false,
            ),
          ),
      ],
    );
  }

}

class _CirclePainter extends CustomPainter {
  final double progress;
  _CirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint base = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final Paint arc = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, base);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
