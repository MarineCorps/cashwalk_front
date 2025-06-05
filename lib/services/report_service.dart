import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/services/http_service.dart';

/// ✅ 신고 사유 ENUM
enum ReportReason {
  abuse,       // 욕설/비하 발언
  sexual,      // 음란성
  promotion,   // 홍보성/도배
  privacy,     // 개인정보 노출
  defamation,  // 특정인 비방
  etc,         // 기타
}

/// ✅ enum → 백엔드에서 요구하는 코드로 변환
String reportReasonToCode(ReportReason reason) {
  switch (reason) {
    case ReportReason.abuse: return 'ABUSE';
    case ReportReason.sexual: return 'SEXUAL';
    case ReportReason.promotion: return 'PROMOTION';
    case ReportReason.privacy: return 'PRIVACY';
    case ReportReason.defamation: return 'DEFAMATION';
    case ReportReason.etc: return 'ETC';
  }
}

/// ✅ 신고 서비스
class ReportService {
  /// POST or COMMENT 신고 요청
  static Future<void> reportContent({
    required int targetId,
    required String type,        // 'POST' or 'COMMENT'
    required String reasonCode,  // 'ABUSE', ...
  }) async {
    final jwt = await JwtStorage.getToken();
    final uri = Uri.parse('${HttpService.baseUrl}/api/report');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'targetId': targetId,
        'type': type,
        'reasonCode': reasonCode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('신고 실패: ${response.statusCode}\n${response.body}');
    }
  }
}
