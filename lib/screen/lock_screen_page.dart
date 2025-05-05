import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cashwalk/widgets/lock_screen_step_widget.dart';

/// ✅ 잠금화면 오른쪽 슬라이드로 등장하는 Google 검색 패널 + 메인 위젯 통합
class LockScreenSlidePanel extends StatefulWidget {
  const LockScreenSlidePanel({super.key});

  @override
  State<LockScreenSlidePanel> createState() => _LockScreenSlidePanelState();
}

class _LockScreenSlidePanelState extends State<LockScreenSlidePanel>
    with SingleTickerProviderStateMixin {
  double dragOffset = 0; // 드래그한 거리
  bool panelVisible = false; // 검색 패널이 열렸는지 여부
  final double maxPanelWidth = 300;
  final TextEditingController _controller = TextEditingController();

  /// 🔍 구글 검색 실행 함수
  void _searchGoogle(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/search?q=$encodedQuery');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('❌ 검색 실행 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔹 메인 잠금화면 콘텐츠 (걸음 수 + 시간 + 보물상자 포함)
        const LockScreenStepWidget(),

        // 🔹 오른쪽 검색 버튼 힌트 (|<| 형태)
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 30,
          right: 0,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                dragOffset += details.delta.dx;
                if (dragOffset < -50) {
                  panelVisible = true;
                }
              });
            },
            child: Container(
              width: 24,
              height: 60,
              color: Colors.transparent,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
            ),
          ),
        ),

        // 🔹 슬라이드 패널
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: 0,
          bottom: 0,
          right: panelVisible ? 0 : -maxPanelWidth,
          width: maxPanelWidth,
          child: Material(
            elevation: 10,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Google 검색", style: TextStyle(fontSize: 18)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => panelVisible = false),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _searchGoogle,
                    decoration: InputDecoration(
                      hintText: "검색어를 입력하세요...",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _searchGoogle(_controller.text),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
