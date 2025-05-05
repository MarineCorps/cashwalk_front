import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cashwalk/page/cashdeal/cashdeal.dart';
import 'package:cashwalk/page/community/community_page.dart';
import 'package:cashwalk/page/runningcrew/runningcrew.dart';
import 'package:cashwalk/page/neighborhoodwalk/neighborhoodwalk.dart';
import 'package:cashwalk/widgets/step_display_widget.dart';
import 'package:cashwalk/widgets/cash_coupon_section.dart';
import 'package:cashwalk/services/community_service.dart';
import 'package:cashwalk/page/community/post_detail_widget.dart';
class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 🔽 홈 화면 전체를 스크롤 가능하게 만듦
    return SingleChildScrollView(
      child: Column(
        children: [
          // 🟡 상단 캐시/쿠폰 표시 영역
          CashCouponSection(),
          // 🟠 걸음 수 원형 위젯 (step_display_widget.dart에서 가져옴)
          const StepDisplayWidget(), //
          // 🔵 광고 배너 (이미지 클릭 시 이벤트 처리)
          // 🔷 카테고리 버튼 그리드 (예: 팬마음, 건강케어 등)
          AdvertisementWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildCategoryButton('팬마음', Icons.favorite, () {}),
                _buildCategoryButton('건강케어', Icons.local_hospital, () {}),
                _buildCategoryButton('돈버는퀴즈', Icons.quiz, () {}),
                _buildCategoryButton('동네상책', Icons.map, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NeighborhoodWalk()));
                }),
                _buildCategoryButton('쇼핑비서', Icons.shopping_bag, () {}),
                _buildCategoryButton('언니의파우치', Icons.card_giftcard, () {}),
                _buildCategoryButton('캐시딜', Icons.attach_money, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CashDealPage()));
                }),
                _buildCategoryButton('트로스트', Icons.psychology, () {}),
                _buildCategoryButton('모두의챌린지', Icons.emoji_events, () {}),
                _buildCategoryButton('러닝크루', Icons.directions_run, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RunningCrewPage()));}),
                _buildCategoryButton('캐시닥', Icons.health_and_safety, () {}),
                _buildCategoryButton('팀워크', Icons.groups, () {}),
                _buildCategoryButton('뽑기', Icons.casino, () {}),
                _buildCategoryButton('돈버는미션', Icons.task, () {}),
                _buildCategoryButton('캐시리뷰', Icons.rate_review, () {}),
                _buildCategoryButton('과민보스', Icons.emoji_emotions, () {}),
                _buildCategoryButton('커뮤니티', Icons.forum, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityPage()));
                }),
                _buildCategoryButton('캐시웨어', Icons.inventory, () {}),
              ],
            ),
          ),
          // 🟣 친구 초대 배너 이미지
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GestureDetector(
              onTap: () {
                print("친구 초대 배너 클릭됨!");
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/chode.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // 🟤 교환권/퀴즈/상품/게시글 영역들
          _buildCouponSection(),
          _buildQuizSection(),
          CashDealSection(),
          _buildBestPostsSection(),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuizSection() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('돈버는퀴즈', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('더보기 >', style: TextStyle(color: Colors.black)),
            ],
          ),
          const SizedBox(height: 10),
          _buildCountdownTimer(),
          const Divider(),
          _buildQuiz(detail: '', participants: '', cash: ''),
          _buildQuiz(detail: '', participants: '', cash: ''),
          _buildQuiz(detail: '', participants: '', cash: ''),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('다음 퀴즈까지 남은 시간 🕓 ', style: TextStyle(color: Colors.white)),
          Text('0 : 0 : 0', style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuiz({required String detail, required String participants, required String cash}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
        child: const Text('진행중', style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
      title: Text(detail, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          const Icon(Icons.people, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(participants, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 10),
          const Icon(Icons.monetization_on, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text(cash, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('모바일 교환권', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('전체보기 >', style: TextStyle(color: Colors.black)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCoupon('5,000캐시'),
              _buildCoupon('10,000캐시'),
              _buildCoupon('20,000캐시'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoupon(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildBestPostsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: CommunityService.fetchTopPopularPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bestPosts = snapshot.data!;

        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('BEST 인기글(실시간)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CommunityPage(initialPostCategory: 'BESTLIVE'),
                        ),
                      );
                    },
                    child: const Text('더보기 >', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              Text('우리 같이 소통해요', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 10),
              ...bestPosts.asMap().entries.map((entry) {
                final i = entry.key;
                final post = entry.value;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunityPage(
                          initialPostId: post['id'],
                          initialBoardType: post['boardType'],
                          initialPostCategory: post['postCategory'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      children: [
                        Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            post['title'],
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '[${post['commentCount']}]',
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }



  Widget _buildBestPostItem(Map<String, dynamic> post) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text(post['rank'], style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              post['title'],
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '[${post['comment']}]',
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class DayStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.yellow[700]),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'http://thumbnail.10x10.co.kr/webimage/image/basic600/235/B002351252.jpg?cmd=thumb&w=500&h=500&fit=true&ws=false',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const Column(
            children: [
              Text('하루 만보 걷기', style: TextStyle(fontSize: 18, color: Colors.white)),
              Text('0 걸음', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('0 kcal   0 분   0 m', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class AdvertisementWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GestureDetector(
        onTap: () {
          print("광고 배너 클릭됨!");
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://picsum.photos/250/80',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class CashDealSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('캐시딜 인기상품', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: PageView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => _buildCashDealPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashDealPage() {
    return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildCashDealItem(),
    );
  }

  Widget _buildCashDealItem() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            'https://cdn.pixabay.com/photo/2022/11/27/18/01/flower-7620426_640.jpg',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: const Text('[만원의행복] 경북 햇 부사 사과'),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('0% 0원', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            Text('P 0 적립 | 무료배송', style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Icon(Icons.star, color: Colors.yellow[700]),
      ),
    );
  }
}