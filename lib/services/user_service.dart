import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/services/http_service.dart';

/// ✅ 사용자 모델 (서버 기준)
class UserProfile {
  final String id;
  final String nickname;
  final String inviteCode;
  final String? profileImage;  // ✅ 필드명 수정됨!
  final int? height;
  final int? weight;
  final String? region;
  final String? gender;
  final String? birthDate;
  final int? points; // ✅ 필드명도 totalPoints 아님! points 맞음

  UserProfile({
    required this.id,
    required this.nickname,
    required this.inviteCode,
    this.profileImage,
    this.height,
    this.weight,
    this.region,
    this.gender,
    this.birthDate,
    this.points,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      nickname: json['nickname'] ?? '익명',
      inviteCode: json['inviteCode'] ?? 'UNKNOWN',
      profileImage: json['profileImage'], // ✅ 수정
      height: json['height'],
      weight: json['weight'],
      region: json['region'],
      gender: json['gender'],
      birthDate: json['birthDate'],
      points: json['points'], // ✅ 수정
    );
  }
}


/// ✅ 유저 관련 모든 기능을 통합 관리
class UserService {
  static UserProfile? _cachedUser;
  static String? _cachedKakaoProfileUrl;
  static String? _cachedKakaoUserId;

  /// ✅ 서버에서 프로필 가져오고 캐시
  static Future<UserProfile> fetchMyProfile() async {
    final token = await JwtStorage.getToken();
    final json = await HttpService.getFromServer(
      '/api/users/me',
      headers: {'Authorization': 'Bearer $token'},
    );
    _cachedUser = UserProfile.fromJson(json);
    return _cachedUser!;
  }

  /// ✅ 현재 캐시된 유저 (nullable)
  static UserProfile? get currentUser => _cachedUser;

  static String get nickname => _cachedUser?.nickname ?? '익명';
  static String get inviteCode => _cachedUser?.inviteCode ?? 'UNKNOWN';

  /// ✅ 서버/카카오/기본 프로필 이미지 우선순위 반환
  static Future<String> getProfileImageUrl() async {
    // 1️⃣ 서버 프로필 먼저
    if (_cachedUser?.profileImage != null) {
      return _cachedUser!.profileImage!;
    }

    // 2️⃣ 카카오 이미지 (로그인 유지 + 사용자 체크)
    try {
      final user = await UserApi.instance.me();
      final kakaoId = user.id.toString();

      if (_cachedKakaoUserId != kakaoId) {
        _cachedKakaoProfileUrl = null;
        _cachedKakaoUserId = kakaoId;
      }

      if (_cachedKakaoProfileUrl != null) {
        return _cachedKakaoProfileUrl!;
      }

      // 프로필 동의 필요
      if (user.kakaoAccount?.profileNeedsAgreement == true) {
        await UserApi.instance.loginWithNewScopes(['profile_image']);
        final updated = await UserApi.instance.me();
        _cachedKakaoProfileUrl = updated.kakaoAccount?.profile?.profileImageUrl;
      } else {
        _cachedKakaoProfileUrl = user.kakaoAccount?.profile?.profileImageUrl;
      }

      if (_cachedKakaoProfileUrl != null) {
        return _cachedKakaoProfileUrl!;
      }
    } catch (e) {
      print('❌ 카카오 이미지 실패: $e');
    }

    // 3️⃣ 기본 이미지
    return 'assets/images/woobin.png';
  }

  /// ✅ 포인트 조회 (서버에서만)
  static Future<int> fetchUserPoint() async {
    final token = await JwtStorage.getToken();
    final decoded = await HttpService.getFromServer(
      '/api/users/me',
      headers: {'Authorization': 'Bearer $token'},
    );
    return decoded['points'] ?? 0;
  }

  /// ✅ 필요 시 호출하여 캐시 초기화
  static void clearCache() {
    _cachedUser = null;
    _cachedKakaoProfileUrl = null;
    _cachedKakaoUserId = null;
  }


  static Future<void> updateProfileField(
      String token, {
        String? nickname,
        String? gender,
        String? birthDate,
        String? region,
        int? height,
        int? weight,
      }) async {
    final url = Uri.parse('${HttpService.baseUrl}/api/users/info');

    final body = <String, dynamic>{};
    if (nickname != null) body['nickname'] = nickname;
    if (gender != null) body['gender'] = gender;
    if (birthDate != null) body['birthDate'] = birthDate;
    if (region != null) body['region'] = region;
    if (height != null) body['height'] = height;
    if (weight != null) body['weight'] = weight;

    final response = await HttpService.patchToServer(url, token: token, body: body);

    if (response.statusCode != 200) {
      print('❌ 사용자 정보 업데이트 실패: ${response.statusCode}');
      throw Exception('업데이트 실패');
    }

    print('✅ 사용자 정보 업데이트 성공');
  }



}


