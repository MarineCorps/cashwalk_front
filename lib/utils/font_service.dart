import 'package:http/http.dart' as http;
import 'dart:convert';
//한글꺠지는걸 방지하기위해 만든 클래스
class FontService {
  static Future<dynamic> getJson(String url, {Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    final decoded = utf8.decode(response.bodyBytes); // ✅ 핵심
    return json.decode(decoded);
  }

  static Future<dynamic> postJson(String url, {Map<String, String>? headers, Object? body}) async {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    final decoded = utf8.decode(response.bodyBytes); // ✅ 핵심
    return json.decode(decoded);
  }
  static Future<dynamic> deleteJson(String url, {Map<String, String>? headers}) async {
    final response = await http.delete(Uri.parse(url), headers: headers);
    final decoded = utf8.decode(response.bodyBytes);
    return json.decode(decoded);
  }

}
