import 'package:flutter/material.dart';

/// ✅ Cashwalk 스타일 맞춤 Month Picker Dialog
Future<void> showCustomMonthPicker(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
    ) async {
  int tempSelectedMonth = selectedDate.month;
  int tempSelectedYear = selectedDate.year;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 380,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                // 🔥 상단 연도 + 좌우 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 24),
                      onPressed: () {
                        tempSelectedYear--;
                        (context as Element).markNeedsBuild();
                      },
                    ),
                    Text(
                      "$tempSelectedYear",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 24),
                      onPressed: () {
                        tempSelectedYear++;
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 🔥 월 선택 (3행 4열)
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = tempSelectedMonth == month;

                      return GestureDetector(
                        onTap: () {
                          tempSelectedMonth = month;
                          (context as Element).markNeedsBuild();
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFFFEE500) : Colors.transparent,
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            "$month월",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 🔥 하단 취소 / 확인 버튼
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('취소', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onDateSelected(DateTime(tempSelectedYear, tempSelectedMonth));
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('확인', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
