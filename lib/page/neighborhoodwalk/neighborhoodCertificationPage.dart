import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cashwalk/services/certification_service.dart';
import 'package:cashwalk/models/certification_model.dart';

class NeighborhoodCertificationPage extends StatefulWidget {
  const NeighborhoodCertificationPage({super.key});

  @override
  State<NeighborhoodCertificationPage> createState() => _NeighborhoodCertificationPageState();
}

class _NeighborhoodCertificationPageState extends State<NeighborhoodCertificationPage> {
  final Location _locationService = Location();
  LocationData? _currentLocation;
  late NaverMapController _mapController;

  CertificationModel? _certificationInfo;
  String _currentAddress = '';
  bool _showMap = false;
  bool _isSelectingResidence = false; // true: 거주지 선택, false: 활동지 선택

  final String _clientId = 'by60fvdvnr';
  final String _clientSecret = 'oe27zhbVGrswwq9WFN82vmCLMqm9BHpkLXjjO5ia';

  @override
  void initState() {
    super.initState();
    _fetchCertificationInfo();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final location = await _locationService.getLocation();
    setState(() {
      _currentLocation = location;
    });

    if (_currentLocation != null) {
      await _fetchAddress(_currentLocation!.latitude!, _currentLocation!.longitude!);
    }
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    final url = Uri.parse('https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=$lng,$lat&output=json');

    final response = await http.get(
      url,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': _clientId,
        'X-NCP-APIGW-API-KEY': _clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final region = data['results'][0]['region'];
      setState(() {
        _currentAddress = '${region['area1']['name']} ${region['area2']['name']} ${region['area3']['name']}';
      });
    }
  }

  Future<void> _fetchCertificationInfo() async {
    try {
      final info = await CertificationService.getCertificationInfo();
      setState(() {
        _certificationInfo = info;
      });
    } catch (e) {
      print('인증 정보 조회 실패: $e');
    }
  }

  Future<void> _showCertificationDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('인증 진행 안내'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('인증을 진행하면, 30일 간 재인증이 불가합니다.'),
              const SizedBox(height: 8),
              const Text('인증을 진행하시겠습니까?'),
              const SizedBox(height: 16),
              Text('인증지역: $_currentAddress', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _certify();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _certify() async {
    await _initLocation();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (_isSelectingResidence) {
        await CertificationService.certifyResidence(_currentAddress, today);
      } else {
        await CertificationService.certifyActivity(_currentAddress, today);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 인증이 완료되었습니다.')),
      );
      setState(() {
        _showMap = false;
      });
      _fetchCertificationInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ 인증 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('동네 인증하기'),
        backgroundColor: Colors.amber,
      ),
      body: _showMap ? _buildMapView() : _buildCertificationListView(),
    );
  }

  Widget _buildCertificationListView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildCertificationTile('거주 지역', true, _certificationInfo?.residenceAddress, _certificationInfo?.residenceCertifiedAt),
          const SizedBox(height: 16),
          _buildCertificationTile('활동 지역', false, _certificationInfo?.activityAddress, _certificationInfo?.activityCertifiedAt),
          const Spacer(),
          const Text('확인해 주세요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('- 동네 인증은 등록 후 30일간 재인증이 불가합니다.'),
          const Text('- 동네 인증은 실제 거주지나 활동지에서 진행해 주세요.'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCertificationTile(String title, bool isResidence, String? address, String? certifiedAt) {
    return GestureDetector(
      onTap: () async {
        _isSelectingResidence = isResidence;
        await _initLocation();
        setState(() {
          _showMap = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                address != null
                    ? Text('$address\n${certifiedAt != null ? '${certifiedAt.replaceAll("-", ".")} 인증완료' : ''}', style: const TextStyle(color: Colors.blue))
                    : const Text('인증된 지역이 없습니다.', style: TextStyle(color: Colors.black)),
              ],
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        NaverMap(
          onMapReady: (controller) async {
            _mapController = controller;

            if (_currentLocation == null) {
              await _initLocation(); // ✅ 현재 위치 받아오기 (없으면 새로 가져옴)
            }

            if (_currentLocation != null) {
              _mapController.updateCamera(
                NCameraUpdate.scrollAndZoomTo(
                  target: NLatLng(
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!,
                  ),
                  zoom: 16,
                ),
              );

              await _fetchAddress(_currentLocation!.latitude!, _currentLocation!.longitude!); // ✅ 주소도 받아오기
            }
          },

          options: const NaverMapViewOptions(
            locationButtonEnable: true,
            consumeSymbolTapEvents: true,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentAddress.isNotEmpty ? '인증 지역: $_currentAddress' : '위치 정보를 불러오는 중...',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _currentAddress.isNotEmpty ? _showCertificationDialog : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentAddress.isNotEmpty ? Colors.amber : Colors.grey,
                  ),
                  child: const Text('우리 동네 인증하기', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),

        ),
      ],
    );
  }
}