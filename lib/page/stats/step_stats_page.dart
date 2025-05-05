import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:cashwalk/models/step_stat.dart';
import 'package:cashwalk/services/step_api_service.dart';

class StepStatsPage extends StatefulWidget {
  const StepStatsPage({Key? key}) : super(key: key);

  @override
  State<StepStatsPage> createState() => _StepStatsPageState();
}

class _StepStatsPageState extends State<StepStatsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _baseDate;
  String _range = 'daily'; // 'daily', 'weekly', 'monthly'
  List<StepStat> _stats = [];

  int _totalSteps = 0;
  double _distanceKm = 0;
  double _calories = 0;
  double _hours = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _baseDate = DateTime.now();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchStats();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _range = ['daily', 'weekly', 'monthly'][_tabController.index];
        _baseDate = DateTime.now();
        _fetchStats();
      });
    }
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
    });

    final stats = await StepApiService.fetchStepStats(_range, _baseDate);

    _calculateSummary(stats);

    setState(() {
      _stats = stats; // ✅ 가공 없이 바로 사용
      _isLoading = false;
    });
  }


  void _calculateSummary(List<StepStat> stats) {
    _totalSteps = stats.fold(0, (sum, s) => sum + s.steps);
    _distanceKm = _totalSteps * 0.0007;
    _calories = _totalSteps * 0.04;
    _hours = _totalSteps * 0.0006;
  }

  void _movePeriod(int offset) {
    setState(() {
      if (_range == 'daily') {
        _baseDate = _baseDate.add(Duration(days: offset));
      } else if (_range == 'weekly') {
        _baseDate = _baseDate.add(Duration(days: 7 * offset));
      } else {
        _baseDate = DateTime(_baseDate.year, _baseDate.month + offset, 1);
      }
    });
    _fetchStats();
  }

  String _formatPeriod() {
    if (_range == 'daily') {
      return DateFormat('M월 d일 EEEE', 'ko').format(_baseDate);
    } else if (_range == 'weekly') {
      final start = _baseDate.subtract(Duration(days: _baseDate.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${DateFormat('M월 d일').format(start)} ~ ${DateFormat('M월 d일').format(end)}';
    } else {
      return DateFormat('M월', 'ko').format(_baseDate);
    }
  }

  double _calculateMaxY() {
    if (_stats.isEmpty) return 1000;
    final maxSteps = _stats.map((e) => e.steps).reduce((a, b) => a > b ? a : b);
    if (maxSteps == 0) return 1000;
    return (maxSteps * 1.1 / 1000).ceil() * 1000; // 10% 정도 여유
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('걸음 통계'),
      ),
      body: Column(
        children: [
          // ✅ 상단 탭 (일 / 주 / 월)
          Container(
            color: Colors.grey[200],
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              tabs: const [
                Tab(text: '일'),
                Tab(text: '주'),
                Tab(text: '월'),
              ],
            ),
          ),
          // ✅ 날짜 이동 (◀️ 4월 27일 ▶️)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _movePeriod(-1),
                  icon: const Icon(Icons.arrow_left),
                ),
                Text(
                  _formatPeriod(), // ✅ 날짜 포맷: "4월 27일", "4월 3주차" 이런 식
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _movePeriod(1),
                  icon: const Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),
          // ✅ 본문 (로딩 / 데이터 없음 / 데이터 표시)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _stats.isEmpty
                ? const Center(child: Text('데이터 없음'))
                : Column(
              children: [
                _buildSummary(), // ✅ 위 통계 요약 (걸음수, 칼로리, 거리, 시간, 속도)
                Expanded(child: _buildChart()), // ✅ 아래 그래프
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final minutes = (_hours * 60).round();
    final speed = (_distanceKm / (minutes / 60)).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // ✅ 걸음수
          Text(
            '$_totalSteps 걸음',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // ✅ 2x2 통계 (칼로리, 거리, 시간, 속도)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.local_fire_department, '${_calories.toStringAsFixed(0)} kcal', '칼로리'),
              _buildStatItem(Icons.place, '${_distanceKm.toStringAsFixed(2)} km', '거리'),
              _buildStatItem(Icons.timer, '$minutes 분', '시간'),
              _buildStatItem(Icons.speed, '$speed km/h', '속도'),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.grey[600], // ✅ 아이콘 회색
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// ✅ 날짜 포맷 (일간은 요일 포함)
  String _formatSelectedDate() {
    final weekdayNames = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];

    if (_range == 'daily') {
      return '${_baseDate.month}월 ${_baseDate.day}일 ${weekdayNames[_baseDate.weekday - 1]}'; // 일간만 요일 포함
    } else {
      return '${_baseDate.month}월 ${_baseDate.day}일'; // 주간/월간은 요일 없이 날짜만
    }
  }


  Widget _summaryItem(IconData icon, String value, String title) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.grey, // 아이콘 색상
          size: 20, // 아이콘 크기
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }


  Widget _buildChart() {
    final lastDayOfMonth = DateTime(_baseDate.year, _baseDate.month + 1, 0).day;

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelPlacement: LabelPlacement.betweenTicks,
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          final label = details.text; // 기본 라벨 (예: "4/01", "4/02", "4/15" 등)

          if (_range == 'weekly') {
            // ✅ 주간: 항상 2자리로 4/01, 4/02 포맷
            final parts = label.split('/');
            final month = parts[0];
            final day = parts[1].padLeft(2, '0');
            return ChartAxisLabel('$month/$day', null);
          } else if (_range == 'monthly') {
            // ✅ 월간: 1일은 "4/01", 15/30은 숫자만 (15, 30)
            final parts = label.split('/');
            final month = parts[0];
            final day = int.tryParse(parts[1]) ?? 0;

            if (day == 1) {
              final formattedDay = day.toString().padLeft(2, '0');
              return ChartAxisLabel('$month/$formattedDay', null); // 예: 4/01
            } else if (day == 15 || day == 30) {
              return ChartAxisLabel('$day', null); // 예: 15, 30
            } else {
              return ChartAxisLabel('', null); // 그 외 날짜는 비움
            }
          }
          return ChartAxisLabel(label, null); // ✅ 일간은 그냥 출력
        },
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: _calculateMaxY(),
      ),
      series: _range == 'daily'
          ? <SplineAreaSeries<StepStat, String>>[
        SplineAreaSeries<StepStat, String>(
          dataSource: _stats,
          xValueMapper: (s, _) => s.date.hour.toString(), // ✅ 일간: 시간(0~23)
          yValueMapper: (s, _) => s.steps,
          gradient: const LinearGradient(
            colors: [Colors.black, Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          markerSettings: const MarkerSettings(isVisible: true),
          color: Colors.black,
        ),
      ]
          : <ColumnSeries<StepStat, String>>[
        ColumnSeries<StepStat, String>(
          dataSource: _stats,
          xValueMapper: (s, _) => DateFormat('M/dd').format(s.date), // ✅ 주간/월간: 항상 M/dd
          yValueMapper: (s, _) => s.steps,
          color: Colors.black,
          borderRadius: const BorderRadius.all(Radius.circular(0)),
          width: 1, // ✅ 꽉찬 막대
          spacing: 0.1, // ✅ 살짝 띄운 간격
        ),
      ],
    );
  }
}
