import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/services/http_service.dart'; // ✅ 추가

class BlockedUser {
  final int id;
  final String nickname;

  BlockedUser({required this.id, required this.nickname});

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'],
      nickname: json['nickname'],
    );
  }
}

class BlockService {
  static const String basePath = '/api/users'; // ✅ baseUrl → basePath로 변경

  /// ✅ 유저 차단
  static Future<void> blockUser(int targetUserId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/block/$targetUserId');

    final response = await http.post(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode != 200) {
      throw Exception('차단 실패 (${response.statusCode})');
    }
  }

  /// ✅ 유저 차단 해제
  static Future<void> unblockUser(int targetUserId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/unblock/$targetUserId');

    final response = await http.post(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode != 200) {
      throw Exception('차단 해제 실패 (${response.statusCode})');
    }
  }

  /// ✅ 내가 차단한 유저 목록 조회
  static Future<List<BlockedUser>> fetchBlockedUsers() async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/blocked');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => BlockedUser.fromJson(e)).toList();
    } else {
      throw Exception('차단 목록 조회 실패 (${response.statusCode})');
    }
  }
}
