import 'package:flutter/material.dart';

class PlanTab extends StatefulWidget {
  const PlanTab({super.key});

  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  String selectedCategory = '전체 러닝';

  final List<Map<String, dynamic>> runningList = [
    {
      'title': '매일 걷기 습관',
      'description': '하루하루 꾸준히 걷기로 체력을 늘려봐요!',
      'tags': ['#걷기'],
      'imagePath': 'assets/images/tree.png',
      'category': '단계 러닝',
    },
    {
      'title': '러닝 실력 향상',
      'description': '하루하루 달리면서 건강한 하루를 마무리해요!',
      'tags': ['#러닝'],
      'imagePath': 'assets/images/tree.png',
      'category': '단계 러닝',
    },
    {
      'title': '다이어트 러닝',
      'description': '러닝하면서 다이어트 정보를!',
      'tags': ['#식이요법', '#다이어트'],
      'imagePath': 'assets/images/tree.png',
      'category': '목적 러닝',
    },
    {
      'title': '체력증진 러닝',
      'description': '러닝하면서 체력을 늘릴 수 있도록!',
      'tags': ['#근력', '#지구력'],
      'imagePath': 'assets/images/tree.png',
      'category': '목적 러닝',
    },
    {
      'title': '스트레스 해소 러닝',
      'description': '스트레스를 날리는 힐링 러닝!',
      'tags': ['#힐링', '#응원'],
      'imagePath': 'assets/images/tree.png',
      'category': '목적 러닝',
    },
    {
      'title': '아침 러닝',
      'description': '공복 유산소로 하루 시작!',
      'tags': ['#공복 러닝'],
      'imagePath': 'assets/images/tree.png',
      'category': '시간 러닝',
    },
    {
      'title': '오후 러닝',
      'description': '오후의 나른함을 러닝으로!',
      'tags': ['#점심 러닝'],
      'imagePath': 'assets/images/tree.png',
      'category': '시간 러닝',
    },
    {
      'title': '야간 러닝',
      'description': '하루를 상쾌하게 마무리!',
      'tags': ['#저녁', '#심야 러닝'],
      'imagePath': 'assets/images/tree.png',
      'category': '시간 러닝',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔥 배너
        Container(
          margin: const EdgeInsets.all(16),
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black87,
            image: const DecorationImage(
              image: AssetImage('assets/images/tree.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            child: const Text(
              '새로워진 러닝크루와 함께\n러닝도 하고 캐시도 받아볼까요?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // 🔥 카테고리 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryButton('전체 러닝'),
                const SizedBox(width: 8),
                _buildCategoryButton('단계 러닝'),
                const SizedBox(width: 8),
                _buildCategoryButton('목적 러닝'),
                const SizedBox(width: 8),
                _buildCategoryButton('시간 러닝'),
              ],
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '나에게 맞는 러닝 가이드를 받아보세요!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),


        const SizedBox(height: 16),

        // 🔥 러닝 리스트
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _filteredRunningList()
                .map((item) => _buildRunningCard(item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String title) {
    final isSelected = selectedCategory == title;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = title;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(title),
    );
  }

  List<Map<String, dynamic>> _filteredRunningList() {
    if (selectedCategory == '전체 러닝') {
      return runningList;
    } else {
      return runningList
          .where((item) => item['category'] == selectedCategory)
          .toList();
    }
  }

  Widget _buildRunningCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.asset(
              item['imagePath'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'],
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: (item['tags'] as List<String>)
                        .map((tag) => Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.deepOrange,
                      ),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '30분',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
