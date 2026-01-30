import 'package:flutter/material.dart';
import '../services/data_service.dart';
import 'main_screen.dart';
import 'webview_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isAgreedToTerms = false;

  void _openWebView(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          url: url,
          title: title,
        ),
      ),
    );
  }

  Future<void> _login() async {
    // 检查是否同意协议
    if (!_isAgreedToTerms) {
      _showAgreementDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟登录过程
      await Future.delayed(const Duration(seconds: 1));
      
      // 创建默认用户并保存
      final defaultUser = DataService.getDefaultUser();
      await DataService.saveCurrentUser(defaultUser);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAgreementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('请勾选协议'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo区域
              Container(
                margin: const EdgeInsets.only(bottom: 64),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5A5A).withOpacity(0.3),
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
                    const Text(
                      '探遇',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4040),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '发现美好，遇见精彩',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                  ],
                ),
              ),

              // 登录按钮
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF72E1E), Color(0xFFFF6B6B)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF72E1E).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _login,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              '开始探索',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 协议条款
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _isAgreedToTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _isAgreedToTerms = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFFF72E1E),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            '登录即同意',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9C8E8E),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openWebView(
                              'https://sites.google.com/view/tanyuuu/%E9%A6%96%E9%A1%B5',
                              '隐私协议',
                            ),
                            child: const Text(
                              '隐私协议',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF72E1E),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text(
                            '、',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9C8E8E),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openWebView(
                              'https://sites.google.com/view/taaanyuuu/%E9%A6%96%E9%A1%B5',
                              '用户协议',
                            ),
                            child: const Text(
                              '用户协议',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF72E1E),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}