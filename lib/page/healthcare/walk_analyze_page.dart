import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../utils/alert_util.dart';

class WalkAnalyzyPage extends StatefulWidget {
  const WalkAnalyzyPage({super.key});
  @override
  WalkAnalyzyPageState createState() => WalkAnalyzyPageState();
}

class WalkAnalyzyPageState extends State<WalkAnalyzyPage> {
  final _bt = BluetoothClassic();
  Device? _device;
  bool _connected = false;
  bool _measuring = false;
  String _status = '초기화 중…';

  static const int FS = 50;
  static const int WINDOW_CVHR = 15;
  static const int WINDOW_VR = 3;
  static const double _vrThreshold = 1.5 + 0.166;

  final Queue<double> _tBuf = Queue<double>();
  final Queue<double> _ayBuf = Queue<double>();
  final Queue<double> _azBuf = Queue<double>();

  List<String> _reasons = [];
  int _cvAbCnt = 0, _hrAbCnt = 0, _vrAbCnt = 0;
  int _cvExceed = 0, _hrExceed = 0, _vrExceed = 0;

  bool _cvWasAbnormal = false;
  bool _hrWasAbnormal = false;
  bool _vrWasAbnormal = false;

  StreamSubscription<Uint8List>? _sub;
  DateTime? _measStartTime;

  final List<double> _cvList = [];
  final List<double> _hrList = [];
  final List<double> _vrList = [];

  static const Map<String, String> _reasonText = {
    'Stride‐CV ↑': '걸음 박자가 불규칙해요',
    'Harmonic Ratio ↓': '걸음이 좌우 균형이 안 맞아요',
    'Vertical RMS ↑': '착지 충격이 너무 강해요',
  };
  bool _ttsEnabled = true;      // TTS ON/OFF
  bool _alerting = false;       // 이미 알림 중인지 체크
  Timer? _alertTimer;           // 반복 타이머


  @override
  void initState() {
    super.initState();
    _initBt();
    _bt.onDeviceStatusChanged().listen((st) => setState(() => _connected = st == Device.connected));
  }

  Future<void> _initBt() async {
    await _bt.initPermissions();
    final paired = await _bt.getPairedDevices();
    final hc = paired.where((d) => (d.name?.contains('HC') ?? false) || d.address.startsWith('98:D3:'));
    setState(() {
      _device = hc.isNotEmpty ? hc.first : (paired.isNotEmpty ? paired.first : null);
      _status = _device != null ? '장치 준비됨' : 'HC-06 페어링 필요';
    });
  }

  Future<void> _connect() async {
    if (_device == null) {
      setState(() => _status = '페어링된 HC-06 없음');
      return;
    }
    setState(() => _status = '블루투스 연결 중…');
    const spp = '00001101-0000-1000-8000-00805F9B34FB';
    final ok = await _bt.connect(_device!.address, spp).catchError((e) {
      setState(() => _status = '연결 예외: $e');
      return false;
    });
    if (!(ok as bool)) {
      setState(() => _status = '연결 실패');
      return;
    }
    setState(() => _status = '연결 성공');
  }

  Future<void> _disconnect() async {
    await _bt.disconnect();
    await _sub?.cancel();
    _resetSession();
    setState(() => _status = '연결 해제됨');
  }

  void _resetSession() {
    _measuring = false;
    _tBuf.clear();
    _ayBuf.clear();
    _azBuf.clear();
    _reasons.clear();
    _cvAbCnt = _hrAbCnt = _vrAbCnt = 0;
    _cvExceed = _hrExceed = _vrExceed = 0;
    _cvWasAbnormal = _hrWasAbnormal = _vrWasAbnormal = false;
    _measStartTime = null;
    _cvList.clear();
    _hrList.clear();
    _vrList.clear();
  }

  void _startMeasurement() {
    if (!_connected) return;
    _resetSession();
    _measStartTime = DateTime.now();
    setState(() {
      _measuring = true;
      _status = '측정 중…';
    });
    _sub = _bt.onDeviceDataReceived().listen(
      _onData,
      onError: (e) => print('stream error: $e'),
      cancelOnError: false,
    );
  }

  void _stopMeasurement() {
    final duration = DateTime.now().difference(_measStartTime!);
    _sub?.cancel();
    setState(() {
      _measuring = false;
      _status = '측정 종료';
    });
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SummaryPage(
        cvList: _cvList,
        hrList: _hrList,
        vrList: _vrList,
        cvCount: _cvExceed,
        hrCount: _hrExceed,
        vrCount: _vrExceed,
        duration: duration,
      ),
    ));
  }

  void _onData(Uint8List chunk) {
    final str = utf8.decode(chunk, allowMalformed: true);
    for (var line in str.split(RegExp(r'[\r\n]+'))) {
      if (line.isEmpty) continue;
      final p = line.trim().split(',');
      if (p.length < 3) continue;
      final t  = double.tryParse(p[0]);
      final af = double.tryParse(p[1]);
      final ad = double.tryParse(p[2]);
      if (t == null || af == null || ad == null) continue;
      _processSample(af, ad, t);
    }
  }

  void _processSample(double af, double ad, double timestamp) {
    _tBuf.add(timestamp);
    if (_tBuf.length  > FS) _tBuf.removeFirst();
    _ayBuf.add(af);
    if (_ayBuf.length > FS) _ayBuf.removeFirst();
    _azBuf.add(ad);
    if (_azBuf.length > FS) _azBuf.removeFirst();

    if (_tBuf.length == FS) _computeGait();
  }

  void _computeGait() {
    final timesMs = _tBuf.toList();
    final ay = _ayBuf.toList();
    final az = _azBuf.toList();

    final meanAy = ay.reduce((a, b) => a + b) / ay.length;
    final stdAy = sqrt(ay.map((v) => pow(v - meanAy, 2)).reduce((a, b) => a + b) / ay.length);
    final thresh = meanAy + stdAy * 0.5;

    List<int> peaks = [];
    for (int i = 1; i < ay.length - 1; i++) {
      if (ay[i] > thresh && ay[i] > ay[i - 1] && ay[i] > ay[i + 1]) {
        peaks.add(i);
      }
    }

    double cv = 0;
    if (peaks.length >= 3) {
      final peakTimes = peaks.map((i) => timesMs[i] / 1000.0).toList();
      final strides = [
        for (int j = 1; j < peakTimes.length; j++) peakTimes[j] - peakTimes[j - 1]
      ];
      final meanStride = strides.reduce((a, b) => a + b) / strides.length;
      final stdStride = sqrt(strides.map((d) => pow(d - meanStride, 2)).reduce((a, b) => a + b) / strides.length);
      cv = stdStride / meanStride * 100;
    }
    cv = cv.clamp(0.0, 10.0);

    final pos = ay.where((v) => v > 0).map((v) => v * v).fold(0.0, (a, b) => a + b);
    final neg = ay.where((v) => v < 0).map((v) => v * v).fold(0.0, (a, b) => a + b).abs();
    final hr = neg > 0 ? pos / neg : double.infinity;

    final vr2 = az.fold(0.0, (a, b) => a + b * b) / az.length;
    final vr = sqrt(vr2);

    // --- 이상 패턴 판별 기준 ---
    bool abCV = cv > 4.0;
    bool abHR = hr < 1.5;
    bool abVR = vr > _vrThreshold;

    _cvAbCnt = abCV ? _cvAbCnt + 1 : 0;
    _hrAbCnt = abHR ? _hrAbCnt + 1 : 0;
    _vrAbCnt = abVR ? _vrAbCnt + 1 : 0;

    _reasons.clear();
    if (_cvAbCnt >= WINDOW_CVHR) _reasons.add('Stride‐CV ↑');
    if (_hrAbCnt >= WINDOW_CVHR) _reasons.add('Harmonic Ratio ↓');
    if (_vrAbCnt >= WINDOW_VR) _reasons.add('Vertical RMS ↑');

    // --- 이상 패턴 카운트 (정상 → 이상 전이 시점에서만 증가) ---
    if (_cvAbCnt >= WINDOW_CVHR && !_cvWasAbnormal) _cvExceed++;
    if (_hrAbCnt >= WINDOW_CVHR && !_hrWasAbnormal) _hrExceed++;
    if (_vrAbCnt >= WINDOW_VR && !_vrWasAbnormal) _vrExceed++;

    _cvWasAbnormal = _cvAbCnt >= WINDOW_CVHR;
    _hrWasAbnormal = _hrAbCnt >= WINDOW_CVHR;
    _vrWasAbnormal = _vrAbCnt >= WINDOW_VR;

    _cvList.add(cv);
    _hrList.add(hr);
    _vrList.add(vr);

    // --- 이상 감지 시 알림 반복 시작 / 이상 없으면 중단 ---
    final hasAbnormal = _reasons.isNotEmpty;
    final message = _reasons.map((r) => _reasonText[r]).join(', ');

    if (hasAbnormal) {
      _startAlertLoop(message);  // 🔔 TTS or Push 알림 시작
    } else {
      _stopAlertLoop();          // ✅ 이상 종료 시 알림 중단
    }

    setState(() {});
  }

  void _startAlertLoop(String message) {
    if (_alerting) return;
    _alerting = true;

    _alertTimer = Timer.periodic(Duration(seconds: 7), (_) {
      final isForeground = SchedulerBinding.instance.lifecycleState == AppLifecycleState.resumed;
      alertUser(message, isForeground: isForeground && _ttsEnabled);
    });
  }

  void _stopAlertLoop() {
    _alertTimer?.cancel();
    _alerting = false;
  }


  Widget _buildMainStatusCard() {
    return Card(
      elevation: 3,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _connected
                  ? (_measuring ? Icons.directions_walk_rounded : Icons.bluetooth_connected)
                  : Icons.bluetooth_disabled_rounded,
              color: _measuring ? Colors.teal : Colors.blueGrey,
              size: 46,
            ),
            const SizedBox(height: 10),
            Text(
              _status,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              child: !_measuring
                  ? const SizedBox(height: 32)
                  : _reasons.isEmpty
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  Text('정상 보행 중입니다',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700])),
                ],
              )
                  : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.red, size: 28),
                      const SizedBox(width: 8),
                      Text('이상 보행 감지!',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (var r in _reasons)
                    Text(
                      _reasonText[r]!,
                      style: TextStyle(fontSize: 14, color: Colors.red[600]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(_connected
                ? Icons.bluetooth_disabled_rounded
                : Icons.bluetooth_connected_rounded),
            label: Text(_connected ? '연결 해제' : '블루투스 연결'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              backgroundColor: _connected ? Colors.red[100] : Colors.teal,
              foregroundColor: _connected ? Colors.red[700] : Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _connected ? _disconnect : _connect,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(_measuring ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(_measuring ? '측정 중지' : '측정 시작'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              backgroundColor: _measuring ? Colors.red : Colors.teal[600],
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _measuring ? _stopMeasurement : _startMeasurement,
          ),
        ),
      ],
    );
  }
  Widget _buildTtsToggleButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.volume_up, color: _ttsEnabled ? Colors.teal : Colors.grey),
          const SizedBox(width: 8),
          Text(_ttsEnabled ? "음성 안내 켜짐" : "음성 안내 꺼짐"),
          const SizedBox(width: 12),
          Switch(
            value: _ttsEnabled,
            onChanged: (val) => setState(() => _ttsEnabled = val),
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }
  Widget _buildTestButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.record_voice_over),
          label: const Text("🔊 TTS"),
          onPressed: () {
            alertUser("이상 보행 감지", isForeground: true, voiceEnabled: _ttsEnabled);
          },

        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.notifications_active),
          label: const Text("📨 푸시 알림 "),
          onPressed: () async {
            await Future.delayed(Duration(seconds: 10));
            alertUser("이상 보행 패턴이 감지되었습니다. 바르게 걸으십시오.", isForeground: false);
          },
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.97),
      appBar: AppBar(
        title: const Text('헬스케어 걸음 모니터', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            _buildMainStatusCard(),
            _buildMainButtons(),
            _buildTtsToggleButton(),
            const SizedBox(height: 20),
            _buildTestButtons(), // ← 여기에 추가!
            const SizedBox(height: 24),
            Card(
              color: Colors.teal[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '앱 사용법',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.teal[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. HC-06 기기 페어링 후 연결\n'
                          '2. 측정 시작 누르고 평소처럼 걸으세요\n'
                          '3. 보행 패턴이 정상/이상 여부 실시간 표시',
                      style: TextStyle(fontSize: 13, color: Colors.teal[900]),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class SummaryPage extends StatelessWidget {
  final List<double> cvList, hrList, vrList;
  final int cvCount, hrCount, vrCount;
  final Duration duration;

  const SummaryPage({
    super.key,
    required this.cvList,
    required this.hrList,
    required this.vrList,
    required this.cvCount,
    required this.hrCount,
    required this.vrCount,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    double avg(List<double> L) =>
        L.isEmpty ? 0 : L.reduce((a, b) => a + b) / L.length;
    double minv(List<double> L) =>
        L.isEmpty ? 0 : L.reduce((a, b) => a < b ? a : b);

    int total = cvList.length;
    double stability = total == 0
        ? 100
        : ((total - (cvCount + hrCount + vrCount)) / total * 100);

    final totalSec = duration.inMilliseconds / 1000.0;
    final dt = cvList.length > 1 ? totalSec / (cvList.length - 1) : 0.0;

    // SummaryPage에서도 임계선 수정 (위험 감지 완화)
    const cvThreshold = 4.0;
    const hrThreshold = 1.5;
    const vrThreshold = 2.2;
    const refRatio = 0.8;
    final maxY = [cvThreshold, hrThreshold, vrThreshold].reduce(max) / refRatio;
    const xInterval = 2.0;

    Widget _statRow({
      required IconData icon,
      required String title,
      required String desc,
      required String value,
      Color? color,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: color ?? Colors.teal[700],
                      )),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('측정 요약 리포트'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 2,
              color: Colors.teal[25],
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '측정 시간  ⏱️  ${totalSec.toStringAsFixed(1)}초',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal[800]),
                    ),
                    const Divider(height: 24, thickness: 1.1),
                    _statRow(
                      icon: Icons.timeline_rounded,
                      title: '걸음 변동성 (Stride-CV)',
                      desc: '높을수록 걸음 박자가 불규칙합니다.',
                      value: '평균: ${avg(cvList).toStringAsFixed(1)}%   '
                          '최대: ${cvList.isEmpty ? 0.0 : cvList.reduce(max).toStringAsFixed(1)}%   '
                          '위험: $cvCount회',
                      color: Colors.red,
                    ),
                    _statRow(
                      icon: FontAwesomeIcons.arrowsLeftRight,
                      title: '대칭성 (Harmonic Ratio)',
                      desc: '낮을수록 걸음이 좌우 균형이 안 맞습니다.',
                      value: '평균: ${avg(hrList).toStringAsFixed(2)}   '
                          '최저: ${minv(hrList).toStringAsFixed(2)}   '
                          '위험: $hrCount회',
                      color: Colors.green,
                    ),
                    _statRow(
                      icon: FontAwesomeIcons.arrowDownLong,
                      title: '수직 충격 (Vertical RMS)',
                      desc: '높을수록 착지 충격이 강합니다.',
                      value: '평균: ${avg(vrList).toStringAsFixed(2)} m/s²   '
                          '최대: ${vrList.isEmpty ? 0.0 : vrList.reduce(max).toStringAsFixed(2)} m/s²   '
                          '위험: $vrCount회',
                      color: Colors.blue,
                    ),
                    const Divider(height: 28, thickness: 1.2),
                    Text(
                      '안정 보행 비율',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          stability > 90
                              ? Icons.emoji_events_rounded
                              : Icons.info_outline_rounded,
                          color: stability > 90
                              ? Colors.teal
                              : Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text('${stability.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: stability > 90
                                  ? Colors.teal[700]
                                  : Colors.orange[800],
                            )),
                        const SizedBox(width: 8),
                        Text(
                          stability > 90 ? '매우 좋음' : '안정성 향상 필요',
                          style: TextStyle(
                            fontSize: 15,
                            color: stability > 90 ? Colors.teal : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '보행 데이터 그래프',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700]),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 220,
                      child: SfCartesianChart(
                        primaryXAxis: NumericAxis(
                          title: AxisTitle(text: '시간 (초)'),
                          minimum: 0,
                          maximum: totalSec,
                          interval: xInterval,
                        ),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                          minimum: 0,
                          maximum: maxY,
                        ),
                        plotAreaBorderWidth: 1.2,
                        plotAreaBorderColor: Colors.teal[300],
                        annotations: <CartesianChartAnnotation>[
                          CartesianChartAnnotation(
                            widget: const Text('CV 4.0%', style: TextStyle(color: Colors.red, fontSize: 12)),
                            coordinateUnit: CoordinateUnit.point,
                            x: 0,
                            y: cvThreshold,
                          ),
                          CartesianChartAnnotation(
                            widget: const Text('HR 1.5', style: TextStyle(color: Colors.green, fontSize: 12)),
                            coordinateUnit: CoordinateUnit.point,
                            x: 0,
                            y: hrThreshold,
                          ),
                          CartesianChartAnnotation(
                            widget: const Text('VR 2.2', style: TextStyle(color: Colors.blue, fontSize: 12)),
                            coordinateUnit: CoordinateUnit.point,
                            x: 0,
                            y: vrThreshold,
                          ),
                        ],
                        series: <CartesianSeries>[
                          LineSeries<double, double>(
                            dataSource: cvList,
                            xValueMapper: (value, index) => index * dt,
                            yValueMapper: (value, index) => value,
                            name: 'CV',
                            color: Colors.red,
                            width: 2,
                            markerSettings: const MarkerSettings(isVisible: false),
                          ),
                          LineSeries<double, double>(
                            dataSource: hrList,
                            xValueMapper: (value, index) => index * dt,
                            yValueMapper: (value, index) => value,
                            name: 'HR',
                            color: Colors.green,
                            width: 2,
                            markerSettings: const MarkerSettings(isVisible: false),
                          ),
                          LineSeries<double, double>(
                            dataSource: vrList,
                            xValueMapper: (value, index) => index * dt,
                            yValueMapper: (value, index) => value,
                            name: 'VR',
                            color: Colors.blue,
                            width: 2,
                            markerSettings: const MarkerSettings(isVisible: false),
                          ),
                        ],
                        legend: Legend(isVisible: true, position: LegendPosition.bottom),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 2, color: Colors.red),
                        const SizedBox(width: 6),
                        const Text('CV'),
                        const SizedBox(width: 18),
                        Container(width: 24, height: 2, color: Colors.green),
                        const SizedBox(width: 6),
                        const Text('HR'),
                        const SizedBox(width: 18),
                        Container(width: 24, height: 2, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('VR'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              'Tip: 평소보다 위험 알림이 많다면\n보행 습관 개선을 시도해 보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.teal[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('처음 화면으로'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
