import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:cashwalk/screen/tutorial_page.dart';
import 'package:cashwalk/screen/home_screen.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/services/firebase_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cashwalk/services/http_service.dart';
import 'package:cashwalk/services/step_service.dart';


// ✅ navigatorKey 전역으로 불러오기
import 'package:cashwalk/services/firebase_service.dart' show navigatorKey;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(nativeAppKey: 'c651375070bb8a02f40ab9b246630fa7');

  await FirebaseService.initializeFCM();
  HttpService.debugBaseUrl();
  await initializeDateFormatting('ko_KR', null);

  await FlutterNaverMap().init(
    clientId: "by60fvdvnr",
    onAuthFailed: (ex) {
      print("인증 실패야: $ex");
    },
  );

  await StepService().init();

  String? token = await JwtStorage.getToken();

  runApp(MyApp(initialScreen: token != null ? HomePage() : const TutorialPage()));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cashwalk',
      navigatorKey: navigatorKey, // ✅ 여기 추가됨

      theme: ThemeData(
        fontFamily: 'NotoSansKR',
        primarySwatch: Colors.blue,

        platform: TargetPlatform.iOS,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', ''),
        Locale('en', ''),
      ],
      home: initialScreen,
    );
  }
}
