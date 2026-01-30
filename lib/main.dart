import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'services/data_service.dart';

void main() {
  runApp(const TanyuApp());
}

class TanyuApp extends StatelessWidget {
  const TanyuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '探遇',
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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await DataService.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
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

    return _isLoggedIn ? const MainScreen() : const LoginScreen();
  }
}