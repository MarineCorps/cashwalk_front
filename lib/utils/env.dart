/// ✅ 로컬 개발 여부
const bool isLocal = true; // true: 로컬 (에뮬레이터 기준), false: 배포 서버

/// ✅ 배포 시 SSL 사용 여부
const bool useSSL = false; // true: https/wss, false: http/ws

/// ✅ 호스트 주소 설정 (포트 포함)
const String host = isLocal ? '10.0.2.2:8080' : '3.36.62.185:8080';

/// ✅ API 요청 base URL
String get httpBaseUrl => useSSL ? 'https://$host' : 'http://$host';

/// ✅ WebSocket 요청 base URL
String get wsBaseUrl => useSSL ? 'wss://$host' : 'ws://$host';
