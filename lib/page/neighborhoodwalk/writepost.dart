import 'package:flutter/material.dart';
import '../../utils/board_key_util.dart';
import 'regionsearch.dart';
import 'package:cashwalk/page/neighborhoodwalk/TopBar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class WritePostPage extends StatefulWidget {
  final String region;

  const WritePostPage({super.key, required this.region});

  @override
  State<WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  String _selectedBoard = '동네 일상';
  late String _selectedRegion;
  bool _isSubmitting = false;

  final List<String> _boards = ['공지', '인기', '동네 일상', '동네 정보', '맛집 추천'];

  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.region;
  }

  void _changeRegion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegionSearchPage()),
    );
    if (result != null && result is String) {
      setState(() {
        _selectedRegion = result;
      });
    }
  }

  void _submitPost() {
    FocusScope.of(context).unfocus();

    String title = _titleController.text.trim();
    String content = _quillController.document.toPlainText().trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      setState(() {
        _isSubmitting = true;
      });

      Map<String, dynamic> newPost = {
        'title': '[$_selectedBoard] $title',
        'boardKey': boardKeyFor(_selectedBoard),
        'content': content,
        'nickname': '0',
        'region': _selectedRegion,
        'views': 0,
        'likes': 0,
        'scraps': 0,
        'commentCount': 0,
        'time': DateTime.now().toIso8601String(),
      };

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, newPost);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력하세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _topYellowBar(context),
            TopBar(region: _selectedRegion, onRegionTap: _changeRegion),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 게시판 라벨
                    const Text('게시판', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // 게시판 선택 드롭다운
                    DropdownButtonFormField<String>(
                      value: _selectedBoard,
                      items: _boards.map((board) {
                        return DropdownMenuItem(
                          value: board,
                          child: Text(board),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBoard = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔥 제목 라벨
                    const Text('제목', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // 제목 입력
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '제목을 입력해주세요',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔥 내용 라벨
                    const Text('내용', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // 에디터
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          quill.QuillSimpleToolbar(
                            configurations: quill.QuillSimpleToolbarConfigurations(
                              controller: _quillController,
                              showAlignmentButtons: true,
                              showBackgroundColorButton: true,
                              showBoldButton: true,
                              showItalicButton: true,
                              showFontSize: true,
                              showFontFamily: true,
                              showColorButton: true,
                              showListCheck: true,
                              showLink: true,
                              showCodeBlock: true,
                              multiRowsDisplay: false,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 300,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: quill.QuillEditor.basic(
                              configurations: quill.QuillEditorConfigurations(
                                controller: _quillController,
                                scrollable: true,
                                expands: false,
                                padding: EdgeInsets.zero,
                                scrollBottomInset: 100,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 하단 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            minimumSize: const Size(0, 0),
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text('취소', style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            minimumSize: const Size(0, 0),
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text('완료', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topYellowBar(BuildContext context) {
    return Container(
      color: Colors.amber,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '동네 생활',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}