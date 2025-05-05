import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashwalk/services/park_service.dart';
import 'package:cashwalk/services/user_service.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart'; // ✅ 추가
import 'package:cashwalk/widgets/month_picker_dialog.dart';
class RecordTab extends StatefulWidget {
  const RecordTab({super.key});

  @override
  State<RecordTab> createState() => _RecordTabState();
}

class _RecordTabState extends State<RecordTab> {
  DateTime selectedDate = DateTime.now();
  List<String> weeklyStamps = [];
  int monthlyCount = 0;
  Map<String, List<dynamic>> dailyRecords = {};

  String nickname = '';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadWalkRecord();
    _loadUserProfile();
  }

  Future<void> _loadWalkRecord() async {
    final result = await ParkService.fetchWalkRecord(
      selectedDate.year,
      selectedDate.month,
    );
    if (result != null) {
      setState(() {
        weeklyStamps = List<String>.from(result['weeklyStamps']);
        monthlyCount = result['monthlyCount'];
        dailyRecords = Map<String, List<dynamic>>.from(result['dailyRecords']);
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserService.fetchMyProfile();
    final image = await UserService.getProfileImageUrl();
    setState(() {
      nickname = profile.nickname;
      profileImageUrl = image;
    });
  }


  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat('yyyy년 MM월', 'ko').format(selectedDate);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(),
          const SizedBox(height: 8),
          _buildWeeklyStamps(),
          const SizedBox(height: 12),
          const Divider(thickness: 6, height: 6, color: Color(0xFFF2F2F2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _showMonthPicker,
                  child: Row(
                    children: [
                      Text(currentMonth,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]! ?? Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('총 산책 횟수 : $monthlyCount회',
                      style: const TextStyle(fontSize: 13)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCalendar(selectedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage: (profileImageUrl != null &&
                profileImageUrl!.isNotEmpty)
                ? NetworkImage(profileImageUrl!)
                : null,
            child: profileImageUrl == null ? const Icon(
                Icons.person, color: Colors.white) : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${nickname.isNotEmpty ? nickname : '사용자'}님",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text("이번 주는 총 ${weeklyStamps.length}일 산책했어요.",
                  style: const TextStyle(fontSize: 14, color: Colors.black)),
              const Text("* 산책 일수는 매주 월요일 자정에 초기화 됩니다.",
                  style: TextStyle(fontSize: 12, color: Colors.grey))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeeklyStamps() {
    final days = ["월", "화", "수", "목", "금", "토", "일"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days.sublist(0, 4).map((day) {
              final isActive = weeklyStamps.contains(day);
              return _buildDayCircle(day, isActive);
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days.sublist(4, 7).map((day) {
              final isActive = weeklyStamps.contains(day);
              return _buildDayCircle(day, isActive);
            }).toList(),
          ),
        ],
      ),
    );
  }

// ✅ 서브 메서드: 요일 원형 버튼 하나를 그리는 메서드
  Widget _buildDayCircle(String day, bool isActive) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFFEE500) : Colors.white,
            border: Border.all(color: Colors.grey, width: 1.0),
          ),
          child: isActive
              ? const Icon(Icons.check, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 13)),
      ],
    );
  }


  Widget _buildCalendar(DateTime referenceDate) {
    final startOfMonth = DateTime(referenceDate.year, referenceDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
        referenceDate.year, referenceDate.month);
    final startWeekday = startOfMonth.weekday % 7;
    final totalItems = startWeekday + daysInMonth;
    final rows = (totalItems / 7).ceil();
    final totalGridItems = rows * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: totalGridItems,
      itemBuilder: (context, index) {
        final today = DateTime.now();
        final dayNum = index - startWeekday + 1;
        final isValid = dayNum > 0 && dayNum <= daysInMonth;

        if (!isValid) return const SizedBox.shrink();

        final date = DateTime(referenceDate.year, referenceDate.month, dayNum);
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final isToday = date.day == today.day && date.month == today.month &&
            date.year == today.year;

        return Center(
          child: GestureDetector(
            onTap: () {
              if (dailyRecords.containsKey(dateStr)) {
                _showRecordDetail(date, dailyRecords[dateStr]!);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? const Color(0xFFFEE500) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      color: isToday ? Colors.black : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (dailyRecords.containsKey(dateStr))
                  const Positioned(
                    bottom: 4,
                    child: Icon(
                        Icons.circle, color: Color(0xFFFEE500), size: 6),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRecordDetail(DateTime date, List<dynamic> records) {
    final formattedDate = DateFormat('MM/dd (E)', 'ko').format(date);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.3,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              // ✅ 화면 가로 폭 꽉 채움
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              // ✅ margin만 부드럽게
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$formattedDate 산책기록', style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('오늘 보상 받은 횟수 : ${records.length}회'),
                    const SizedBox(height: 12),
                    for (var r in records)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text('🟡 ${r["time"]}  ${r["parkName"]}',
                            style: const TextStyle(fontSize: 14)),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, // ✅ 버튼도 좌우 꽉 차게
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('확인', style: TextStyle(
                            color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE500),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMonthPicker() async {
    await showCustomMonthPicker(
      context,
      selectedDate,
          (pickedDate) {
        setState(() {
          selectedDate = pickedDate;
        });
        _loadWalkRecord();
      },
    );
  }
}