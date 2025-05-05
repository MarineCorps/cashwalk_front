import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class JwtStorage {
  static final _storage = FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _loginMethodKey = 'login_method'; // ✅ kakao or google

  /// JWT 토큰 저장
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// JWT 토큰 조회
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// JWT 토큰 삭제
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// JWT 내부에서 userId 파싱
  static Future<int?> getUserIdFromToken() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> decoded = json.decode(payload);
      return decoded['userId'];
    } catch (e) {
      print('❌ 토큰 디코딩 실패: $e');
      return null;
    }
  }

  /// 로그인 방식 저장 (kakao / google)
  static Future<void> saveLoginMethod(String method) async {
    await _storage.write(key: _loginMethodKey, value: method);
  }

  /// 로그인 방식 조회
  static Future<String?> getLoginMethod() async {
    return await _storage.read(key: _loginMethodKey);
  }

  /// 전체 초기화 (로그아웃 시 사용)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
