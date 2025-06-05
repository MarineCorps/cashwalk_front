import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';
import '../services/block_service.dart';
import 'package:cashwalk/services/report_service.dart';
import 'package:cashwalk/widgets/report_dialog.dart';
class CommentCard extends StatefulWidget {
  final CommentModel comment;
  final List<CommentModel> replies;
  final VoidCallback onReplyPressed;
  final VoidCallback onRefresh;
  final List<int> blockedUserIds;
  final bool isReplying; // ✅ 추가
  final Widget? replyInput; // ✅ 추가


  const CommentCard({
    super.key,
    required this.comment,
    required this.replies,
    required this.onReplyPressed,
    required this.onRefresh,
    required this.blockedUserIds,
    this.isReplying = false,
    this.replyInput,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late bool likedByMe;
  late bool dislikedByMe;
  late int likeCount;
  late int dislikeCount;
  bool isEditing = false; // ✅ 현재 댓글 수정 중인지 여부
  final TextEditingController _editController = TextEditingController(); // ✅ 입력 필드
  /// ✅ 대댓글 각각의 상태 저장용 Map
  late Map<int, ReplyState> replyStates;
  Map<int, bool> isEditingReply = {}; // 각 대댓글의 수정 여부
  Map<int, TextEditingController> replyEditControllers = {}; // 각 대댓글의 텍스트컨트롤러


  @override
  void initState() {
    super.initState();

    // ✅ 메인 댓글 초기 상태 복사
    likedByMe = widget.comment.likedByMe;
    dislikedByMe = widget.comment.dislikedByMe;
    likeCount = widget.comment.likeCount;
    dislikeCount = widget.comment.dislikeCount;

    // ✅ 각 대댓글 상태 초기화
    replyStates = {
      for (var r in widget.replies)
        r.id: ReplyState(
          likedByMe: r.likedByMe,
          dislikedByMe: r.dislikedByMe,
          likeCount: r.likeCount,
          dislikeCount: r.dislikeCount,
        )
    };
  }
  @override
  void dispose() {
    _editController.dispose(); // 메인 댓글
    for (var controller in replyEditControllers.values) {
      controller.dispose(); // 대댓글 모두 해제
    }
    super.dispose();
  }


  Future<void> _toggleMainReaction(String type) async {
    await CommentService.toggleCommentReaction(widget.comment.id, type);

    setState(() {
      if (type == 'like') {
        if (likedByMe) {
          likedByMe = false;
          likeCount--;
        } else {
          likedByMe = true;
          likeCount++;
          if (dislikedByMe) {
            dislikedByMe = false;
            dislikeCount--;
          }
        }
      } else {
        if (dislikedByMe) {
          dislikedByMe = false;
          dislikeCount--;
        } else {
          dislikedByMe = true;
          dislikeCount++;
          if (likedByMe) {
            likedByMe = false;
            likeCount--;
          }
        }
      }
    });

    widget.onRefresh();
  }

  Future<void> _toggleReplyReaction(int id, String type) async {
    await CommentService.toggleCommentReaction(id, type);

    setState(() {
      final state = replyStates[id];
      if (state == null) return;

      if (type == 'like') {
        if (state.likedByMe) {
          state.likedByMe = false;
          state.likeCount--;
        } else {
          state.likedByMe = true;
          state.likeCount++;
          if (state.dislikedByMe) {
            state.dislikedByMe = false;
            state.dislikeCount--;
          }
        }
      } else {
        if (state.dislikedByMe) {
          state.dislikedByMe = false;
          state.dislikeCount--;
        } else {
          state.dislikedByMe = true;
          state.dislikeCount++;
          if (state.likedByMe) {
            state.likedByMe = false;
            state.likeCount--;
          }
        }
      }
    });

    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainComment(context),
            // ✅ 댓글 본문 바로 아래에 답글 입력창
            if (widget.isReplying && widget.replyInput != null) ...[
              const SizedBox(height: 8),
              widget.replyInput!,
            ],
            const SizedBox(height: 8),
            // ✅ 대댓글은 그 아래
            ...widget.replies.map((r) => _buildReply(context, r)).toList(),
          ],
        ),
      ),

    );
  }


  Widget _buildMainComment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.comment.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (widget.comment.isMine)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.person, size: 16, color: Colors.grey),
              ),
            const Spacer(),
            _buildPopupMenu(widget.comment),
          ],
        ),
        const SizedBox(height: 4),
        isEditing
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _editController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: '댓글을 수정하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false; // 취소
                    });
                  },
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await CommentService.updateComment(widget.comment.id, _editController.text);
                    setState(() {
                      isEditing = false;
                    });
                    widget.onRefresh(); // 수정 완료 후 새로고침
                  },
                  child: const Text('저장'),
                ),
              ],
            )
          ],
        )
            : Text(widget.comment.content),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(DateFormat('yyyy.MM.dd HH:mm').format(widget.comment.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: widget.onReplyPressed,
              child: const Text('답글 쓰기', style: TextStyle(color: Colors.grey)),
            ),
            const Spacer(),
            _buildReactionButtons(
                likedByMe, dislikedByMe, likeCount, dislikeCount, _toggleMainReaction),
          ],
        ),
      ],
    );
  }

  Widget _buildReply(BuildContext context, CommentModel reply) {
    final state = replyStates.putIfAbsent(
      reply.id,
          () => ReplyState(
        likedByMe: reply.likedByMe,
        dislikedByMe: reply.dislikedByMe,
        likeCount: reply.likeCount,
        dislikeCount: reply.dislikeCount,
      ),
    );

    final isEditingThisReply = isEditingReply[reply.id] == true;
    final controller = replyEditControllers[reply.id];

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8, top: 4),
            child: Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(reply.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (reply.isMine)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.person, size: 16, color: Colors.grey),
                      ),
                    const Spacer(),
                    _buildPopupMenu(reply),
                  ],
                ),
                const SizedBox(height: 4),
                isEditingThisReply && controller != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: '답글을 수정하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isEditingReply[reply.id] = false;
                            });
                          },
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final newContent = controller.text.trim();
                            if (newContent.isNotEmpty) {
                              await CommentService.updateComment(reply.id, newContent);
                              setState(() {
                                isEditingReply[reply.id] = false;
                              });
                              widget.onRefresh();
                            }
                          },
                          child: const Text('저장'),
                        ),
                      ],
                    )
                  ],
                )
                    : Text(reply.content),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(DateFormat('yyyy.MM.dd HH:mm').format(reply.createdAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    _buildReactionButtons(
                      state.likedByMe,
                      state.dislikedByMe,
                      state.likeCount,
                      state.dislikeCount,
                          (type) => _toggleReplyReaction(reply.id, type),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildReactionButtons(
      bool liked,
      bool disliked,
      int likeCnt,
      int dislikeCnt,
      Function(String type) onTap,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.thumb_up, color: liked ? Colors.amber : Colors.grey, size: 18),
          onPressed: () => onTap('like'),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text('$likeCnt', style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.thumb_down, color: disliked ? Colors.redAccent : Colors.grey, size: 18),
          onPressed: () => onTap('dislike'),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text('$dislikeCnt', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildPopupMenu(CommentModel c) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == '삭제') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('댓글 삭제'),
              content: const Text('정말로 삭제하시겠습니까?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
              ],
            ),
          );
          if (confirm == true) {
            await CommentService.deleteComment(c.id);
            widget.onRefresh();
          }
        } else if (value == '차단') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('사용자 차단'),
              content: const Text('이 사용자를 차단하시겠습니까?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('차단')),
              ],
            ),
          );
          if (confirm == true) {
            await BlockService.blockUser(c.userId);
            widget.onRefresh();
          }
        } else if (value == '차단해제') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('차단 해제'),
              content: const Text('이 사용자의 차단을 해제하시겠습니까?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('해제')),
              ],
            ),
          );
          if (confirm == true) {
            await BlockService.unblockUser(c.userId);
            widget.onRefresh();
          }
        } else if (value == '수정') {
          setState(() {
            if (c.id == widget.comment.id) {
              isEditing = true;
              _editController.text = c.content;
            } else {
              isEditingReply[c.id] = true;
              replyEditControllers[c.id] ??= TextEditingController(text: c.content);
              replyEditControllers[c.id]!.text = c.content;
            }
          });
        } else if (value == '신고') {
          final reasonCode = await showReportDialog(context);
          if (reasonCode != null) {
            try {
              await ReportService.reportContent(
                targetId: c.id,
                type: 'COMMENT',
                reasonCode: reasonCode,
              );
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('신고 실패: $e')));
            }
          }
        }
      },
      itemBuilder: (context) {
        if (c.isMine) {
          return const [
            PopupMenuItem(value: '수정', child: Text('수정')),
            PopupMenuItem(value: '삭제', child: Text('삭제')),
          ];
        } else if (widget.blockedUserIds.contains(c.userId)) {
          return const [
            PopupMenuItem(value: '차단해제', child: Text('차단해제')),
            PopupMenuItem(value: '신고', child: Text('신고')),
          ];
        } else {
          return const [
            PopupMenuItem(value: '차단', child: Text('차단')),
            PopupMenuItem(value: '신고', child: Text('신고')),
          ];
        }
      },
    );
  }



}

class ReplyState {
  bool likedByMe;
  bool dislikedByMe;
  int likeCount;
  int dislikeCount;

  ReplyState({
    required this.likedByMe,
    required this.dislikedByMe,
    required this.likeCount,
    required this.dislikeCount,
  });
}
