import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ 필기체 폰트 사용을 위해 추가

class CashCouponSection extends StatefulWidget {
  const CashCouponSection({super.key});

  @override
  State<CashCouponSection> createState() => _CashCouponSectionState();
}

class _CashCouponSectionState extends State<CashCouponSection> {
  int _point = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoint(); // ⬅️ 사용자 포인트 불러오기
  }

  /// ✅ 서버에서 사용자 포인트를 가져오는 함수
  Future<void> _loadUserPoint() async {
    try {
      final token = await JwtStorage.getToken(); // 저장된 JWT 토큰 가져오기
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _point = data['point']; // 포인트 값을 상태에 저장
        });
      } else {
        print('포인트 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  /// ✅ UI 구현부
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Colors.yellow[700],
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔝 첫 번째 줄: 홈 + 화면잠금 버튼
          Stack(
            alignment: Alignment.center,
            children: [
              // 가운데 정렬된 "홈"
              const Center(
                child: Text(
                  '홈',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              // 오른쪽 정렬된 잠금 아이콘
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.lock, color: Colors.black87),
                  onPressed: () {
                    print('화면 잠금 버튼 클릭됨');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 💰 두 번째 줄: 원 안의 필기체 C + 포인트 텍스트, 내 쿠폰함 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // ✅ 필기체 C 아이콘
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black87,
                    child: Text(
                      'C',
                      style: GoogleFonts.dancingScript( // ✅ 필기체 적용
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_point',
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
                  )
                ],
              ),

              // 🧾 내 쿠폰함 버튼
              OutlinedButton(
                onPressed: () {
                  print('내 쿠폰함 클릭됨');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.black87),
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
