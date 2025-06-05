import 'package:flutter/material.dart';
import 'package:cashwalk/page/neighborhoodwalk/life_tab.dart';
import 'package:cashwalk/page/neighborhoodwalk/walk_tab.dart';
import 'package:cashwalk/page/neighborhoodwalk/record.dart';
import 'package:cashwalk/page/neighborhoodwalk/neighborhoodCertificationPage.dart';

class NeighborhoodWalk extends StatefulWidget {
  const NeighborhoodWalk({super.key});

  @override
  State<NeighborhoodWalk> createState() => _NeighborhoodWalkState();
}

class _NeighborhoodWalkState extends State<NeighborhoodWalk> {
  int _selectedIndex = 0;

  final List<String> _titles = ['홈', '동네 생활', '주변 산책', '산책 기록'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.black),
        ),
        actions: _selectedIndex == 0
            ? [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
            ),
            child: const Text(
              '동네산책 사용법',
              style: TextStyle(color: Colors.black),
            ),
          )
        ]
            : null,
      ),
      body: _getSelectedTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '동네 생활',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '주변 산책',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '산책 기록',
          ),
        ],
      ),
    );
  }

  Widget _getSelectedTab() {
    switch (_selectedIndex) {
      case 0:
        return _homeContent();
      case 1:
        return const LifeTab();
      case 2:
        return const WalkTab();
      case 3:
        return const RecordTab();
      default:
        return _homeContent();
    }
  }

  Widget _homeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _weatherCard(),
          const SizedBox(height: 16),
          _missionNotice(),
          const SizedBox(height: 16),
          _missionButtonCard(
            icon: Icons.directions_walk,
            title: '주변 산책하고 캐시 적립하기',
            subtitle: '일주일 동안 산책하면, 최대 350캐시 적립',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalkTab()),
              );
            },
          ),
          const SizedBox(height: 10),
          _missionButtonCard(
            icon: Icons.verified_user,
            title: '우리 동네 인증하기',
            subtitle: '동네 인증하고 최대 1,000캐시 적립하기',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NeighborhoodCertificationPage()),
              );
            },
          ),
          const SizedBox(height: 20),
          _neighborStories(),
        ],
      ),
    );
  }

  Widget _weatherCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📍 경기도 용인시 기흥구 동백동'),
                Text('최저 12° / 최고 29°'),
              ],
            ),
            SizedBox(height: 10),
            Text('🌙 25°C', style: TextStyle(fontSize: 32)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Chip(label: Text('미세먼지: 보통')),
                Chip(label: Text('초미세먼지: 보통')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _missionNotice() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '우리 동네 보물찾기!\n산책하면서 숨은 10개시를 찾아보세요.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _missionButtonCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListTile(
          leading: Icon(icon, size: 30, color: Colors.black),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _neighborStories() {
    final stories = List.generate(10, (i) => {
      'title': ' ${i + 1}',
      'location': '${i + 1}동',
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('동네 이웃들의 이야기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('더보기 >'),
            ],
          ),
        ),
        ListView.builder(
          itemCount: stories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final story = stories[index];
            return ListTile(
              leading: Text('${index + 1}'.padLeft(2, '0')),
              title: Text(story['title']!),
              trailing: Text(story['location']!),
            );
          },
        ),
      ],
    );
  }
}