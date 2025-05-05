import 'package:flutter/material.dart';
import 'package:cashwalk/main.dart'; // HomePage 위치에 맞게 경로 조정 필요
import 'package:cashwalk/screen/home_screen.dart';
// CASHDEAL 메인 페이지
class CashDealPage extends StatelessWidget {
  const CashDealPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭 개수
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            'CASHDEAL',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('제휴문의', style: TextStyle(color: Colors.black)),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(96),
            child: Column(
              children: [
                // 검색창
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // 탭바
                const TabBar(
                  labelColor: Colors.red,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.red,
                  tabs: [
                    Tab(text: '쇼핑'),
                    Tab(text: '캐시리뷰'),
                    Tab(text: '돈버는퀴즈'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _ShoppingTab(), // 쇼핑 탭
            _CashReviewTab(), // 캐시리뷰 탭
            _QuizTab(), // 퀴즈 탭
          ],
        ),
      ),
    );
  }
}

// ------------------ 쇼핑 탭 ------------------
class _ShoppingTab extends StatelessWidget {
  const _ShoppingTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildTimerBanner(), // 타이머 배너
        _buildCategoryIcons(context), // 카테고리 버튼들
        _buildDealSection(), // 오늘의 캐시딜 섹션
      ],
    );
  }

  // 상단 타이머 + 배너 이미지
  Widget _buildTimerBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.green[200],
      child: Column(
        children: [
          Row(
            children: [
              // 타이머 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text("00 : 00", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text('스크롤 해야 시간이 줄어요'),
            ],
          ),
          const SizedBox(height: 10),
          // 배너 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://via.placeholder.com/350x100.png?text=농식품부+할인지원',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리 아이콘 버튼들
  Widget _buildCategoryIcons(BuildContext context) {
    final buttons = [
      _buildCategoryButton('신상품', Icons.fiber_new, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
      }),
      _buildCategoryButton('이주의 특가', Icons.local_offer, () {}),
      _buildCategoryButton('농할지원', Icons.agriculture, () {}),
      _buildCategoryButton('산지직송', Icons.local_shipping, () {}),
      _buildCategoryButton('삼천원딜', Icons.monetization_on, () {}),
      _buildCategoryButton('유통임박', Icons.hourglass_bottom, () {}),
      _buildCategoryButton('판매랭킹', Icons.emoji_events, () {}),
      _buildCategoryButton('적립10%', Icons.percent, () {}),
      _buildCategoryButton('제로딜', Icons.recycling, () {}),
      _buildCategoryButton('품질보장', Icons.verified, () {}),
      _buildCategoryButton('만점상품', Icons.star, () {}),
      _buildCategoryButton('뷰티', Icons.brush, () {}),
      _buildCategoryButton('간편식', Icons.fastfood, () {}),
      _buildCategoryButton('건강식품', Icons.local_pharmacy, () {}),
      _buildCategoryButton('생필품', Icons.shopping_cart, () {}),
      _buildCategoryButton('가전·디지털', Icons.devices, () {}),
      _buildCategoryButton('패션·잡화', Icons.checkroom, () {}),
      _buildCategoryButton('반려동물', Icons.pets, () {}),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 20,
        children: buttons,
      ),
    );
  }

  // 단일 카테고리 버튼
  Widget _buildCategoryButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // 오늘의 캐시딜 상품 리스트
  Widget _buildDealSection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('오늘의 캐시딜',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildProductCard();
            },
          ),
        ],
      ),
    );
  }

  // 상품 카드 UI
  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://via.placeholder.com/150',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          const Text('[산지직송] 해남 수미감자 2kg',
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          const Text('0% 원',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          const Text('무료배송 · 0명 구매중', style: TextStyle(fontSize: 12)),
          Row(
            children: const [
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text('0', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------ 캐시리뷰 탭 ------------------
class _CashReviewTab extends StatefulWidget {
  const _CashReviewTab();

  @override
  State<_CashReviewTab> createState() => _CashReviewTabState();
}

class _CashReviewTabState extends State<_CashReviewTab> {
  bool isAllSelected = true;
  bool notifySwitch = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 배너 이미지
        Image.network('https://via.placeholder.com/400x100.png?text=캐시리뷰+배너'),
        const SizedBox(height: 10),
        // 탭 선택 버튼 (전체 / 신청한 체험단)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton('전체', isAllSelected, () {
              setState(() {
                isAllSelected = true;
              });
            }),
            const SizedBox(width: 12),
            _buildTabButton('내가 신청한 체험단', !isAllSelected, () {
              setState(() {
                isAllSelected = false;
              });
            }),
          ],
        ),
        const SizedBox(height: 8),
        // 알림 스위치
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.campaign_outlined, size: 18),
              const SizedBox(width: 4),
              const Expanded(
                  child: Text('체험단 이벤트가 시작하면 알려드려요',
                      style: TextStyle(fontSize: 13))),
              Switch(
                value: notifySwitch,
                onChanged: (val) {
                  setState(() {
                    notifySwitch = val;
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(),
        // 리뷰 리스트
        Expanded(
          child: isAllSelected ? _buildAllReviewList() : _buildMyReviewList(),
        ),
      ],
    );
  }

  // 탭 전환 버튼
  Widget _buildTabButton(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.brown[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // 전체 체험단 리스트
  Widget _buildAllReviewList() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _buildReviewItem(
          title: '듀얼제형, 컬러로 올인원 베이스메이크업',
          applyCount: 0,
          limit: 0,
          remainTime: '0일 0시간 0분',
        ),
        _buildReviewItem(
          title: '강남역 유명 성형외과 방문 캠페인',
          applyCount: 0,
          limit: 0,
          remainTime: '0일 0시간 0분',
        ),
      ],
    );
  }

  // 내가 신청한 체험단
  Widget _buildMyReviewList() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: const [
        Center(child: Text('신청한 체험단이 없습니다.', style: TextStyle(color: Colors.grey))),
      ],
    );
  }

  // 단일 체험단 아이템
  Widget _buildReviewItem({
    required String title,
    required int applyCount,
    required int limit,
    required String remainTime,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
            '$applyCount명 신청 / $limit명 모집\n남은시간: $remainTime'),
        isThreeLine: true,
      ),
    );
  }
}

// ------------------ 퀴즈 탭 ------------------
class _QuizTab extends StatefulWidget {
  const _QuizTab();

  @override
  State<_QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<_QuizTab> {
  bool showUpcoming = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 배너
        Image.network('https://via.placeholder.com/400x100.png?text=돈버는퀴즈+배너'),
        // 타이머 영역
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('다음 퀴즈까지 남은 시간 ', style: TextStyle(color: Colors.white)),
              Icon(Icons.alarm, color: Colors.redAccent),
              SizedBox(width: 6),
              Text('00:00:00',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // 탭 버튼 (예정 / 지난)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleButton('방송예정', showUpcoming, () {
              setState(() {
                showUpcoming = true;
              });
            }),
            const SizedBox(width: 16),
            _buildToggleButton('지난방송', !showUpcoming, () {
              setState(() {
                showUpcoming = false;
              });
            }),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _buildQuizList(isLive: showUpcoming),
        ),
      ],
    );
  }

  // 탭 전환 버튼
  Widget _buildToggleButton(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // 퀴즈 리스트
  Widget _buildQuizList({required bool isLive}) {
    final quizDataLive = [
      {
        'title': '💥알룰로스 땅콩버터 <마지막 50% 긴급세일 종료임박>',
        'applyCount': 0,
        'cash': 0,
      },
      {
        'title': '[실시간 퀴즈] 유기농 건강식품 퀴즈 LIVE!',
        'applyCount': 0,
        'cash': 0,
      },
    ];

    final quizDataPast = [
      {
        'title': '[종료] 방탄커피 64% 특가🔥',
        'applyCount': 0,
        'cash': 0,
      },
      {
        'title': '🎁 이벤트 마감! 오늘도 참여 감사!',
        'applyCount': 0,
        'cash': 0,
      },
    ];

    final quizList = isLive ? quizDataLive : quizDataPast;

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: quizList.length,
      itemBuilder: (context, index) {
        final item = quizList[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상태 + 제목
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isLive ? Colors.red : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isLive ? '진행중' : '종료',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // 참여자 수
              Row(
                children: [
                  const Icon(Icons.people, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${item['applyCount'] ?? 0}명 참여',
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 2),
              // 캐시 정보
              Row(
                children: [
                  const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${item['cash'] ?? 0}캐시 남음',
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
