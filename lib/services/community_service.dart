import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:cashwalk/services/http_service.dart'; // ✅ baseUrl import

class CommunityService {
  static const String basePath = '/api/community';

  // ────────────────────────────────
  // 📌 게시글 작성 / 조회 / 삭제
  // ────────────────────────────────

  static Future<void> createPost({
    required String title,
    required String content,
    required String boardType,
    required String postCategory,
    XFile? image,
  }) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/posts');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $jwt';

    request.files.add(http.MultipartFile.fromString(
      'post',
      jsonEncode({
        'title': title,
        'content': content,
        'boardType': boardType,
        'postCategory': postCategory,
      }),
      contentType: MediaType('application', 'json'),
    ));

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('imageFile', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('게시글 작성 실패 (${response.statusCode})\n${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchPostDetail(int postId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/posts/$postId/detail');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('게시글 상세 조회 실패 (${response.statusCode})');
    }
  }

  static Future<void> deletePost(int postId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/posts/$postId');

    final response = await http.delete(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode != 204) {
      throw Exception('게시글 삭제 실패 (${response.statusCode})\n${response.body}');
    }
  }

  static Future<List<dynamic>> fetchMyPosts() async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/myposts');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('내 게시글 조회 실패 (${response.statusCode})');
    }
  }

  // ────────────────────────────────
  // 🔍 게시글 검색 / 정렬
  // ────────────────────────────────

  static Future<List<Map<String, dynamic>>> searchPosts({
    String? keyword,
    String sort = 'latest',
    String? boardType,
    String? postCategory,
    int page = 0,
    int size = 10,
  }) async {
    final jwt = await JwtStorage.getToken();

    final queryParams = {
      'keyword': keyword ?? '',
      'sort': sort,
      'page': '$page',
      'size': '$size',
      if (boardType != null) 'boardType': boardType,
      if (postCategory != null) 'postCategory': postCategory,
    };

    final uri = Uri.parse('${HttpService.baseUrl}$basePath/search')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(json['content']);
    } else {
      throw Exception('게시글 검색 실패 (${response.statusCode})');
    }
  }

  // ────────────────────────────────
  // 👍 좋아요 / 비추천
  // ────────────────────────────────

  static Future<void> toggleReaction(int postId, String type) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/posts/$postId/$type');

    final response = await http.post(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode != 200) {
      throw Exception('게시글 $type 실패 (${response.statusCode})');
    }
  }

  static Future<Map<String, int>> fetchReactions(int postId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/posts/$postId/reactions');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return {
        'likeCount': json['likeCount'],
        'dislikeCount': json['dislikeCount'],
      };
    } else {
      throw Exception('반응 수 조회 실패 (${response.statusCode})');
    }
  }

  // ────────────────────────────────
  // 📌 북마크 기능
  // ────────────────────────────────

  static Future<String> toggleBookmark(int postId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/posts/$postId/bookmark');

    final response = await http.post(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['message'];
    } else {
      throw Exception('북마크 토글 실패 (${response.statusCode})');
    }
  }

  static Future<List<dynamic>> fetchBookmarks() async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/bookmarks/me');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('북마크 조회 실패 (${response.statusCode})');
    }
  }

  // ────────────────────────────────
  // 🚨 게시글 신고
  // ────────────────────────────────

  static Future<void> reportPost(int postId, String reasonCode) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}/api/report');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'targetId': postId,
        'type': 'POST',
        'reasonCode': reasonCode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('게시글 신고 실패 (${response.statusCode})\n${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTopPopularPosts() async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}$basePath/search').replace(queryParameters: {
      'postCategory': 'BESTLIVE',
      'page': '0',
      'size': '10',
    });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(json['content']);
    } else {
      throw Exception('실시간 인기글 조회 실패 (${response.statusCode})');
    }
  }
}
