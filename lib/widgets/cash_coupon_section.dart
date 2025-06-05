import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cashwalk/services/user_service.dart';

class CashCouponSection extends StatelessWidget {
  const CashCouponSection({super.key});

  @override
  Widget build(BuildContext context) {
    final int point = UserService.currentUser?.points ?? 0;

    return Container(
      height: 120,
      color: const Color(0xFFFFD400), // ✅ 통일된 노란색 (캐시워크 메인 컬러)
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Center(
                child: Text(
                  '홈',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.lock_outline, color: Colors.black),
                  onPressed: () {
                    print('🔒 화면 잠금 클릭됨');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ 캐시 포인트
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black,
                    child: Text(
                      'C',
                      style: GoogleFonts.dancingScript(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$point',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '캐시',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // ✅ 쿠폰함 버튼
              OutlinedButton(
                onPressed: () {
                  print('🎟 내 쿠폰함 클릭됨');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('내 쿠폰함', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
