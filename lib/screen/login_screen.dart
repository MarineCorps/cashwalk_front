import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cashwalk/services/http_service.dart';
import 'package:cashwalk/utils/jwt_storage.dart';
import 'package:cashwalk/screen/home_screen.dart';
import 'package:cashwalk/signup/terms_page.dart';
import 'package:cashwalk/signup/information_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _jwtToken;

  Future<void> _handleGoogleLogin() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      serverClientId: '899929648402-bbil6484g4onafr7a44nf53a4189fl3p.apps.googleusercontent.com',
    );

    try {
      final account = await _googleSignIn.signIn();
      final auth = await account?.authentication;
      final idToken = auth?.idToken;

      final response = await HttpService.postToServer(
        '/api/auth/google',
        {'idToken': idToken},
        headers: {'Content-Type': 'application/json'},
      );

      await _processLoginResponse(response);
    } catch (error) {
      print('❌ Google 로그인 실패: $error');
    }
  }

  Future<void> _handleKakaoLogin() async {
    try {
      bool kakaoInstalled = await isKakaoTalkInstalled();

      OAuthToken token = kakaoInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      final response = await HttpService.postToServer(
        '/api/auth/kakao',
        token.accessToken,
        headers: {'Content-Type': 'application/json'},
      );

      await _processLoginResponse(response);
    } catch (e) {
      print('❌ 카카오 로그인 실패: $e');
    }
  }

  Future<void> _processLoginResponse(dynamic data) async {
    final jwt = data['jwt'];
    final isNewUser = data['isNewUser'];
    final firstLoginCompleted = data['firstLoginCompleted'];

    setState(() {
      _jwtToken = jwt;
    });

    await JwtStorage.saveToken(jwt);

    if (isNewUser == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TermsPage()),
      );
    } else if (firstLoginCompleted == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InformationPage(nickname: "닉네임 placeholder")),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/loading.png', // 🔄 이미지 경로는 pubspec.yaml에 등록되어 있어야 함
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.4)), // ✅ 텍스트 가독성 향상
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Column(
                  children: const [
                    Text('👟', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 16),
                    Text(
                      'cashwalk',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '돈버는 만보기 캐시워크',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton.icon(
                    onPressed: _handleKakaoLogin,
                    icon: const Icon(Icons.chat_bubble, color: Colors.black),
                    label: const Text(
                      '카카오로 시작하기',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE100),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('또는', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LoginCircleButton(
                      icon: Icons.facebook,
                      label: '페이스북',
                      onTap: () {},
                      iconSize: 31,
                    ),
                    const SizedBox(width: 24),
                    _LoginCircleButton(
                      icon: FontAwesomeIcons.google,
                      label: '구글',
                      onTap: _handleGoogleLogin,
                    ),
                    const SizedBox(width: 24),
                    _LoginCircleButton(
                      icon: Icons.link,
                      label: '사용해보기',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('게스트 로그인은 지원되지 않습니다.')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _LoginCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double iconSize;

  const _LoginCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Ink(
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: Colors.white.withOpacity(0.85), // ✅ 살짝 투명한 흰색 배경
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2), // ✅ 그림자 효과
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white70, size: iconSize), // ✅ 더 잘 보이는 검정
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

}
