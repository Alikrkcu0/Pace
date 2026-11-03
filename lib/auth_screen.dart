import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    // Senin o meşhur shimmer (parlama) animasyon kontrolcün
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 3 saniye sonra diğer sayfaya geçiş
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        final session = Supabase.instance.client.auth.currentSession;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                session != null ? const DashboardScreen() : const LoginPage(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Center(
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                stops: [
                  _shimmerController.value - 0.3,
                  _shimmerController.value,
                  _shimmerController.value + 0.3,
                ],
                colors: const [Colors.white30, Colors.white, Colors.white30],
              ).createShader(bounds),
              child: const Text(
                "P A C E",
                style: TextStyle(
                  letterSpacing: 15,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
