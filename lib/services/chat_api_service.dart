import 'dart:convert';
import 'package:cashwalk/utils/font_service.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cashwalk/utils/env.dart'; // ✅ 추가

class ChatApiService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await JwtStorage.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<int> sendLuckyCash({required int receiverId, required String messageId}) async {
    final headers = await _authHeaders();
    final body = jsonEncode({'receiverId': receiverId, 'messageId': messageId});
    final response = await FontService.postJson('$httpBaseUrl/api/chat/lucky-cash/send', headers: headers, body: body);
    return response['roomId'];
  }

  static Future<int> redeemLuckyCash(String messageId) async {
    final headers = await _authHeaders();
    final body = jsonEncode({'messageId': messageId});
    final response = await FontService.postJson('$httpBaseUrl/api/chat/lucky-cash/redeem', headers: headers, body: body);
    return response['reward'];
  }

  static Future<List<Map<String, dynamic>>> getMessages(int roomId) async {
    final headers = await _authHeaders();
    final response = await FontService.getJson('$httpBaseUrl/api/chat/messages/$roomId', headers: headers);
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    } else {
      throw Exception('메시지 응답이 List가 아님: $response');
    }
  }

  static Future<void> markMessagesAsRead(int roomId) async {
    final headers = await _authHeaders();
    await FontService.postJson('$httpBaseUrl/api/chat/read/$roomId', headers: headers);
  }

  static Future<void> hideChatRoom(int roomId) async {
    final headers = await _authHeaders();
    await FontService.postJson('$httpBaseUrl/api/chat/hide/$roomId', headers: headers);
  }

  static Future<Map<String, dynamic>> startChat(int friendUserId) async {
    final headers = await _authHeaders();
    final body = jsonEncode({'friendUserId': friendUserId});
    final response = await http.post(
      Uri.parse('$httpBaseUrl/api/chat/start'), // ✅ 분기 적용
      headers: headers,
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('채팅방 열기 실패');
    }
    return json.decode(response.body);
  }

  static Future<String> uploadImage(String filePath) async {
    final token = await JwtStorage.getToken();
    final uri = Uri.parse('$httpBaseUrl/api/chat/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('이미지 업로드 실패');
    }
    final res = await response.stream.bytesToString();
    final jsonData = json.decode(res);
    return jsonData['fileUrl'];
  }

  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final token = await JwtStorage.getToken();
    return await FontService.getJson(
      '$httpBaseUrl/api/users/$userId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
