import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:cashwalk/services/park_service.dart';
import 'dart:async';
import 'package:cashwalk/models/park.dart';

class WalkTab extends StatefulWidget {
  const WalkTab({super.key});

  @override
  State<WalkTab> createState() => _WalkTabState();
}

class _WalkTabState extends State<WalkTab> {
  late NaverMapController _controller;
  final Location _locationService = Location();

  LocationData? _currentLocation;
  LocationData? _lastLocation;
  DateTime _lastUpdateTime = DateTime.now();

  List<Park> _nearbyParks = [];
  final Map<String, NMarker> _overlays = {}; // ✅ 깔끔하게 NMarker로 변경

  bool _mapReady = false;
  bool _bottomSheetShown = false;
  Park? _selectedPark;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bottomSheetShown = false;
  }

  Future<void> _initializeLocation() async {
    if (!await _requestPermission()) return;

    final loc = await _locationService.getLocation();
    _currentLocation = loc;
    _lastLocation = loc;
    _lastUpdateTime = DateTime.now();

    if (_mapReady) {
      await _loadData(loc.longitude!, loc.latitude!);
      _tryAutoBottomSheet();
    }

    _locationService.onLocationChanged.listen((locData) async {
      final now = DateTime.now();
      final moved = _lastLocation == null ||
          ParkService.calculateDistance(
            _lastLocation!.latitude!,
            _lastLocation!.longitude!,
            locData.latitude!,
            locData.longitude!,
          ) > 50;
      final timed = now.difference(_lastUpdateTime) > const Duration(seconds: 30);

      if (_mapReady && (moved || timed)) {
        _lastLocation = locData;
        _lastUpdateTime = now;
        await _loadData(locData.longitude!, locData.latitude!);
        _tryAutoBottomSheet();
      }
    });
  }

  Future<bool> _requestPermission() async {
    if (!await _locationService.serviceEnabled() && !await _locationService.requestService()) return false;
    var perm = await _locationService.hasPermission();
    if (perm == PermissionStatus.denied) {
      perm = await _locationService.requestPermission();
      if (perm != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future<void> _loadData(double lng, double lat) async {
    try {
      final parks = await ParkService.fetchNearbyParks(lat, lng); // ✅ List<Park> 반환
      if (!mounted) return;
      setState(() {
        _nearbyParks = parks; // ✅ 타입 일치 (List<Park>)
      });
      await _moveCamera(lat, lng);
      await _smartGenerateMarkers(parks); // ✅ _smartGenerateMarkers도 List<Park> 받음
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공원 정보를 불러오지 못했습니다.')),
        );
      }
    }
  }


  Future<void> _moveCamera(double lat, double lng) async {
    await _controller.updateCamera(
      NCameraUpdate.fromCameraPosition(NCameraPosition(target: NLatLng(lat, lng), zoom: 16)),
    );
  }

  Future<void> _smartGenerateMarkers(List<Park> parks) async {
    final updatedIds = <String>{};

    for (final park in parks) {
      final id = 'park_${park.id}';
      final rewarded = park.isRewardedToday;
      final expectedIconPath = rewarded ? 'assets/images/green_tree.png' : 'assets/images/award_tree.png';

      final existingMarker = _overlays[id];

      if (existingMarker == null) {
        // 🔵 마커가 아예 없으면 새로 생성
        await _addNewMarker(id, park, expectedIconPath);
      } else {
        // 🔵 마커는 있는데 rewarded 상태가 다르면 교체
        await _controller.deleteOverlay(existingMarker as NOverlayInfo);
        _overlays.remove(id);
        await _addNewMarker(id, park, expectedIconPath);
      }

      updatedIds.add(id);
    }

    // 🔵 서버 응답에 없는 마커는 삭제
    final toDelete = _overlays.keys.toSet().difference(updatedIds);
    for (final id in toDelete) {
      await _controller.deleteOverlay(_overlays[id]! as NOverlayInfo);
      _overlays.remove(id);
    }
  }

  Future<void> _addNewMarker(String id, Park park, String iconPath) async {
    final marker = NMarker(
      id: id,
      position: NLatLng(park.latitude, park.longitude),
      icon: await NOverlayImage.fromAssetImage(iconPath),
      size: const Size(32, 32),
    );
    marker.setOnTapListener((_) {
      setState(() => _selectedPark = park);
      _sheetController.animateTo(0.35, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });

    await _controller.addOverlay(marker);
    _overlays[id] = marker;
  }



  void _tryAutoBottomSheet() {
    if (!_bottomSheetShown && _nearbyParks.isNotEmpty) {
      _bottomSheetShown = true; // ✅ 무조건 한번은 띄우게 한다.

      final unrewarded = _nearbyParks.where((p) => !p.isRewardedToday).toList();
      Park nearest;

      if (unrewarded.isNotEmpty) {
        unrewarded.sort((a, b) => a.distance.compareTo(b.distance));
        nearest = unrewarded.first;
      } else {
        _nearbyParks.sort((a, b) => a.distance.compareTo(b.distance));
        nearest = _nearbyParks.first;
      }

      setState(() => _selectedPark = nearest);
      print('✅ 선택된 park: ${_selectedPark?.parkName} (isRewardedToday: ${_selectedPark?.isRewardedToday})');

      _sheetController.animateTo(0.35, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }


  Future<void> _earnPoint(int parkId) async {
    try {
      await ParkService.earnPoint(parkId);
      if (!mounted) return;

      final id = 'park_$parkId';
      final index = _nearbyParks.indexWhere((p) => p.id == parkId);

      if (index != -1) {
        // ✅ 리스트 안에서도 copyWith로 갱신
        final updatedPark = _nearbyParks[index].copyWith(isRewardedToday: true);
        _nearbyParks[index] = updatedPark;
        await _addNewMarker(id, updatedPark, 'assets/images/green_tree.png');
      }

      if (_selectedPark != null && _selectedPark!.id == parkId) {
        setState(() {
          _selectedPark = _selectedPark!.copyWith(isRewardedToday: true);
        });
      }

      _showPopupAndClose(); // ✅ 팝업과 바텀시트 닫기
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('포인트 적립에 실패했습니다.')),
        );
      }
    }
  }

  void _showPopupAndClose() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/coin_reward.png', height: 80),
              const SizedBox(height: 20),
              const Text('10캐시 적립 완료!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('🎉 축하합니다!', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ✅ 팝업만 닫기
                },

                child: const Text('확인'),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHintSheet(ScrollController ctrl) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
    child: ListView(
      controller: ctrl,
      padding: const EdgeInsets.all(16),
      children: const [
        Center(
          child: SizedBox(width: 40, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(10))))),
        ),
        SizedBox(height: 12),
        Text('🏃‍♂️ 지도를 터치해서 적립 가능한 공원을 확인하세요!', style: TextStyle(fontSize: 16)),
      ],
    ),
  );

  Widget _buildParkInfoSheet(Park park, ScrollController ctrl) {
    final dist = park.distance;
    final steps = (dist / 0.8).round();
    final kcal = (steps * 0.035).round();
    final near = dist <= 250;
    final rewarded = park.isRewardedToday;
    final count = _nearbyParks.where((p) => !p.isRewardedToday).length;

    if (near && !rewarded) {
      return _buildRewardableSheet(park, ctrl, dist, steps, kcal, count);
    } else {
      return _buildAlreadyRewardedSheet(park, ctrl, dist, steps, kcal, count);
    }
  }

  Widget _buildRewardableSheet(Park park, ScrollController ctrl, num dist, int steps, int kcal, int count) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: ListView(
        controller: ctrl,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          const Text(
            '장소에 도착했어요!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '10캐시를 받아보세요.',
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfff6f6f6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.indigo),
                const SizedBox(width: 6),
                Text(
                  park.parkName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _earnPoint(park.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('적립하기', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyRewardedSheet(Park park, ScrollController ctrl, num dist, int steps, int kcal, int count) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: ListView(
        controller: ctrl,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '산책해서 10캐시 적립 받기',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfff6f6f6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.indigo),
                const SizedBox(width: 6),
                Text(
                  park.parkName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('📍 적립 가능한 공원 수 : $count개'),
          const SizedBox(height: 6),
          Text('📌 현재위치에서 $steps걸음 · ${dist.toInt()}m · ${kcal}kcal 소모'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: NaverMap(
              onMapReady: (ctrl) async {
                _controller = ctrl;
                _mapReady = true;
                if (_currentLocation != null) {
                  await _loadData(_currentLocation!.longitude!, _currentLocation!.latitude!);
                  _tryAutoBottomSheet();
                }
              },
              options: const NaverMapViewOptions(initialCameraPosition: NCameraPosition(target: NLatLng(37.2676, 127.1531), zoom: 16), scrollGesturesEnable: true, zoomGesturesEnable: true),
            ),
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.12,
            minChildSize: 0.08,
            maxChildSize: 0.35,
            builder: (context, scrollCtrl) {
              return _selectedPark == null ? _buildHintSheet(scrollCtrl) : _buildParkInfoSheet(_selectedPark!, scrollCtrl);
            },
          ),
        ],
      ),
    );
  }
}
