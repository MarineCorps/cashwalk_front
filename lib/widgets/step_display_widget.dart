import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cashwalk/services/step_service.dart';
import 'package:cashwalk/services/step_api_service.dart';
import 'package:cashwalk/services/user_service.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:cashwalk/page/stats/step_stats_page.dart';
import 'package:cashwalk/page/cashtalk/cash_talk_friend.dart';


//그 외에 애니메이션이나 숫자 카운팅 효과도 추가해야됨
class StepDisplayWidget extends StatefulWidget {
  const StepDisplayWidget({super.key});


  @override
  State<StepDisplayWidget> createState() => _StepDisplayWidgetState();
}

class _StepDisplayWidgetState extends State<StepDisplayWidget> {
  final StepService _stepService = StepService();
  int _currentSteps = 0;

  static const int stepGoal = 10000;

  String? profileImageUrl;

  @override
  void initState() {
    super.initState();

    _stepService.init();

    // ✅ 프로필 이미지 불러오기
    _loadProfileImage();

    // 1️⃣ 센서 스트림 수신
    _stepService.stepStream.listen((steps) {
      setState(() {
        _currentSteps = steps;
      });
    }, onError: (e) async {
      print('🚨 센서 실패. 서버 데이터로 대체');

      // 2️⃣ 센서 실패 시 서버에서 fallback
      final todayData = await StepApiService.fetchTodaySteps();
      if (todayData != null && mounted) {
        setState(() {
          _currentSteps = (todayData['steps'] ?? 0) as int;
        });
      }
    });
  }
  // ✅ 카카오 프로필 불러오는 함수
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentSteps / stepGoal).clamp(0.0, 1.0);
    double calories = _currentSteps * 0.033;
    double distanceKm = _currentSteps * 0.0008;
    double durationMin = _currentSteps / 100;

    final formattedSteps = NumberFormat.decimalPattern().format(_currentSteps);

    return SizedBox(
      height: 360,
      width: double.infinity,
      child: Stack(
        children: [
          // 🖼 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/woobin.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🧩 UI 내용: 상단 아이콘 + 원형 그래프
          Column(
            children: [
              // 🔶 상단 아이콘 Row
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.bar_chart, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => StepStatsPage()));;
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.medication, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.image, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
              // 🎯 원형 그래프 및 텍스트
              child:Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: CustomPaint(
                    painter: _CirclePainter(progress),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '하루만보걷기',
                          style: TextStyle(fontSize: 14, color: Colors.white,
                          ),
                        ),
                        Text(
                          formattedSteps,
                          style: GoogleFonts.dangrek(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white,
                          ),
                        ),
                        const Text(
                          '걸음',
                          style: TextStyle(fontSize: 14, color: Colors.white,),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${calories.toStringAsFixed(0)} kcal | ${durationMin.toStringAsFixed(0)}분 | ${distanceKm.toStringAsFixed(2)}km',
                          style: const TextStyle(fontSize: 13, color: Colors.white70,),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft, // ✅ 왼쪽 정렬
                child: Padding(
                  padding: const EdgeInsets.only(left: 20), // ✅ 살짝 여백 주기 (선택사항)
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CashTalkHome()),
                      );
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
    );
  }
}

// 🎯 원형 프로그레스 바 그리기
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

    double sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, sweepAngle, false, arc,);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}