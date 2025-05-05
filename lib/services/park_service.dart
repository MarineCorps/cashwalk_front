import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/services/http_service.dart';
import 'package:cashwalk/models/park.dart'; // ✅ Park 모델 import

class ParkService {
  /// ✅ 근처 공원 정보 조회 (isRewardedToday 포함됨)
  static Future<List<Park>> fetchNearbyParks(double lat, double lng) async {
    print('[📍 nearby request] latitude: $lat, longitude: $lng');

    final token = await JwtStorage.getToken();

    final decoded = await HttpService.postToServer(
      '/api/parks/nearby',
      {
        'longitude': lng,
        'latitude': lat,
      },
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (decoded is List) {
      print('[📋 디코딩된 nearby parks 데이터] $decoded');
      return decoded.map((e) => Park.fromJson(e)).toList(); // ✅ Park 객체 변환
    } else {
      throw Exception('응답 형식이 리스트가 아닙니다.');
    }


  }

  /// ✅ 공원 포인트 적립 API 호출
  static Future<String> earnPoint(int parkId) async {
    final token = await JwtStorage.getToken();

    final decoded = await HttpService.postToServer(
      '/api/points/walk',
      {
        'parkId': parkId,
      },
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (decoded is Map) {
      return decoded['message'] ?? '포인트 적립 완료';
    } else {
      return '포인트 적립 완료';
    }
  }

  /// ✅ 월별 산책 보상 기록 조회 (스탬프 & 일자별 적립)
  static Future<Map<String, dynamic>?> fetchWalkRecord(int year, int month) async {
    final token = await JwtStorage.getToken();
    try {
      final decoded = await HttpService.getFromServer(
        '/api/points/walk-record?year=$year&month=$month',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      print('❌ 산책 기록 조회 실패: $e');
      return null;
    }
  }

  /// ✅ 오늘 적립한 공원 ID 리스트
  static Future<Set<int>> fetchTodayRewardedParkIds() async {
    final token = await JwtStorage.getToken();
    try {
      final decoded = await HttpService.getFromServer(
        '/api/points/nwalk-today',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return (decoded as List).map((e) => e as int).toSet();
    } catch (e) {
      print('❌ 오늘 적립 공원 조회 실패: $e');
      return {};
    }
  }

  /// ✅ 오늘 총 적립 횟수 조회
  static Future<int> fetchTodayNwalkCount() async {
    final token = await JwtStorage.getToken();
    try {
      final decoded = await HttpService.getFromServer(
        '/api/points/nwalk-count',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return decoded['count'] ?? 0;
    } catch (e) {
      print('❌ 오늘 적립 횟수 조회 실패: $e');
      return 0;
    }
  }

  /// ✅ 오늘 적립 안한 공원 판별
  static bool isRewardable(Park park) {
    return !park.isRewardedToday; // ✅ 모델 기반으로 접근
  }

  /// ✅ 두 지점 사이 거리 계산
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _degToRad(double deg) => deg * pi / 180;
}
