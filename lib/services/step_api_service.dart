import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/services/http_service.dart';
import 'package:cashwalk/models/step_stat.dart';
import 'package:intl/intl.dart';
class StepApiService {
  /// ✅ 서버에 걸음 수 저장
  static Future<void> reportSteps(int stepCount) async {
    final token = await JwtStorage.getToken();
    final response = await HttpService.postToServer(
      '/api/steps/report',
      {'steps': stepCount},
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response == null) {
      print('❌ 걸음 수 저장 실패');
    }
  }

  /// ✅ 오늘 걸음 수 및 포인트 조회
  static Future<Map<String, dynamic>?> fetchTodaySteps() async {
    final token = await JwtStorage.getToken();
    try {
      return await HttpService.getFromServer(
        '/api/steps/today',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('❌ 오늘 걸음 수 조회 실패: $e');
      return null;
    }
  }

  /// ✅ 포인트 1 적립 요청
  static Future<bool> claimPoint() async {
    final token = await JwtStorage.getToken();
    try {
      await HttpService.postToServer(
        '/api/steps/claim',
        null,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('✅ 서버에 포인트 1 적립 완료');
      return true;
    } catch (e) {
      print('❌ 포인트 적립 실패: $e');
      return false;
    }
  }

  /// ✅ 오늘 총 적립 횟수 조회
  static Future<int> fetchTodayNwalkCount() async {
    final token = await JwtStorage.getToken();
    try {
      final data = await HttpService.getFromServer(
        '/api/points/nwalk-count',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return data['count'];
    } catch (e) {
      print('❌ 오늘 적립 횟수 조회 실패: $e');
      return 0;
    }
  }

  static Future<List<StepStat>> fetchStepStats(String range, DateTime date) async {
    final token = await JwtStorage.getToken();

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await HttpService.getFromServer(
        '/api/steps/stats?range=$range&date=$formattedDate',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('📥 서버 응답: $response');

      if (response == null) {
        print('❌ 서버 응답 null');
        return [];
      }

      if (response is List) {
        final original = response.map((json) => StepStat.fromJson(json)).toList();
        return _fillMissingData(original, range, date); // ✅ 받아오자마자 빈 데이터 채우기
      } else {
        print('❌ 서버 응답 형식 이상: $response');
        return [];
      }
    } catch (e) {
      print('❌ 걸음 수 통계 조회 실패: $e');
      return [];
    }
  }

  /// ✅ 날짜 빠진거 채워주는 함수
  static List<StepStat> _fillMissingData(List<StepStat> original, String range, DateTime baseDate) {
    if (range == 'daily') {
      Map<int, StepStat> map = {for (var s in original) int.parse(DateFormat('H').format(s.date)): s};
      return List.generate(24, (h) {
        return map[h] ?? StepStat(date: DateTime(baseDate.year, baseDate.month, baseDate.day, h), steps: 0);
      });
    } else if (range == 'weekly') {
      final start = baseDate.subtract(Duration(days: baseDate.weekday - 1));
      Map<String, StepStat> map = {for (var s in original) DateFormat('yyyy-MM-dd').format(s.date): s};
      return List.generate(7, (i) {
        final d = start.add(Duration(days: i));
        return map[DateFormat('yyyy-MM-dd').format(d)] ?? StepStat(date: d, steps: 0);
      });
    } else {
      final start = DateTime(baseDate.year, baseDate.month, 1);
      final daysInMonth = DateTime(baseDate.year, baseDate.month + 1, 0).day;
      Map<String, StepStat> map = {for (var s in original) DateFormat('yyyy-MM-dd').format(s.date): s};
      return List.generate(daysInMonth, (i) {
        final d = start.add(Duration(days: i));
        return map[DateFormat('yyyy-MM-dd').format(d)] ?? StepStat(date: d, steps: 0);
      });
    }
  }

}
