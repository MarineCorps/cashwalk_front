import 'package:flutter/material.dart';
import 'package:cashwalk/services/favorite_service.dart';
import 'package:cashwalk/page/community/unified_post_list.dart';
import 'package:cashwalk/page/community/favorite_tab.dart';
import 'package:cashwalk/page/community/writepost.dart';
import 'package:cashwalk/page/community/community_drawer.dart';
import 'package:cashwalk/page/community/post_detail_widget.dart';
import 'dart:async';

class CommunityPage extends StatefulWidget {
  final int? initialPostId;
  final String? initialBoardType;
  final String? initialPostCategory;

  const CommunityPage({
    super.key,
    this.initialPostId,
    this.initialBoardType,
    this.initialPostCategory,
  });

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int currentIndex = 1; // 기본: 전체 탭
  final List<String> tabs = ['즐겨찾기', '전체', '인기글', '공지'];
  List<String> favoriteTabs = [];
  Map<String, dynamic>? selectedPost;
  String? selectedBoardType;
  String? selectedPostCategory;
  final _favoritesController = StreamController<List<String>>.broadcast();

  final Map<String, String> boardTypeLabels = {
    'FREE': '자유/일상',
    'QNA': '질문답변',
    'NOTICE': '공지사항',
    'FRIEND_RECRUIT': '친구모집',
    'BOARD_OPEN_REQUEST': '게시판 오픈 신청',
    'DAILY_CHALLENGE': '6천보 챌린지',
  };

  final Map<String, String> postCategoryLabels = {
    'BESTLIVE': 'BEST 인기글',
    'LEGEND': '명예의 전당',
  };

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    // ✅ 홈탭에서 게시글이 넘어온 경우 자동 초기화
    if (widget.initialPostId != null) {
      selectedPost = {
        'id': widget.initialPostId,
        'boardType': widget.initialBoardType,
        'postCategory': widget.initialPostCategory,
      };
      selectedBoardType = widget.initialBoardType;
      selectedPostCategory = widget.initialPostCategory;

      if (widget.initialPostCategory == 'BESTLIVE') {
        currentIndex = 2;
      } else if (widget.initialBoardType == 'NOTICE') {
        currentIndex = 3;
      } else {
        currentIndex = 1;
      }
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final boards = await FavoriteService.fetchFavorites();
      setState(() {
        favoriteTabs = boards;
      });
      _favoritesController.add(boards);
    } catch (e) {
      debugPrint('❌ 즐겨찾기 불러오기 실패: $e');
    }
  }

  String? getSelectedFilterLabel() {
    if (selectedBoardType != null) return boardTypeLabels[selectedBoardType];
    if (selectedPostCategory != null) return postCategoryLabels[selectedPostCategory];
    return null;
  }

  /// 📌 현재 탭에 따라 보여줄 게시글 리스트 위젯
  Widget buildTabWidget(String tab) {
    switch (tab) {
      case '즐겨찾기':
        return FavoriteTab(
          favoriteBoards: favoriteTabs,
          onSeeMore: (key) {
            setState(() {
              selectedPost = null;
              selectedBoardType = boardTypeLabels.containsKey(key) ? key : null;
              selectedPostCategory = postCategoryLabels.containsKey(key) ? key : null;

              // 탭 자동 전환
              if (key == 'BESTLIVE') {
                currentIndex = 2;
              } else if (key == 'NOTICE') {
                currentIndex = 3;
              } else if (boardTypeLabels.containsKey(key)) {
                currentIndex = 1;
              } else {
                currentIndex = -1; // 탭 선택 안함 (ex: LEGEND)
              }
            });
          },
          onPostTap: (post) {
            setState(() {
              selectedPost = post;
              selectedBoardType = post['boardType'];
              selectedPostCategory = post['postCategory'];
            });
          },
        );
      case '전체':
      case '인기글':
      case '공지':
        final boardType = tab == '공지'
            ? 'NOTICE'
            : (tab == '전체' ? selectedBoardType : null);
        final postCategory = tab == '인기글'
            ? 'BESTLIVE'
            : (tab == '전체' ? null : selectedPostCategory);

        return UnifiedPostList(
          boardType: boardType,
          postCategory: postCategory,
          onPostTap: (post) {
            setState(() {
              selectedPost = post;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 📍 게시판 선택 드롭다운 (전체 탭에서만 노출됨, 탭 아래 위치)
  Widget buildDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedBoardType,
            hint: const Text('게시판 선택'),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (val) {
              setState(() {
                selectedBoardType = val;
                selectedPostCategory = null;
                selectedPost = null;
              });
            },
            items: boardTypeLabels.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// 🧩 화면 구성 전체
  @override
  Widget build(BuildContext context) {
    final selectedTab = currentIndex >= 0 && currentIndex < tabs.length
        ? tabs[currentIndex]
        : '기타';
    final bool showDropdown = selectedTab == '전체';
    final String? selectedTitle = getSelectedFilterLabel();
    final String? currentKey = selectedBoardType ?? selectedPostCategory;

    return Scaffold(
      backgroundColor: Colors.white,

      /// 📍 왼쪽 햄버거 메뉴 → 즐겨찾기 Drawer
      drawer: StreamBuilder<List<String>>(
        stream: _favoritesController.stream,
        initialData: favoriteTabs,
        builder: (context, snapshot) {
          final favorites = snapshot.data ?? [];

          return CommunityDrawer(
            favoriteBoards: favorites,
            onWritePost: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WritePostPage()),
              );
              if (result == true) setState(() {});
            },
            onToggleFavorite: (type) async {
              try {
                final isFavorite = favorites.contains(type);
                if (isFavorite) {
                  await FavoriteService.removeFavorite(
                    boardType: boardTypeLabels.containsKey(type) ? type : null,
                    postCategory: postCategoryLabels.containsKey(type) ? type : null,
                  );
                } else {
                  await FavoriteService.addFavorite(
                    boardType: boardTypeLabels.containsKey(type) ? type : null,
                    postCategory: postCategoryLabels.containsKey(type) ? type : null,
                  );
                }
                final updated = await FavoriteService.fetchFavorites();
                setState(() {
                  favoriteTabs = updated;
                });
                _favoritesController.add(updated);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isFavorite ? '즐겨찾기 해제됨' : '즐겨찾기 추가됨')),
                );
              } catch (e) {
                debugPrint('❌ 즐겨찾기 토글 실패: $e');
              }
            },
          );
        },
      ),

      /// 📍 상단 AppBar
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('커뮤니티', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      /// 📍 화면 Body
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          /// 📍 최상단 커뮤니티 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                Text('👟', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('community', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          /// 📍 탭 선택 바 (즐겨찾기 / 전체 / 인기글 / 공지)
          _buildTabSelector(),

          /// 📍 선택된 게시판 or 카테고리 이름 + 즐겨찾기 토글 아이콘
          if (selectedTitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedTitle,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  if (currentKey != null)
                    IconButton(
                      icon: Icon(
                        favoriteTabs.contains(currentKey)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber[800],
                      ),
                      onPressed: () async {
                        final isFavorite = favoriteTabs.contains(currentKey);
                        try {
                          if (isFavorite) {
                            await FavoriteService.removeFavorite(
                              boardType: boardTypeLabels.containsKey(currentKey) ? currentKey : null,
                              postCategory: postCategoryLabels.containsKey(currentKey) ? currentKey : null,
                            );
                          } else {
                            await FavoriteService.addFavorite(
                              boardType: boardTypeLabels.containsKey(currentKey) ? currentKey : null,
                              postCategory: postCategoryLabels.containsKey(currentKey) ? currentKey : null,
                            );
                          }
                          final updated = await FavoriteService.fetchFavorites();
                          setState(() {
                            favoriteTabs = updated;
                          });
                          _favoritesController.add(updated);
                        } catch (e) {
                          debugPrint('❌ 즐겨찾기 토글 실패: $e');
                        }
                      },
                    )
                ],
              ),
            ),

          /// 📍 전체 탭일 때만 게시판 드롭다운 노출
          if (showDropdown) buildDropdown(),

          /// 📍 게시글 상세 보기 (선택 시 표시)
          if (selectedPost != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: PostDetailWidget(postId: selectedPost!['id']),
            ),

          /// 📍 실제 게시글 리스트
          if (currentIndex >= 0) buildTabWidget(tabs[currentIndex]),
          if (currentIndex == -1)
            UnifiedPostList(
              boardType: selectedBoardType,
              postCategory: selectedPostCategory,
              onPostTap: (post) {
                setState(() {
                  selectedPost = post;
                });
              },
            ),
        ],
      ),

      /// 📍 하단 글쓰기 FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFEB00),
        child: const Icon(Icons.edit, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WritePostPage()),
          );
          if (result == true) setState(() {});
        },
      ),
    );
  }

  /// 📍 탭 선택 바 위젯 (화면 상단 탭 부분)
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 20, color: Colors.grey),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isSelected = currentIndex == index &&
                      (index != 1 || (selectedBoardType == null && selectedPostCategory == null));

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                        selectedPost = null;
                        selectedBoardType = null;
                        selectedPostCategory = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.amber[800] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isSelected)
                            Container(height: 2, width: 20, color: Colors.amber),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
