import 'package:flutter/material.dart';
import 'writepost.dart';
import 'regionsearch.dart'; // ⭐️ 지역 검색 추가
import '../../utils/board_key_util.dart'; // boardKeyFor 함수
import 'package:intl/intl.dart'; // ⭐️ 시간 포맷

class LifeTab extends StatefulWidget {
  const LifeTab({super.key});

  @override
  State<LifeTab> createState() => _LifeTabState();
}

class _LifeTabState extends State<LifeTab> with SingleTickerProviderStateMixin {
  String _selectedRegion = '고아읍';
  late TabController _tabController;

  List<Map<String, dynamic>> posts = [];

  final List<String> _tabs = ['전체글', '공지', '인기', '동네 일상', '동네 정보', '맛집 추천'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _topBar(),
          _tabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: _tabs.map((tab) {
                return _postList();
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () async {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (context) => WritePostPage(region: _selectedRegion)),
          );
          if (result != null) {
            result['region'] = _selectedRegion; // 현재 지역 저장
            setState(() {
              posts.insert(0, result);
            });
          }
        },
        child: const Icon(Icons.edit, color: Colors.black),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final selected = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => const RegionSearchPage()),
              );
              if (selected != null && selected.isNotEmpty) {
                setState(() {
                  _selectedRegion = selected.split(' ').last;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedRegion,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _iconAndLabel(Icons.notifications_none, '알림'),
              const SizedBox(width: 16),
              _iconAndLabel(Icons.bookmark_border, '스크랩'),
              const SizedBox(width: 16),
              _iconAndLabel(Icons.assignment_outlined, '작성글'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconAndLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }

  Widget _tabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: _tabs.map((tab) => Tab(child: Text(tab))).toList(),
        ),
      ),
    );
  }

  Widget _postList() {
    final currentTab = _tabs[_tabController.index];
    final currentBoardKey = boardKeyFor(currentTab);

    return PostListView(posts: posts, currentBoardKey: currentBoardKey);
  }
}

// 🔥 시간 포맷 함수
String formatPostTime(String isoString) {
  if (isoString.isEmpty) return '';
  final postTime = DateTime.tryParse(isoString);
  if (postTime == null) return '';

  final now = DateTime.now();

  if (postTime.year == now.year &&
      postTime.month == now.month &&
      postTime.day == now.day) {
    return DateFormat('HH:mm').format(postTime); // 오늘이면 시:분
  } else {
    return DateFormat('MM/dd').format(postTime); // 아니면 월/일
  }
}

//
// 🔥 PostListView
//
class PostListView extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  final String currentBoardKey;

  const PostListView({super.key, required this.posts, required this.currentBoardKey});

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Map<String, dynamic>> filteredPosts = widget.currentBoardKey == 'all'
        ? widget.posts
        : widget.posts.where((post) => post['boardKey'] == widget.currentBoardKey).toList();

    if (filteredPosts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            '해당 게시판에 글이 없습니다.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(post['nickname'] ?? '익명', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(width: 4),
                          const Icon(Icons.circle, size: 3, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(post['region'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.visibility, size: 16, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text('${post['views'] ?? 0}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(width: 8),
                          const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text('${post['likes'] ?? 0}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(width: 8),
                          const Icon(Icons.bookmark_border, size: 16, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text('${post['scraps'] ?? 0}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(width: 8),
                          Text(formatPostTime(post['time'] ?? ''), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('${post['commentCount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      const Text('댓글', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
