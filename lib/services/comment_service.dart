import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/services/http_service.dart';

class CommentService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/community/comments';

  /// ✅ 댓글 목록 조회
  static Future<List<dynamic>> fetchComments(int postId) async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('$baseUrl/post/$postId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('댓글 목록 조회 실패');
    }
  }

  /// ✅ 일반 댓글 작성 (parentId 없음)
  static Future<void> createComment(int postId, String content) async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('$baseUrl/post/$postId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('댓글 작성 실패');
    }
  }

  /// ✅ 대댓글 작성 (parentId 있음)
  static Future<void> createReply(int postId, String content, int parentId) async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('$baseUrl/post/$postId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'parentId': parentId, // ✅ 대댓글을 구분하기 위한 parentId
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('대댓글 작성 실패');
    }
  }


  /// ✅ 댓글 수정
  static Future<void> updateComment(int commentId, String content) async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('$baseUrl/$commentId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('댓글 수정 실패');
    }
  }

  /// ✅ 댓글 삭제
  static Future<void> deleteComment(int commentId) async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('$baseUrl/$commentId');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode != 200) {
      throw Exception('댓글 삭제 실패');
    }
  }

  /// ✅ 댓글 좋아요 / 비추천
  static Future<void> toggleCommentReaction(int commentId, String type) async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('$baseUrl/comment/$commentId/$type'); // type = like or dislike
    print('✅ 댓글 반응 요청: $url'); // ✅ 디버깅
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $jwt'},
    );
    print('📥 서버 응답 상태: ${response.statusCode}');
    print('📥 서버 응답 내용: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('댓글 $type 실패');
    }
  }

  /// ✅ 댓글 좋아요/비추천 수 조회
  static Future<Map<String, int>> fetchCommentReactions(int commentId) async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('$baseUrl/$commentId/reactions');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'likeCount': data['likeCount'] ?? 0,
        'dislikeCount': data['dislikeCount'] ?? 0,
      };
    } else {
      throw Exception('댓글 반응 수 조회 실패');
    }
  }

  /// ✅ 내가 쓴 댓글 목록 조회
  static Future<List<dynamic>> fetchMyComments() async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('http://10.0.2.2:8080/api/community/my-comments');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('내 댓글 조회 실패');
    }
  }

  /// ✅ 내가 단 댓글에 답글이 달린 목록 조회
  static Future<List<dynamic>> fetchMyRepliedComments() async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('http://10.0.2.2:8080/api/community/my-replied-comments');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('답글 달린 댓글 조회 실패');
    }
  }
  static Future<void> reportComment(int commentId, String reasonCode) async {
    final jwt = await JwtStorage.getToken();
    final url = Uri.parse('http://10.0.2.2:8080/api/report');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'targetId': commentId,
        'type': 'COMMENT',
        'reasonCode': reasonCode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('댓글 신고 실패');
    }
  }

}
