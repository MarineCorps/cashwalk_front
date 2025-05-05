import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/models/invite_stats.dart';
import 'package:cashwalk/services/http_service.dart';

class InviteService {
  /// ✅ 초대 통계 조회 (한글 깨짐 완벽 방지됨)
  static Future<InviteStats> getInviteStats() async {
    final token = await JwtStorage.getToken();
    final headers = {'Authorization': 'Bearer $token'};

    final data = await HttpService.getFromServer('/api/invite/stats', headers: headers);
    return InviteStats.fromJson(data);
  }
}
