import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashwalk/services/community_service.dart';
import 'package:cashwalk/services/comment_service.dart';
import 'package:cashwalk/services/block_service.dart';
import 'package:cashwalk/models/comment_model.dart';
import 'package:cashwalk/widgets/comment_card.dart';
import 'package:cashwalk/services/http_service.dart';
import 'package:cashwalk/widgets/report_dialog.dart';
import 'package:cashwalk/services/report_service.dart';
class PostDetailWidget extends StatefulWidget {
  final int postId;
  const PostDetailWidget({super.key, required this.postId});

  @override
  State<PostDetailWidget> createState() => _PostDetailWidgetState();
}

class _PostDetailWidgetState extends State<PostDetailWidget> {
  late int currentPostId;
  Map<String, dynamic>? post;
  List<CommentModel> comments = [];
  List<int> blockedUserIds = [];
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
      setState(() {
        post = data;
        recommendCount = data['likeCount'] ?? 0;
        dislikeCount = data['dislikeCount'] ?? 0;
        bookmarked = data['bookmarked'] ?? false;
        likedByMe = data['likedByMe'] ?? false;
        dislikedByMe = data['dislikedByMe'] ?? false;
        comments = (data['comments'] as List<dynamic>)
            .map((json) => CommentModel.fromJson(json))
            .toList();
      });
    } catch (e) {
      debugPrint('❌ 게시글 상세 조회 실패: $e');
    }
  }

  Future<void> _loadBlockedUsers() async {
    try {
      final ids = await BlockService.fetchBlockedUsers();
      setState(() {
        blockedUserIds = ids.map((u) => u.id).toList();
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

  List<CommentModel> _topLevelComments() =>
      comments.where((c) => c.parentId == null).toList().reversed.toList();

  List<CommentModel> _repliesFor(int parentId) =>
      comments.where((c) => c.parentId == parentId).toList().reversed.toList();

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
              const SizedBox(height: 12),

              // ✅ 이미지가 있으면 렌더링
              if (post!['imageUrl'] != null && post!['imageUrl'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post!['imageUrl'].toString().startsWith('http')
                          ? post!['imageUrl']
                          : '${HttpService.baseUrl}${post!['imageUrl']}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  ),
                ),
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
              child: Text(
                post!['title'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  // 🛠️ 수정 버튼은 껍데기 (페이지 라우팅만 설정)
                  Navigator.pushNamed(context, '/edit-post', arguments: post);
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: const Text('정말 이 게시글을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      await CommunityService.deletePost(currentPostId);
                      if (context.mounted) {
                        Navigator.pop(context); // 뒤로 가기
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                        );
                      }
                    } catch (e) {
                      debugPrint('❌ 게시글 삭제 실패: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('삭제 중 오류가 발생했습니다.')),
                        );
                      }
                    }
                  }
                }
              },
              itemBuilder: (ctx) => [
                if (post?['isMine'] == true) ...[
                  const PopupMenuItem(value: 'edit', child: Text('수정')),
                  const PopupMenuItem(value: 'delete', child: Text('삭제')),
                ]
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(post!['nickname'], style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Text(
              DateFormat('yyyy-MM-dd').format(DateTime.parse(post!['createdAt'])),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                Text('추천 $recommendCount'),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    dislikedByMe ? Icons.thumb_down : Icons.thumb_down_outlined,
                    color: dislikedByMe ? Colors.black : Colors.grey,
                  ),
                  onPressed: () => _toggleReaction('dislike'),
                ),
                Text('비추천 $dislikeCount'),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: bookmarked ? Colors.amber : Colors.grey),
              onPressed: _toggleBookmark,
            ),
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              onPressed: () async {
                if (post!['isMine'] == true) {
                  // ❌ 자기 글인 경우: 신고 불가 알림
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('본인의 게시글은 신고할 수 없습니다.')),
                  );
                  return;
                }

                // ✅ 타인의 글인 경우: 신고 다이얼로그
                final selectedReason = await showReportDialog(context);
                if (selectedReason != null) {
                  try {
                    await ReportService.reportContent(
                      targetId: widget.postId,
                      type: 'POST',
                      reasonCode: selectedReason,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('게시글이 성공적으로 신고되었습니다.')),
                      );
                    }
                  } catch (e) {
                    debugPrint('❌ 신고 실패: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('신고 중 오류가 발생했습니다.')),
                      );
                    }
                  }
                }
              },
            ),

          ],
        )
      ],
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(hintText: '댓글을 입력하세요', border: OutlineInputBorder()),
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
      padding: const EdgeInsets.only(top: 8, left: 40),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: const InputDecoration(hintText: '답글을 입력하세요', border: OutlineInputBorder()),
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
    final topLevel = _topLevelComments();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('댓글 ${topLevel.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...topLevel.map((comment) {
          final replies = _repliesFor(comment.id);
          return CommentCard(
            comment: comment,
            replies: replies,
            blockedUserIds: blockedUserIds,
            onReplyPressed: () {
              setState(() {
                replyingToCommentId = comment.id;
                _replyController.clear();
              });
            },
            onRefresh: _loadPostDetail,
            isReplying: replyingToCommentId == comment.id,
            replyInput: _buildReplyInput(),
          );
        }),
      ],
    );
  }


}
