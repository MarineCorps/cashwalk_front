import 'package:flutter/material.dart';
import 'package:cashwalk/services/community_service.dart';
import 'package:cashwalk/services/comment_service.dart';
import 'package:cashwalk/services/block_service.dart';
import 'package:intl/intl.dart';

class PostDetailWidget extends StatefulWidget {
  final int postId;
  const PostDetailWidget({super.key, required this.postId});

  @override
  State<PostDetailWidget> createState() => _PostDetailWidgetState();
}

class _PostDetailWidgetState extends State<PostDetailWidget> {
  late int currentPostId;
  Map<String, dynamic>? post;
  List<dynamic> comments = [];
  List<int> _blockedUserIds = [];
  bool likedByMe = false;
  bool dislikedByMe = false;
  bool bookmarked = false;
  int recommendCount = 0;
  int dislikeCount = 0;

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  int? replyingToCommentId;

  @override
  void initState() {
    super.initState();
    currentPostId = widget.postId;
    _loadPostDetail();
    _loadBlockedUsers();
  }

  @override
  void didUpdateWidget(covariant PostDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.postId != oldWidget.postId) {
      currentPostId = widget.postId;
      _loadPostDetail();
    }
  }

  Future<void> _loadPostDetail() async {
    try {
      final data = await CommunityService.fetchPostDetail(currentPostId);
    // ✅ 디버깅: 서버에서 받은 첫 댓글 출력
    final firstComment = (data['comments'] as List?)?.firstOrNull;
    if (firstComment != null) {
    print('✅ 서버 응답 첫 댓글 isMine: ${firstComment['isMine']}');
    }

      setState(() {
        post = data;
        recommendCount = data['likeCount'] ?? 0;
        dislikeCount = data['dislikeCount'] ?? 0;
        bookmarked = data['bookmarked'] ?? false;
        comments = data['comments'] ?? [];
        likedByMe = data['likedByMe'] ?? false;
        dislikedByMe = data['dislikedByMe'] ?? false;  // ✅ 이거 추가!
      });
    } catch (e) {
      debugPrint('❌ 게시글 상세 조회 실패: $e');
    }
  }
  Future<void> _loadBlockedUsers() async {
    try {
      final ids = await BlockService.fetchBlockedUsers();

      // 🔁 BlockedUser 리스트에서 id만 추출해서 int 리스트로 변환
      final idList = ids.map((user) => user.id).toList();

      setState(() {
        _blockedUserIds = idList;  // ✅ 이제 타입 일치
      });
    } catch (e) {
      debugPrint('🚫 차단 목록 로딩 실패: $e');
    }
  }


  Future<void> _toggleReaction(String type) async {
    await CommunityService.toggleReaction(currentPostId, type);
    await _loadPostDetail();
  }

  Future<void> _toggleBookmark() async {
    await CommunityService.toggleBookmark(currentPostId);
    await _loadPostDetail();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      await CommentService.createComment(currentPostId, content);
      _commentController.clear();
      await _loadPostDetail();
    } catch (e) {
      debugPrint('❌ 댓글 등록 실패: $e');
    }
  }

  Future<void> _submitReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty || replyingToCommentId == null) return;

    try {
      await CommentService.createReply(currentPostId, content, replyingToCommentId!);
      _replyController.clear();
      setState(() {
        replyingToCommentId = null;
      });
      await _loadPostDetail();
    } catch (e) {
      debugPrint('❌ 대댓글 등록 실패: $e');
    }
  }

  List<Map<String, dynamic>> _groupComments(List<dynamic> rawComments) {
    final topLevel = <Map<String, dynamic>>[];
    final Map<int, List<Map<String, dynamic>>> replyMap = {};

    for (final c in rawComments) {
      final comment = c as Map<String, dynamic>;
      final parentId = comment['parentId'];
      if (parentId == null) {
        topLevel.add(comment);
      } else {
        replyMap.putIfAbsent(parentId, () => []).add(comment);
      }
    }

    for (final parent in topLevel) {
      parent['replies'] = replyMap[parent['id']] ?? [];
    }

    return topLevel;
  }

  @override
  Widget build(BuildContext context) {
    if (post == null) return const Center(child: CircularProgressIndicator());

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Text(post!['content'] ?? '', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              _buildReactionButtons(),
              const Divider(height: 32),
              _buildCommentInput(),
              const SizedBox(height: 16),
              _buildCommentList(),
              if (replyingToCommentId != null) _buildReplyInput(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(post!['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {},
              itemBuilder: (context) => const [
                PopupMenuItem(value: '쪽지', child: Text('쪽지 보내기')),
                PopupMenuItem(value: '차단', child: Text('차단')),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(post!['nickname'] ?? '익명', style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(post!['createdAt'])), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('조회 ${post!['views']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 8),
            Text('추천 $recommendCount', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildReactionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👍 추천 / 👎 비추천 → 🔧 중앙 정렬
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // ✅ 가운데 정렬
          children: [
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    likedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: likedByMe ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => _toggleReaction('like'),
                ),
                Text('추천 $recommendCount', style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    dislikedByMe ? Icons.thumb_down : Icons.thumb_down_outlined,
                    color: dislikedByMe ? Colors.black : Colors.grey, // ✅ 검정색 적용
                  ),
                  onPressed: () => _toggleReaction('dislike'),
                ),
                Text('비추천 $dislikeCount', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),

        // 📌 북마크 / 🔗 공유 / 🚩 신고 (오른쪽)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                bookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: bookmarked ? Colors.amber : Colors.grey,
              ),
              onPressed: _toggleBookmark,
            ),
            IconButton(icon: const Icon(Icons.share, color: Colors.grey), onPressed: () {}),
            IconButton(icon: const Icon(Icons.flag_outlined, color: Colors.grey), onPressed: () {}),
          ],
        ),
      ],
    );
  }



  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: '댓글을 입력하세요',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _submitComment,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEB00), foregroundColor: Colors.black),
          child: const Text('등록'),
        ),
      ],
    );
  }

  Widget _buildReplyInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: '답글을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _submitReply,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEB00), foregroundColor: Colors.black),
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    final grouped = _groupComments(comments).reversed.toList();

    // ✅ 디버깅: 전체 댓글 수 및 첫 댓글의 isMine
    if (grouped.isNotEmpty) {
      print('✅ 렌더링용 댓글 수: ${grouped.length}, 첫 댓글 isMine: ${grouped.first['isMine']}');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('댓글 ${grouped.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...grouped.map((comment) {
          final parentId = comment['id'];
          final replies = (comment['replies'] as List).reversed.toList(); //대댓글은 오름차순

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCommentItem(comment),
              ...replies.map((r) => _buildCommentItem(r, isReply: true)),
              if (replyingToCommentId == parentId)
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: _buildInlineReplyInput(),
                ),
            ],
          );
        }),
      ],
    );
  }


  Widget _buildCommentItem(Map<String, dynamic> c, {bool isReply = false}) {
    final int commentId = c['id'];
    final bool liked = c['likedByMe'] ?? false;
    final bool disliked = c['dislikedByMe'] ?? false;
    final int likeCount = c['likeCount'] ?? 0;
    final int dislikeCount = c['dislikeCount'] ?? 0;
    final bool isMine = c['isMine'] ?? false;
    final int userId = c['userId'];

    // ✅ 디버깅: 현재 댓글의 id, isMine, isReply 출력
    print('📌 댓글 렌더링: id=$commentId, isReply=$isReply, isMine=$isMine');
    return Container(
      margin: EdgeInsets.only(bottom: 12, left: isReply ? 48 : 4),
      padding: EdgeInsets.all(isReply ? 8 : 12),
      decoration: BoxDecoration(
        color: isReply ? Colors.grey.shade50 : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(isReply ? 6 : 8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReply)
            const Padding(
              padding: EdgeInsets.only(right: 8, top: 4),
              child: Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
            ),

          // ✅ Expanded 처리로 overflow 방지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧑 닉네임 + 메뉴
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        c['nickname'] ?? '익명',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isReply ? 13 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == '수정') {
                          if (isReply) {
                            _replyController.text = c['content'];
                            replyingToCommentId = c['parentId'] ?? commentId;
                          } else {
                            _commentController.text = c['content'];
                            replyingToCommentId = null;
                          }
                        } else if (value == '삭제') {
                          await CommentService.deleteComment(commentId);
                          await _loadPostDetail();
                        } else if (value == '신고') {
                          await CommentService.reportComment(commentId, 'INAPPROPRIATE');
                        } else if (value == '차단') {
                          await BlockService.blockUser(userId);
                          await _loadPostDetail();
                        } else if (value == '차단해제') {
                          await BlockService.unblockUser(userId);
                          await _loadPostDetail();
                        }
                      },
                      itemBuilder: (context) {
                        if (isMine) {
                          return const [
                            PopupMenuItem(value: '수정', child: Text('수정')),
                            PopupMenuItem(value: '삭제', child: Text('삭제')),
                          ];
                        } else if (_blockedUserIds.contains(userId)) {
                          return const [
                            PopupMenuItem(value: '신고', child: Text('신고')),
                            PopupMenuItem(value: '차단해제', child: Text('차단해제')),
                          ];
                        } else {
                          return const [
                            PopupMenuItem(value: '신고', child: Text('신고')),
                            PopupMenuItem(value: '차단', child: Text('차단')),
                          ];
                        }
                      },
                      icon: const Icon(Icons.more_vert, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 💬 댓글 내용 (줄바꿈 허용)
                Text(
                  c['content'] ?? '',
                  style: TextStyle(fontSize: isReply ? 13 : 14),
                  softWrap: true,
                ),
                const SizedBox(height: 8),

                // 📅 날짜 + 답글 + 반응버튼들
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      c['createdAt'] != null
                          ? DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(c['createdAt']))
                          : '날짜 없음',
                      style: TextStyle(fontSize: isReply ? 11 : 12, color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          replyingToCommentId = c['parentId'] ?? commentId;
                          _replyController.clear();
                        });
                      },
                      child: Text(
                        '답글 쓰기',
                        style: TextStyle(fontSize: isReply ? 11 : 12, color: Colors.grey),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: liked ? Colors.amber : Colors.grey, size: 18),
                      onPressed: () async {
                        await CommentService.toggleCommentReaction(commentId, 'like');
                        await _loadPostDetail();
                      },
                      constraints: const BoxConstraints(), // 크기 강제 줄임
                      padding: EdgeInsets.zero,
                    ),
                    Text('$likeCount', style: TextStyle(fontSize: isReply ? 11 : 12)),
                    IconButton(
                      icon: Icon(Icons.thumb_down, color: disliked ? Colors.redAccent : Colors.grey, size: 18),
                      onPressed: () async {
                        await CommentService.toggleCommentReaction(commentId, 'dislike');
                        await _loadPostDetail();
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    Text('$dislikeCount', style: TextStyle(fontSize: isReply ? 11 : 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineReplyInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _replyController,
            decoration: const InputDecoration(
              hintText: '답글을 입력하세요',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _submitReply,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFEB00),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: const Text('등록', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }


}
