import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/intl.dart';

class SummaryPage extends StatefulWidget {
  final double distance;
  final Duration duration;
  final double calories;
  final double pace;
  final List<NLatLng> path;
  final DateTime startTime;
  final DateTime endTime;
  final bool isDistanceMode;
  final bool isUnlimited;

  const SummaryPage({
    super.key,
    required this.distance,
    required this.duration,
    required this.calories,
    required this.pace,
    required this.path,
    required this.startTime,
    required this.endTime,
    this.isDistanceMode = true,
    this.isUnlimited = true,
  });

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  double diaryLevel = 5;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy.MM.dd (E)', 'ko');
    final timeFormatter = DateFormat('hh:mm a', 'en').format;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('러닝기록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                  if (widget.path.length >= 2) {
                    controller.addOverlay(
                      NPolylineOverlay(
                        id: 'summary_path',
                        coords: widget.path,
                        color: Colors.red,
                        width: 4,
                      ),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isUnlimited
                        ? (widget.isDistanceMode ? '거리 무제한 러닝' : '시간 무제한 러닝')
                        : (widget.isDistanceMode ? '거리 목표 러닝' : '시간 목표 러닝'),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormatter.format(widget.startTime)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('${timeFormatter(widget.startTime)} - ${timeFormatter(widget.endTime)}'),
                  const SizedBox(height: 16),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dataTile('시간', _formatDuration(widget.duration)),
                      _dataTile('거리', '${widget.distance.toStringAsFixed(2)}km'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dataTile('소모 칼로리', '${widget.calories.toStringAsFixed(0)} kcal'),
                      _dataTile('페이스', '${widget.pace.toStringAsFixed(2)}/km'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('러닝 일기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('인증샷 남기기', style: TextStyle(fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
