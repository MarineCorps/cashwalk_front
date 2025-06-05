import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  // ✅ 현재 환경이 로컬(에뮬레이터)인지 여부
  static const bool isLocal = false; //로컬이면 true

  // ✅ baseUrl 자동 분기
  static final String baseUrl = isLocal
      ? 'http://10.0.2.2:8080' // 로컬 개발용 (에뮬레이터에서 PC 서버 접속)
      : 'http://192.168.35.252:8080'; // apk전용

  static void debugBaseUrl() {
    print('[🌐 현재 baseUrl] $baseUrl');
  }
  // ✅ GET 요청
  static Future<dynamic> getFromServer(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  // ✅ POST 요청
  static Future<dynamic> postToServer(
      String endpoint,
      dynamic body, {
        Map<String, String>? headers,
        bool decode = true,
      }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: body is String ? body : jsonEncode(body),
    );

    // ✅ 응답 디버깅 로그
    print('[📥 응답 바이트] ${response.bodyBytes}');
    print('[📥 디코딩 후 응답] ${utf8.decode(response.bodyBytes)}');

    return _handleResponse(response);
  }

  // ✅ DELETE 요청
  static Future<dynamic> deleteFromServer(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url, headers: headers);
    return _handleResponse(response);
  }

  // ✅ 공통 응답 핸들링
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = utf8.decode(response.bodyBytes);
      return jsonDecode(decoded);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
  /// ✅ PATCH 요청 전송 메서드 (Bearer 토큰 포함)
  static Future<http.Response> patchToServer(
      Uri url, {
        required String token,
        required Map<String, dynamic> body,
      }) async {
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print('❌ PATCH 요청 실패: $e');
      rethrow;
    }
  }



}
