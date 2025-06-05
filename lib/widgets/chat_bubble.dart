import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final int? myUserId;
  final void Function(String messageId, int reward) onRedeem;
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

    // ✅ createdAt 기반 로컬 만료 보정
    final createdAtStr = msg['createdAt'];
    final createdAt = DateTime.tryParse(createdAtStr ?? '')?.toLocal();
    final isActuallyExpired = createdAt == null
        ? false
        : DateTime.now().difference(createdAt).inHours >= 24;

    final expired = msg['expired'] == true || isActuallyExpired;
    final opened = msg['opened'] == true;

    if (isSender) {
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
        ],
      );
    } else {
      if (opened) {
        return Column(
          children: [
            Image.asset('assets/images/lucky_received.png',
              height: 200,
              width: double.infinity, // 👉 가로 꽉 차게
              fit: BoxFit.cover,
            ),
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
            Image.asset('assets/images/lucky_expired.png',
              height: 200,
              width: double.infinity, // 👉 가로 꽉 차게
              fit: BoxFit.cover,),
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
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: (!expired && !opened)
                  ? () {
                if (onLuckyCashTap != null) {
                  onLuckyCashTap!();
                }
              }
                  : null,
              child: Text(
                expired
                    ? '⏰ 만료됨'
                    : opened
                    ? '받기 완료'
                    : '친구의 선물 받기',
              ),
            ),
          ],
        );
      }
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
