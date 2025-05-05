import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:math';
import 'summary_page.dart';

class FreeRunning extends StatefulWidget {
  final bool isUnlimited;
  final bool isDistanceMode;
  final double distanceGoal;
  final Duration timeGoal;

  const FreeRunning({
    super.key,
    required this.isUnlimited,
    required this.isDistanceMode,
    this.distanceGoal = 0.0,
    this.timeGoal = Duration.zero,
  });

  @override
  State<FreeRunning> createState() => _FreeRunningState();
}

class _FreeRunningState extends State<FreeRunning> {
  bool isMapMode = false;
  bool isPaused = false;

  double distance = 0.0; // km
  Duration elapsedTime = Duration.zero;
  Timer? _timer;

  late Location _location;
  late StreamSubscription<LocationData> _locationSubscription;
  List<NLatLng> _path = [];

  NaverMapController? _naverMapController;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _startRunning();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationSubscription.cancel();
    super.dispose();
  }

  void _startRunning() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused) {
        setState(() {
          elapsedTime += const Duration(seconds: 1);
          _checkGoalReached();
        });
      }
    });
  }

  void _pauseRunning() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _startLocationUpdates() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final currentLatLng = NLatLng(locationData.latitude!, locationData.longitude!);

        setState(() {
          if (_path.isNotEmpty) {
            distance += _calculateDistance(
              _path.last.latitude,
              _path.last.longitude,
              currentLatLng.latitude,
              currentLatLng.longitude,
            );
          }
          _path.add(currentLatLng);

          _naverMapController?.updateCamera(
            NCameraUpdate.withParams(
              target: currentLatLng,
              zoom: 16,
            ),
          );

          if (_naverMapController != null && _path.length >= 2) {
            _naverMapController!.clearOverlays();
            _naverMapController!.addOverlay(NPolylineOverlay(
              id: 'running_path',
              coords: _path,
              color: Colors.red,
              width: 4,
            ));
          }
        });
      }
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371e3; // meters
    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLon = (lon2 - lon1) * pi / 180;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c / 1000; // meters -> km
  }

  void _checkGoalReached() {
    if (!widget.isUnlimited) {
      if (widget.isDistanceMode) {
        double remainingDistance = (widget.distanceGoal - distance).clamp(0, widget.distanceGoal);
        if (remainingDistance <= 0) {
          _finishRunning();
        }
      } else {
        Duration remainingTime = widget.timeGoal - elapsedTime;
        if (remainingTime <= Duration.zero) {
          _finishRunning();
        }
      }
    }
  }
  double _calculateCalories() {
    return distance * 60;
  }

  double _calculatePace() {
    if (elapsedTime.inSeconds == 0 || distance == 0) return 0.0;
    return (elapsedTime.inSeconds / 60) / distance;
  }
  void _finishRunning() {
    _timer?.cancel();
    _locationSubscription.cancel();

    final now = DateTime.now();
    final start = now.subtract(elapsedTime);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SummaryPage(
              distance: distance,
              duration: elapsedTime,
              calories: _calculateCalories(),
              pace: _calculatePace(),
              path: _path,
              startTime: start,
              endTime: now,
              isUnlimited: widget.isUnlimited,
              isDistanceMode: widget.isDistanceMode,
            ),
      ),
    );
  }




  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _switchToMapMode() {
    setState(() {
      isMapMode = true;
    });
  }

  void _exitMapMode() {
    setState(() {
      isMapMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isMapMode ? _buildMapRunningScreen() : _buildNormalRunningScreen();
  }

  Widget _buildNormalRunningScreen() {
    final mainValue = widget.isUnlimited
        ? (widget.isDistanceMode
        ? distance
        : elapsedTime)
        : (widget.isDistanceMode
        ? (widget.distanceGoal - distance).clamp(0, widget.distanceGoal)
        : (widget.timeGoal - elapsedTime));

    final subValue = widget.isDistanceMode
        ? _formatDuration(elapsedTime)
        : '${distance.toStringAsFixed(2)} km';

    return Scaffold(
      appBar: AppBar(
        title: const Text('자유 러닝', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isDistanceMode
                ? '${(mainValue as double).toStringAsFixed(2)} km'
                : _formatDuration(mainValue as Duration),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    widget.isDistanceMode ? _formatDuration(elapsedTime) : '${distance.toStringAsFixed(2)} km',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.isDistanceMode ? '소요 시간' : '이동 거리'),
                ],
              ),
              Column(
                children: [
                  Text('${_calculateCalories().toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('소비 칼로리'),
                ],
              ),
              Column(
                children: [
                  Text('${_calculatePace().toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('평균 페이스'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _pauseRunning,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepOrange,
              ),
              alignment: Alignment.center,
              child: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _switchToMapMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('지도 보기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapRunningScreen() {
    final mainValue = widget.isUnlimited
        ? (widget.isDistanceMode
        ? distance
        : elapsedTime)
        : (widget.isDistanceMode
        ? (widget.distanceGoal - distance).clamp(0, widget.distanceGoal)
        : (widget.timeGoal - elapsedTime));

    final subValue = widget.isDistanceMode
        ? _formatDuration(elapsedTime)
        : '${distance.toStringAsFixed(2)} km';

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            onMapReady: (controller) {
              _naverMapController = controller;
            },
            options: const NaverMapViewOptions(
              locationButtonEnable: true,
              mapType: NMapType.basic,
              activeLayerGroups: [NLayerGroup.building],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.1,
            maxChildSize: 0.35,
            builder: (context, scrollController) {
              return Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 28), // 핸들바 높이만큼 여백
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            // 🧡 러닝 종류
                            Center(
                              child: Text(
                                widget.isUnlimited
                                    ? (widget.isDistanceMode ? '거리 무제한 러닝' : '시간 무제한 러닝')
                                    : (widget.isDistanceMode ? '거리 목표 러닝' : '시간 목표 러닝'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // 🧡 메인 수치
                            Text(
                              widget.isDistanceMode
                                  ? '${(mainValue as double).toStringAsFixed(2)} km'
                                  : _formatDuration(mainValue as Duration),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),

                            // 🧡 하단 정보
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      widget.isDistanceMode
                                          ? _formatDuration(elapsedTime)
                                          : '${distance.toStringAsFixed(2)} km',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const Text('소요 시간'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('${_calculateCalories().toStringAsFixed(0)} kcal',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const Text('소비 칼로리'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('${_calculatePace().toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const Text('평균 페이스'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🧡 핸들바는 항상 위에 고정
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),


          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _pauseRunning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.deepOrange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isPaused ? '재개' : '일시 정지',
                      style: const TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _finishRunning,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('운동 종료', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: IconButton(
              onPressed: _exitMapMode,
              icon: const Icon(Icons.close, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}