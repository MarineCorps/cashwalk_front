import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login_screen.dart';

class TutorialStep {
  final String message;
  final int? stepCount;
  final bool showChest;

  TutorialStep({
    required this.message,
    this.stepCount,
    this.showChest = false,
  });
}

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> with TickerProviderStateMixin {
  int _stepCount = 0;
  bool _showChest = false;
  bool _isLast = false;
  bool _stepAnimating = false;
  bool _showCoinAnimation = false;
  int _currentIndex = 0;

  late final AnimationController _coinController;

  final List<TutorialStep> steps = [
    TutorialStep(message: '안녕하세요! 저는 캐시워커님의 걷기코치입니다.', stepCount: 0),
    TutorialStep(message: '캐시워크는 걸을수록 돈이 쌓이는 돈버는 만보기예요. 지금부터 사용방법을 알려드릴게요.', stepCount: 0),
    TutorialStep(message: '여러분이 걸을때마다 걸음수가 올라가고\n100걸음마다 보물상자를 얻을 수 있어요.', stepCount: 10),
    TutorialStep(message: '짠! 방금 보물상자를 얻었네요. 이제 보물상자를 한번 눌러볼까요?', stepCount: 10, showChest: true),
    TutorialStep(message: '캐시가 적립되었습니다! 이렇게 모은 캐시는 다양한 제휴점에서 현금처럼 사용할 수 있어요.', stepCount: 10),
    TutorialStep(message: '하루 최대 100캐시(10,000걸음)까지 적립할 수 있으니, 잊지말고 매일매일 적립하세요!', stepCount: 10),
    TutorialStep(message: '자! 그럼 이제부터 저와 함께\n돈버는 걷기 생활을 시작해 볼까요?', stepCount: 10),
    TutorialStep(message: '캐시워커님 화이팅!', stepCount: 10),
  ];

  @override
  void initState() {
    super.initState();
    _coinController = AnimationController(vsync: this);
    if (steps[_currentIndex].stepCount == 10) {
      _startStepAnimation();
    }
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }

  void _nextMessage() {
    if (_isLast) return;
    if (_currentIndex < steps.length - 1) {
      setState(() {
        _currentIndex++;
        _stepCount = steps[_currentIndex].stepCount ?? _stepCount;
        _showChest = steps[_currentIndex].showChest;
        _isLast = _currentIndex == steps.length - 1;
      });
    }
  }

  void _startStepAnimation() {
    if (_stepAnimating) return;
    setState(() {
      _stepAnimating = true;
      _stepCount = 0;
    });
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (_stepCount >= 10) {
        timer.cancel();
        setState(() {
          _stepAnimating = false;
          _showChest = true;
          _currentIndex++;
          _stepCount = steps[_currentIndex].stepCount ?? _stepCount;
          _showChest = steps[_currentIndex].showChest;
          _isLast = _currentIndex == steps.length - 1;
        });
      } else {
        setState(() {
          _stepCount++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = steps[_currentIndex];
    if (_currentIndex == 2 && !_stepAnimating) _startStepAnimation();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🎉 코인 애니메이션 (보물상자 클릭 시)
            if (_showCoinAnimation)
              Positioned(
                top: 180,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/animations/coin_reward.json',
                    controller: _coinController,
                    onLoaded: (composition) {
                      _coinController.duration = composition.duration;
                      _coinController.forward(from: 0).whenComplete(() {
                        setState(() {
                          _showCoinAnimation = false;
                        });
                        _nextMessage();
                      });
                    },
                  ),
                ),
              ),

            Positioned(
              top: 100,
              child: Column(
                children: [
                  const Text('하루 만보 걷기', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '${currentStep.stepCount != null ? _stepCount : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                  const Text('걸음', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),

                  // 🚶 걷는 애니메이션
                  if (_currentIndex == 2 && _stepAnimating)
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Lottie.asset(
                        'assets/animations/walking.json',
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),

                  // 🎁 보물상자 아이콘
                  if (_showChest)
                    GestureDetector(
                      onTap: () {
                        if (_currentIndex == 3) {
                          setState(() {
                            _showCoinAnimation = true;
                          });
                        }
                      },
                      child: const Icon(Icons.card_giftcard, color: Colors.amber, size: 60),
                    ),
                ],
              ),
            ),

            if (_currentIndex == 4)
              Positioned(
                top: 300,
                child: Image.asset(
                  'assets/images/brand.png',
                  height: 200,
                ),
              ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  if (_currentIndex == 0)
                    const Column(
                      children: [
                        Text(
                          '메시지를 누르면 다음으로 넘어갑니다',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Icon(Icons.arrow_downward, color: Colors.yellow, size: 32),
                      ],
                    ),
                  GestureDetector(
                    onTap: () {
                      if (_currentIndex == 3 || _stepAnimating) return;
                      if (_isLast) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      } else {
                        _nextMessage();
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage('assets/images/woobin.png'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.yellow[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              currentStep.message,
                              style: const TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
