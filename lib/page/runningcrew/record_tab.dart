import 'package:flutter/material.dart';

class RecordTab extends StatelessWidget {
  const RecordTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('러닝기록'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 30),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('cashwalker 님', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('총 러닝 ', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        width: 200,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 0,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Lv.1 ', style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              ToggleButtons(
                isSelected: const [true, false],
                onPressed: (_) {},
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('My')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('With')),
                ],
                borderRadius: BorderRadius.circular(20),
                borderColor: Colors.grey,
                selectedBorderColor: Colors.deepOrange,
                selectedColor: Colors.deepOrange,
              ),
              const SizedBox(height: 24),
              const Text('이번주 러닝 일기 2025.04', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  final dayNums = ['21', '22', '23', '24', '25', '26', '27'];
                  return Column(
                    children: [
                      Text(days[index], style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(dayNums[index], style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Text('베스트기록', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildEmptyCard(''),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('최근기록', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('더보기', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              _buildEmptyCard(''),
              _buildEmptyCard(''),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
