import 'package:cashwalk/services/http_service.dart';
import 'package:cashwalk/models/certification_model.dart';
import 'package:cashwalk/utils/jwt_storage.dart';

class CertificationService {
  // ✅ 거주지 인증 요청
  static Future<bool> certifyResidence(String address, String certifiedAt) async {
    final token = await JwtStorage.getToken();
    final response = await HttpService.postToServer(
      '/api/certifications/residence',
      {
        'address': address,
        'certifiedAt': certifiedAt,
      },
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response == '거주지 인증 완료';
  }

  // ✅ 활동지 인증 요청
  static Future<bool> certifyActivity(String address, String certifiedAt) async {
    final token = await JwtStorage.getToken();
    final response = await HttpService.postToServer(
      '/api/certifications/activity',
      {
        'address': address,
        'certifiedAt': certifiedAt,
      },
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response == '활동지 인증 완료';
  }

  // ✅ 내 인증정보 조회
  static Future<CertificationModel?> getCertificationInfo() async {
    final token = await JwtStorage.getToken();
    final response = await HttpService.getFromServer(
      '/api/certifications',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response == null) return null;
    return CertificationModel.fromJson(response);
  }
}
