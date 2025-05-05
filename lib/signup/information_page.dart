import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'body_page.dart';

class InformationPage extends StatefulWidget {
  final String nickname;

  const InformationPage({super.key, required this.nickname});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  String? gender;
  DateTime? birthDate;
  String? region;

  final List<String> koreanCities = [
    '서울시', '부산시', '대구시', '인천시', '광주시', '대전시', '울산시',
    '세종시', '경기도', '강원도', '충청북도', '충청남도',
    '전라북도', '전라남도', '경상북도', '경상남도', '제주도'
  ];

  bool get isValid => gender != null && birthDate != null && region != null;

  void _showCustomDatePicker() {
    final now = DateTime.now();
    int selectedYear = birthDate?.year ?? now.year - 20;
    int selectedMonth = birthDate?.month ?? 1;
    int selectedDay = birthDate?.day ?? 1;

    final years = List.generate(100, (i) => now.year - i);
    final months = List.generate(12, (i) => i + 1);
    final days = List.generate(31, (i) => i + 1);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 320,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: years.indexOf(selectedYear),
                        ),
                        itemExtent: 36,
                        onSelectedItemChanged: (index) {
                          selectedYear = years[index];
                        },
                        children: years.map((y) => Center(child: Text('$y'))).toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMonth - 1,
                        ),
                        itemExtent: 36,
                        onSelectedItemChanged: (index) {
                          selectedMonth = index + 1;
                        },
                        children: months.map((m) => Center(child: Text('$m'))).toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedDay - 1,
                        ),
                        itemExtent: 36,
                        onSelectedItemChanged: (index) {
                          selectedDay = index + 1;
                        },
                        children: days.map((d) => Center(child: Text('${d.toString().padLeft(2, '0')}'))).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CupertinoButton(
                    child: const Text('취소'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('선택'),
                    onPressed: () {
                      setState(() {
                        birthDate = DateTime(selectedYear, selectedMonth, selectedDay);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showRegionPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 400,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('거주지역', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: koreanCities.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      title: Text(koreanCities[index]),
                      onTap: () {
                        setState(() {
                          region = koreanCities[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String birthText = birthDate != null
        ? '${birthDate!.year.toString().padLeft(4, '0')}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '성별, 생일, 거주지역 설정하기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.nickname}님,\n성별과 생일, 거주지역을 입력해주세요.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text('성별', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _genderButton('남자'),
                const SizedBox(width: 12),
                _genderButton('여자'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('생일', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showCustomDatePicker,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(text: birthText),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '생년월일 선택',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('거주지역', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showRegionPicker,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(text: region ?? ''),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '거주지역 선택',
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BodyPage(
                        nickname: widget.nickname,
                        gender: gender!,
                        birthDate: birthText,
                        region: region!,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderButton(String value) {
    final isSelected = gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.brown[400] : Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}