import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import 'package:lottie/lottie.dart';
import 'package:cashwalk/services/chat_api_service.dart';

class LuckyLotteryDialog extends StatefulWidget {
  final String messageId;
  final void Function(int reward) onCompleted;

  const LuckyLotteryDialog({
    super.key,
    required this.messageId,
    required this.onCompleted,
  });

  @override
  State<LuckyLotteryDialog> createState() => _LuckyLotteryDialogState();
}

class _LuckyLotteryDialogState extends State<LuckyLotteryDialog> {
  bool _isScratched = false;
  bool _showReward = false;
  int? _reward;

  Future<void> _redeemLuckyCash() async {
    try {
      print('📤 [LuckyCash Redeem 요청 전송] messageId: ${widget.messageId}');

      final reward = await ChatApiService.redeemLuckyCash(widget.messageId);

      print('✅ [LuckyCash Redeem 성공] 받은 reward: $reward');

      if (!mounted) return;

      setState(() {
        _reward = reward;
        _showReward = true;
      });

      widget.onCompleted(reward);
    } catch (e, stacktrace) {
      print('❌ [LuckyCash Redeem 실패]');
      print('⛔ 오류 내용: $e');
      print('📍 스택트레이스: $stacktrace');
      if (mounted) {
        setState(() {
          _isScratched = false;
          _showReward = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 복권 적립 실패: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎁 행운복권 긁기',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Scratcher(
              brushSize: 40,
              threshold: 97,
              color: Colors.grey,
              onChange: (_) {},
              onThreshold: () async {
                if (_isScratched || widget.messageId.isEmpty) return;

                setState(() {
                  _isScratched = true;
                  _showReward = true;
                });

                await _redeemLuckyCash();
              },
              child: Container(
                width: 300,
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: _reward != null
                      ? Text(
                    '🎉 $_reward 캐시 당첨!',
                    key: ValueKey(_reward),
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  )
                      : const Text(
                    '긁어서 확인하세요!',
                    key: ValueKey('scratch'),
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_showReward) ...[
              SizedBox(
                height: 120,
                child: Lottie.asset(
                  'assets/animations/firework.json',
                  repeat: false,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
