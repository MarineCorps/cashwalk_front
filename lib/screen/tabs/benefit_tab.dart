import 'package:flutter/material.dart';

class BenefitTab extends StatelessWidget {
  const BenefitTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        toolbarHeight: 40,
        title: const Text('혜택', style: TextStyle(color: Colors.black,)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.yellow[700],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.attach_money, size: 20),
                    SizedBox(width: 4),
                    Text('0 캐시', style: TextStyle(fontSize: 16)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('내 쿠폰함', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      '출석체크 보상',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '최대 10,000캐시 당첨!',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _rewardBox('1천보 출첵', active: true),
                    _rewardBox('2천보 달성'),
                    _rewardBox('3천보 달성'),
                  ],
                ),
              ],
            ),
          ),

          const Divider(thickness: 6, color: Color(0xFFF2F2F2)),

          _sectionTitle('신규 고객에게만 드려요!'),
          _simpleTile(
              icon: Icons.celebration,
              title: '가입 축하금 받기',
              subtitle: '님, 100캐시 받으세요!'
          ),

          _sectionTitle('바로 받아요!'),
          _iconTile(Icons.qr_code, '행운캐시 룰렛', '최대 1만 캐시 받기'),
          _iconTile(Icons.favorite, '건강 기록하고', '최대 1만 캐시 받기', badge: '신규'),
          _iconTile(Icons.directions_walk, '동네산책', '매일 50캐시 획득'),

          _sectionTitle('놓치기 아까워요'),
          _iconTile(Icons.pets, '모두의 챌린지 참여하고', '횟수 제한없이 1만 캐시 전환하기'),
          _iconTile(Icons.menu_book, '체험단 신청하고', '써보고 싶은 제품 무료로 받기'),
          _iconTile(Icons.card_giftcard, '돈버는 미션 참여하고', '최대 200만 캐시 받기'),
          _iconTile(Icons.reviews, '화장품 리뷰하고', '500캐시 무한대 받기'),

          _sectionTitle('이런 것도 있어요'),
          _iconTile(Icons.group, '친구초대', '최대 15만 캐시 받기', badge: '인기|이벤트'),
          _iconTile(Icons.quiz, '돈버는 퀴즈 맞추고', '최대 1만 캐시 당첨되기'),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _rewardBox(String label, {bool active = false, String? number}) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFEB00) : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
        border: active ? Border.all(color: const Color(0xFFE8B500), width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (active)
            const Icon(Icons.card_giftcard, size: 36, color: Colors.brown) // 또는 chest 아이콘
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Center(
                child: Text(
                  number ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }



  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  Widget _simpleTile({required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _iconTile(IconData icon, String title, String subtitle, {String? badge}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Row(
        children: [
          Text(subtitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
          if (badge != null) ...[
            const SizedBox(width: 6),
            for (var tag in badge.split('|'))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: tag == '신규' ? Colors.blue[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(tag, style: const TextStyle(fontSize: 10, color: Colors.black)),
              ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}