import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/intl.dart';
import 'package:cashwalk/services/running_service.dart';

class RunningDetailPage extends StatefulWidget {
  final int recordId;

  const RunningDetailPage({super.key, required this.recordId});

  @override
  State<RunningDetailPage> createState() => _RunningDetailPageState();
}

class _RunningDetailPageState extends State<RunningDetailPage> {
  Map<String, dynamic>? record;
  double diaryLevel = 5;
  TextEditingController memoController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final data = await RunningService.fetchRunningRecordDetail(widget.recordId);
    setState(() {
      record = data;
      diaryLevel = (data['diaryLevel'] ?? 5).toDouble();
      memoController.text = data['diaryMemo'] ?? '';
      isLoading = false;
    });
  }

  Future<void> _updateDiary() async {
    final data = {
      'diaryLevel': diaryLevel.toInt(),
      'diaryMemo': memoController.text.trim(),
    };
    await RunningService.updateRunningDiary(widget.recordId, data);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _deleteRecord() async {
    await RunningService.deleteRunningRecord(widget.recordId);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy.MM.dd (E)', 'ko');
    final timeFormatter = DateFormat('hh:mm a', 'en').format;

    if (isLoading || record == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final start = DateTime.tryParse(record?['startTime'] ?? '') ?? DateTime.now();
    final end = DateTime.tryParse(record?['endTime'] ?? '') ?? DateTime.now();
    final duration = Duration(seconds: record?['duration'] ?? 0);
    final distance = (record?['distance'] ?? 0).toDouble();
    final pace = (record?['pace'] ?? 0).toDouble();
    final calories = (record?['calories'] ?? 0).toDouble();
    final isUnlimited = record?['isUnlimited'] ?? false;
    final isDistanceMode = record?['isDistanceMode'] ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('러닝기록'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _updateDiary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteRecord,
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: NaverMap(
              options: const NaverMapViewOptions(
                locationButtonEnable: false,
                scrollGesturesEnable: false,
                zoomGesturesEnable: false,
                tiltGesturesEnable: false,
              ),
              onMapReady: (controller) {
                final path = (record?['path'] ?? []) as List;
                final polyline = path.map((e) {
                  final lat = e['lat'] ?? 0.0;
                  final lng = e['lng'] ?? 0.0;
                  return NLatLng(lat, lng);
                }).toList();

                if (polyline.length >= 2) {
                  controller.addOverlay(NPolylineOverlay(
                    id: 'running_path',
                    coords: polyline,
                    color: Colors.orangeAccent,
                    width: 4,
                  ));
                }
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUnlimited
                        ? (isDistanceMode ? '거리 무제한 러닝' : '시간 무제한 러닝')
                        : (isDistanceMode ? '거리 목표 러닝' : '시간 목표 러닝'),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(formatter.format(start), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${timeFormatter(start)} - ${timeFormatter(end)}'),
                  const SizedBox(height: 16),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dataTile('시간', _formatDuration(duration)),
                      _dataTile('거리', '${distance.toStringAsFixed(2)}km'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dataTile('소모 칼로리', '${calories.toStringAsFixed(0)} kcal'),
                      _dataTile('페이스', _formatPace(pace)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('러닝 일기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('매우 쉬움'),
                      Text('보통'),
                      Text('매우 힘듦'),
                    ],
                  ),
                  Slider(
                    value: diaryLevel,
                    onChanged: (v) {
                      setState(() {
                        diaryLevel = v;
                      });
                    },
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: Colors.deepOrange,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: memoController,
                    decoration: InputDecoration(
                      hintText: '한줄 메모를 입력해주세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepOrange),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _dataTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatPace(double p) {
    final min = p.floor();
    final sec = ((p - min) * 60).round().toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
