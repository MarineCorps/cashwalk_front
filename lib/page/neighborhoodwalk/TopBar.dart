import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String region;
  final VoidCallback onRegionTap;

  const TopBar({
    super.key,
    required this.region,
    required this.onRegionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 지역명 버튼
          OutlinedButton(
            onPressed: onRegionTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            child: Row(
              children: [
                Text(region, style: const TextStyle(color: Colors.black)),
                const Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
          // 아이콘 + 텍스트
          Row(
            children: [
              _iconWithText(Icons.notifications_none, '알림'),
              const SizedBox(width: 12),
              _iconWithText(Icons.bookmark_border, '스크랩'),
              const SizedBox(width: 12),
              _iconWithText(Icons.edit_note, '작성글'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconWithText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }
}