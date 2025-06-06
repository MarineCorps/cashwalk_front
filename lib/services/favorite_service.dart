import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/services/http_service.dart'; // ✅ HttpService로 변경

class FavoriteService {
  static const String basePath = '/api/favorites'; // ✅ basePath만 따로 정의

  /// 즐겨찾기 전체 목록 조회 (BoardType + PostCategory 포함)
  static Future<List<String>> fetchFavorites() async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('${HttpService.baseUrl}$basePath/me');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(json);
    } else {
      throw Exception('❌ 즐겨찾기 목록 조회 실패: ${response.statusCode}');
    }
  }

  /// 즐겨찾기 추가
  static Future<void> addFavorite({String? boardType, String? postCategory}) async {
    final jwt = await JwtStorage.getToken();
    final query = boardType != null ? 'boardType=$boardType' : 'postCategory=$postCategory';
    final url = Uri.parse('${HttpService.baseUrl}$basePath?$query');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode != 200) {
      throw Exception('❌ 즐겨찾기 추가 실패: ${response.statusCode}');
    }
  }

  /// 즐겨찾기 제거
  static Future<void> removeFavorite({String? boardType, String? postCategory}) async {
    final jwt = await JwtStorage.getToken();
    final query = boardType != null ? 'boardType=$boardType' : 'postCategory=$postCategory';
    final url = Uri.parse('${HttpService.baseUrl}$basePath?$query');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode != 200) {
      throw Exception('❌ 즐겨찾기 제거 실패: ${response.statusCode}');
    }
  }
}
