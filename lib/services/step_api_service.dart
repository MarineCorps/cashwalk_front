import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/services/http_service.dart';
import 'package:cashwalk/models/step_stat.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class StepApiService {
  /// ✅ 서버에 걸음 수 저장
  static Future<void> reportSteps(int stepCount) async {
    final token = await JwtStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('${HttpService.baseUrl}/api/steps/report'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'steps': stepCount}),
      );

      if (response.statusCode != 200) {
        print('❌ 걸음 수 저장 실패: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
    }
  }

  /// ✅ 오늘 걸음 수 및 포인트 조회
  static Future<Map<String, dynamic>?> fetchTodaySteps() async {
    final token = await JwtStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('${HttpService.baseUrl}/api/steps/today'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ 오늘 걸음 수 조회 실패: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      return null;
    }
  }

  /// ✅ 포인트 1 적립 요청 (디코딩 없음)
  static Future<bool> claimPoint() async {
    final token = await JwtStorage.getToken();
    try {
      final response = await http.post(
        Uri.parse('${HttpService.baseUrl}/api/steps/claim'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ 포인트 1 적립 완료');
        return true;
      } else {
        print('❌ 포인트 적립 실패: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      return false;
    }
  }

  /// ✅ 오늘 총 적립 횟수 조회
  static Future<int> fetchTodayNwalkCount() async {
    final token = await JwtStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('${HttpService.baseUrl}/api/points/nwalk-count'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'];
      } else {
        print('❌ 오늘 적립 횟수 조회 실패: ${response.statusCode} ${response.body}');
        return 0;
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      return 0;
    }
  }

  /// ✅ 걸음 수 통계 조회 (일간/주간/월간)
  static Future<List<StepStat>> fetchStepStats(String range, DateTime date) async {
    final token = await JwtStorage.getToken();
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.get(
        Uri.parse('${HttpService.baseUrl}/api/steps/stats?range=$range&date=$formattedDate'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final original = decoded.map((json) => StepStat.fromJson(json)).toList();
          return _fillMissingData(original, range, date);
        } else {
          print('❌ 서버 응답 형식 이상: $decoded');
          return [];
        }
      } else {
        print('❌ 걸음 수 통계 조회 실패: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      return [];
    }
  }

  /// ✅ 날짜 빠진 구간 채워주는 함수
  static List<StepStat> _fillMissingData(List<StepStat> original, String range, DateTime baseDate) {
    if (range == 'daily') {
      Map<int, StepStat> map = {
        for (var s in original) int.parse(DateFormat('H').format(s.date)): s
      };
      return List.generate(24, (h) {
        return map[h] ?? StepStat(date: DateTime(baseDate.year, baseDate.month, baseDate.day, h), steps: 0);
      });
    } else if (range == 'weekly') {
      final start = baseDate.subtract(Duration(days: baseDate.weekday - 1));
      Map<String, StepStat> map = {
        for (var s in original) DateFormat('yyyy-MM-dd').format(s.date): s
      };
      return List.generate(7, (i) {
        final d = start.add(Duration(days: i));
        return map[DateFormat('yyyy-MM-dd').format(d)] ?? StepStat(date: d, steps: 0);
      });
    } else {
      final start = DateTime(baseDate.year, baseDate.month, 1);
      final daysInMonth = DateTime(baseDate.year, baseDate.month + 1, 0).day;
      Map<String, StepStat> map = {
        for (var s in original) DateFormat('yyyy-MM-dd').format(s.date): s
      };
      return List.generate(daysInMonth, (i) {
        final d = start.add(Duration(days: i));
        return map[DateFormat('yyyy-MM-dd').format(d)] ?? StepStat(date: d, steps: 0);
      });
    }
  }
}
