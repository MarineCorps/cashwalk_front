import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:http_parser/http_parser.dart';

class CommunityService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/community';

  // ────────────────────────────────
  // 📌 게시글 작성 / 조회 / 삭제
  // ────────────────────────────────

  /// ✅ 게시글 작성 (multipart/form-data + JSON 구조)
  /// ✅ 게시글 작성 API (multipart/form-data + JSON 포함)
  static Future<void> createPost({
    required String title,
    required String content,
    required String boardType,
    required String postCategory,
    XFile? image,
  }) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('$baseUrl/posts');

    // ✅ MultipartRequest 생성
    final request = http.MultipartRequest('POST', uri);

    // ✅ Authorization 헤더 추가
    request.headers['Authorization'] = 'Bearer $jwt';

    // ✅ JSON 본문을 'post' 파트에 추가 (application/json 명시)
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

    // ✅ 이미지가 있다면 파일 파트로 추가
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('imageFile', image.path));
    }

    // ✅ 요청 전송 및 응답 확인
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('게시글 작성 실패 (${response.statusCode})\n${response.body}');
    }
  }

  /// ✅ 게시글 상세 조회
  static Future<Map<String, dynamic>> fetchPostDetail(int postId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('$baseUrl/posts/$postId/detail');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('게시글 상세 조회 실패 (${response.statusCode})');
    }
  }

  /// ✅ 게시글 삭제
  static Future<void> deletePost(int postId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('$baseUrl/posts/$postId');

    final response = await http.delete(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode != 204) {
      throw Exception('게시글 삭제 실패 (${response.statusCode})\n${response.body}');
    }
  }

  /// ✅ 내가 쓴 게시글 목록 조회
  static Future<List<dynamic>> fetchMyPosts() async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('$baseUrl/myposts');

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

  /// ✅ 게시글 검색 (키워드, 정렬, 게시판/카테고리 필터 포함)
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

    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);

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

  /// ✅ 게시글에 좋아요 또는 비추천 토글 (type: 'like' or 'dislike')
  static Future<void> toggleReaction(int postId, String type) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('$baseUrl/posts/$postId/$type');

    final response = await http.post(uri, headers: {
      'Authorization': 'Bearer $jwt',
    });

    if (response.statusCode != 200) {
      throw Exception('게시글 $type 실패 (${response.statusCode})');
    }
  }

  /// ✅ 게시글의 좋아요 / 비추천 수 조회
  static Future<Map<String, int>> fetchReactions(int postId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('$baseUrl/posts/$postId/reactions');

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

  /// ✅ 게시글 북마크 토글
  static Future<String> toggleBookmark(int postId) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('$baseUrl/posts/$postId/bookmark');

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

  /// ✅ 북마크한 게시글 목록 조회
  static Future<List<dynamic>> fetchBookmarks() async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('$baseUrl/bookmarks/me');

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

  /// ✅ 게시글 신고 (POST + 신고 사유 코드)
  static Future<void> reportPost(int postId, String reasonCode) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('http://10.0.2.2:8080/api/report');

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

  /// ✅ 실시간 인기글 Top 10 조회
  static Future<List<Map<String, dynamic>>> fetchTopPopularPosts() async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: {
      'postCategory': 'BESTLIVE', // 실시간 인기글만 필터
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
