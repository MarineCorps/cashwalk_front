import 'package:flutter/material.dart';
import 'plan_tab.dart';
import 'running_tab.dart';
import 'record_tab.dart';

class RunningCrewPage extends StatelessWidget {
  const RunningCrewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('러닝크루', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: '러닝 플랜'),
              Tab(text: '자유러닝'),
              Tab(text: '러닝 기록'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PlanTab(),  // 러닝 플랜 탭
            RunningTab(),  // 자유러닝 탭
            RecordTab(), // 러닝 기록 탭
          ],
        ),
      ),
    );
  }
}
