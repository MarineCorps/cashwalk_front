import 'package:flutter/material.dart';
import 'package:cashwalk/widgets/lucky_lottery.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe; // 메시지 위치용
  final int? myUserId;
  final void Function(String messageId, int reward) onRedeem;

  // ✅ 다이얼로그 실행용 콜백
  final VoidCallback? onLuckyCashTap;

  const ChatBubble({
    super.key,
    required this.msg,
    required this.isMe,
    required this.myUserId,
    required this.onRedeem,
    this.onLuckyCashTap,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = msg['type'] == 'IMAGE';
    final isLucky = msg['type'] == 'LUCKY_CASH';
    final createdAtStr = msg['createdAt'];

    return Column(
      crossAxisAlignment:
      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isMe ? Colors.yellow[100] : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isImage
                ? Image.network(msg['fileUrl'] ?? '', width: 180)
                : isLucky
                ? _buildLuckyCash(context)
                : Text(msg['content'] ?? ''),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
          child: Text(
            _formatTime(createdAtStr),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyCash(BuildContext context) {
    final isSender = msg['senderId'] == myUserId;
    final opened = msg['opened'] == true;
    final expired = msg['expired'] == true;
    final createdAt = msg['createdAt'];
    final remainingText = _formatRemainingTime(createdAt);

    if (isSender) {
      // 🎁 보낸 사용자용 메시지
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎁 행운 캐시를 보냈어요!',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (opened)
            const Text('상대가 선물을 열었어요! 🎉',
                style: TextStyle(color: Colors.green))
          else if (expired)
            const Text('상대가 열지 않아 만료됐어요.',
                style: TextStyle(color: Colors.grey))
          else
            const Text('아직 선물을 열지 않았어요.',
                style: TextStyle(color: Colors.orange)),
          const SizedBox(height: 4),
          Text('⏰ $remainingText',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      );
    } else {
      // 🎁 받은 사용자용 메시지
      if (opened) {
        return Column(
          children: [
            Image.asset('assets/images/lucky_received.png', height: 100),
            const SizedBox(height: 12),
            const Text('행운 캐시를 받으세요!',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('유효 시간이 끝나기 전에 친구의 선물을 받아보세요.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              child: const Text('받기 완료'),
            ),
          ],
        );
      } else if (expired) {
        return Column(
          children: [
            Image.asset('assets/images/lucky_expired.png', height: 100),
            const SizedBox(height: 12),
            const Text('행운 캐시를 받지 못했어요.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('오늘 다시 친구에게 캐시를 선물할 수 있어요!'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Text('만료된 선물입니다.'),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('📢 여기에 광고가 표시됩니다',
                    style: TextStyle(color: Colors.black54)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('행운 캐시를 받으세요!',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('유효 시간이 끝나기 전에 친구의 선물을 받아보세요.'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  remainingText,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (onLuckyCashTap != null) {
                  onLuckyCashTap!();
                }
              },
              child: const Text('친구의 선물 받기'),
            ),
          ],
        );
      }
    }
  }

  String _formatRemainingTime(String? createdAtStr) {
    if (createdAtStr == null) return '유효시간 계산불가';

    try {
      final createdAt = DateTime.parse(createdAtStr).toLocal();
      final now = DateTime.now();
      final passed = now.difference(createdAt);
      final remaining = Duration(hours: 24) - passed;

      if (remaining.isNegative) return '만료됨';

      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      final seconds = remaining.inSeconds % 60;

      return '${hours.toString().padLeft(2, '0')}시간 '
          '${minutes.toString().padLeft(2, '0')}분 '
          '${seconds.toString().padLeft(2, '0')}초';
    } catch (e) {
      return '유효시간 계산 오류';
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    final dt = DateTime.tryParse(isoTime)?.toLocal();
    if (dt == null) return '';
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = hour < 12 ? '오전' : '오후';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$ampm $hour12:$minute';
  }
}
