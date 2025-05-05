import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:cashwalk/services/community_service.dart';

class WritePostPage extends StatefulWidget {
  const WritePostPage({super.key});

  @override
  State<WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final _titleController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();

  // ✅ 게시판 매핑 (UI 이름 → 백엔드 ENUM 값)
  final Map<String, String> _boardMap = {
    '캐시톡 친구 추가 모집': 'FRIEND_RECRUIT',
    '게시판 오픈 신청': 'BOARD_OPEN_REQUEST',
    '하루 6천보 챌린지': 'DAILY_CHALLENGE',
    '자유/일상': 'FREE',
    '공지사항': 'NOTICE',
    '질문답변': 'QNA',
  };

  String _selectedBoard = '자유/일상'; // 기본 선택
  final String _defaultPostCategory = 'GENERAL'; // ✅ 현재는 고정

  bool _isSubmitting = false;

  /// ✅ 게시글 제출 처리
  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final content = _quillController.document.toPlainText().trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await CommunityService.createPost(
        title: title,
        content: content,
        boardType: _boardMap[_selectedBoard]!,
        postCategory: _defaultPostCategory, // ✅ 고정된 카테고리 사용
      );

      if (mounted) {
        Navigator.pop(context, true); // 작성 완료 후 페이지 닫기
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('작성 실패: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _topYellowBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('게시판', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedBoard,
                      items: _boardMap.keys.map((board) {
                        return DropdownMenuItem(value: board, child: Text(board));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedBoard = val!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('제목', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '제목을 입력해주세요',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('내용', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          quill.QuillToolbar.simple(
                            configurations: quill.QuillSimpleToolbarConfigurations(
                              controller: _quillController,
                              showFontSize: true,
                              showBoldButton: true,
                              showItalicButton: true,
                              showListBullets: true,
                              showUndo: true,
                              showRedo: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 280,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: quill.QuillEditor.basic(
                              configurations: quill.QuillEditorConfigurations(
                                controller: _quillController,
                                scrollable: true,
                                expands: false,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEB00),
                            foregroundColor: Colors.black,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('완료'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topYellowBar() {
    return Container(
      color: const Color(0xFFFFEB00),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('커뮤니티', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
