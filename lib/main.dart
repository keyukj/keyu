import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/data_service.dart';
import 'services/in_app_purchase_service.dart';

void main() {
  runApp(const TanyuApp());
}

class TanyuApp extends StatelessWidget {
  const TanyuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '彼趣',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFF72E1E),
        scaffoldBackgroundColor: const Color(0xFFFFF0F0),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF4A4040)),
          titleTextStyle: TextStyle(
            color: Color(0xFF4A4040),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF4A4040),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF4A4040),
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF9C8E8E),
            fontSize: 14,
          ),
        ),
      ),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _hasAgreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // 初始化内购服务
      await InAppPurchaseService.initialize();
      
      // 检查是否已同意协议
      final prefs = await SharedPreferences.getInstance();
      
      // 临时注释：强制显示启动页用于测试
      // final agreedToTerms = prefs.getBool('agreed_to_terms') ?? false;
      final agreedToTerms = false; // 强制显示启动页
      
      // 检查登录状态
      final isLoggedIn = await DataService.isLoggedIn();
      
      setState(() {
        _hasAgreedToTerms = agreedToTerms;
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasAgreedToTerms = false;
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF0F0),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF72E1E),
          ),
        ),
      );
    }

    // 如果未同意协议，显示启动页
    if (!_hasAgreedToTerms) {
      return const SplashScreen();
    }

    // 如果已同意协议但未登录，显示登录页
    // 如果已登录，显示主页
    return _isLoggedIn ? const MainScreen() : const LoginScreen();
  }
}