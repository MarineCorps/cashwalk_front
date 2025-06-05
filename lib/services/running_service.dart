import 'package:cashwalk/services/http_service.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RunningService {
  /// ✅ 러닝 기록 저장 (POST /api/running/record)
  static Future<dynamic> saveRunningRecord(Map<String, dynamic> data) async {
    String? token = await JwtStorage.getToken();
    if (token == null) throw Exception("JWT 토큰 없음");

    return await HttpService.postToServer(
      '/api/running/record',
      data,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// ✅ 러닝 기록 목록 조회 (GET /api/running/record)
  static Future<dynamic> fetchRunningRecordList() async {
    String? token = await JwtStorage.getToken();
    if (token == null) throw Exception("JWT 토큰 없음");

    return await HttpService.getFromServer(
      '/api/running/record',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// ✅ 러닝 기록 상세 조회 (GET /api/running/record/{id})
  static Future<dynamic> fetchRunningRecordDetail(int id) async {
    String? token = await JwtStorage.getToken();
    if (token == null) throw Exception("JWT 토큰 없음");

    return await HttpService.getFromServer(
      '/api/running/record/$id',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// ✅ 러닝 다이어리 수정 (PATCH /api/running/record/{id}/diary)
  static Future<dynamic> updateRunningDiary(int id, Map<String, dynamic> data) async {
    String? token = await JwtStorage.getToken();
    if (token == null) throw Exception("JWT 토큰 없음");

    final url = Uri.parse('${HttpService.baseUrl}/api/running/record/$id/diary');
    final http.Response response = await HttpService.patchToServer(
      url,
      token: token,
      body: data,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = utf8.decode(response.bodyBytes);
      return jsonDecode(decoded);
    } else {
      throw Exception('PATCH 실패: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  /// ✅ 러닝 기록 삭제 (DELETE /api/running/{id})
  static Future<void> deleteRunningRecord(int id) async {
    String? token = await JwtStorage.getToken();
    if (token == null) throw Exception("JWT 토큰 없음");

    final url = Uri.parse('${HttpService.baseUrl}/api/running/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('삭제 실패: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}
