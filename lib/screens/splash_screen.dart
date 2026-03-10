import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'webview_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _agreedToTerms = false;

  Future<void> _startExploring() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先阅读并同意隐私协议和用户协议'),
          backgroundColor: Color(0xFFF72E1E),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 保存已同意协议的状态
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreed_to_terms', true);

    // 直接导航到应用首页
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  void _showPrivacyPolicy() {
    // 显示隐私协议
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WebViewScreen(
          url: 'https://sites.google.com/view/tanyuuu/%E9%A6%96%E9%A1%B5',
          title: '隐私协议',
        ),
      ),
    );
  }

  void _showUserAgreement() {
    // 显示用户协议
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WebViewScreen(
          url: 'https://sites.google.com/view/taaanyuuu/%E9%A6%96%E9%A1%B5',
          title: '用户协议',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo区域
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5A5A).withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 标题
              const Text(
                '彼趣',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4040),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 副标题
              const Text(
                '发现美好，遇见精彩',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9C8E8E),
                ),
              ),
              
              const Spacer(flex: 3),
              
              // 开始探索按钮
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _startExploring,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF72E1E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    '开始探索',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 隐私协议勾选
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFFF72E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9C8E8E),
                        ),
                        children: [
                          const TextSpan(text: '登录即同意隐私'),
                          TextSpan(
                            text: '隐私协议',
                            style: const TextStyle(
                              color: Color(0xFFF72E1E),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _showPrivacyPolicy,
                          ),
                          const TextSpan(text: '、'),
                          TextSpan(
                            text: '用户协议',
                            style: const TextStyle(
                              color: Color(0xFFF72E1E),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _showUserAgreement,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
