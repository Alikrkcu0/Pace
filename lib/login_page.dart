import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  final Random _random = Random();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  double _glow1Top = 100;
  double _glow1Left = 100;
  double _glow2Top = 300;
  double _glow2Left = 200;

  late Timer _movementTimer;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _movementTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _glow1Top = _random.nextInt(600).toDouble() - 100;
          _glow1Left = _random.nextInt(400).toDouble() - 100;
          _glow2Top = _random.nextInt(600).toDouble() - 100;
          _glow2Left = _random.nextInt(400).toDouble() - 100;
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _movementTimer.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("E-posta ve şifre boş olamaz.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('status')
            .eq('id', user.id)
            .maybeSingle();

        if (profile?['status'] == 'inactive') {
          if (!mounted) return;

          final reactivate = await showDialog<bool>(
            context: context,
            barrierColor: Colors.black.withOpacity(0.45),
            builder: (context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.075),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.13),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Hesabı Yeniden Aktifleştir",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "Bu hesap daha önce devre dışı bırakılmış.\n\nTekrar aktif etmek ister misiniz?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.68),
                              fontSize: 14,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 26),
                          GestureDetector(
                            onTap: () => Navigator.pop(context, true),
                            child: Container(
                              height: 52,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.16),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "AKTİF ET",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () => Navigator.pop(context, false),
                            child: Text(
                              "Vazgeç",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.50),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );

          if (reactivate == true) {
            await Supabase.instance.client
                .from('profiles')
                .update({'status': 'active'})
                .eq('id', user.id);
          } else {
            await Supabase.instance.client.auth.signOut();
            return;
          }
        }
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage("Giriş yapılırken bir hata oluştu.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    String turkishMessage = message;

    if (message.toLowerCase().contains("invalid login credentials")) {
      turkishMessage = "E-posta veya şifre hatalı.";
    } else if (message.toLowerCase().contains("invalid email")) {
      turkishMessage = "Geçerli bir e-posta adresi gir.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFF3B82F6),
                size: 22,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  turkishMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          _buildBackgroundGlows(),
          _buildBlurLayer(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    _buildPaceLogo(),
                    const SizedBox(height: 80),
                    _buildWelcomeText(),
                    const SizedBox(height: 40),
                    _buildFormInputs(),
                    const SizedBox(height: 30),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    _buildGoogleSignInButton(),
                    const SizedBox(height: 30),
                    _buildRegisterRedirect(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return GestureDetector(
      onTap: () {
        _showMessage("Google ile giriş daha sonra eklenecek.");
      },
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 35),
            SizedBox(width: 10),
            Text(
              "Google ile devam et",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterRedirect() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
        },
        child: RichText(
          text: TextSpan(
            text: "Hesabınız yok mu? ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
            children: const [
              TextSpan(
                text: "Kayıt Ol",
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundGlows() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 4),
          curve: Curves.easeInOutSine,
          top: _glow1Top,
          left: _glow1Left,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B82F6).withOpacity(0.1),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(seconds: 4),
          curve: Curves.easeOutSine,
          top: _glow2Top,
          left: _glow2Left,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B82F6).withOpacity(0.07),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlurLayer() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildPaceLogo() {
    return AnimatedBuilder(
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
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "HOŞ GELDİNİZ.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Devam etmek için giriş yapın.",
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFormInputs() {
    return Column(
      children: [
        _buildField(
          "E-POSTA",
          Icons.mail_outline_rounded,
          controller: _emailController,
        ),
        const SizedBox(height: 25),
        _buildField(
          "ŞİFRE",
          Icons.lock_outline_rounded,
          controller: _passwordController,
          isPass: true,
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    IconData icon, {
    required TextEditingController controller,
    bool isPass = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3B82F6),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPass,
          keyboardType: isPass
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white12, size: 20),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _signIn,
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "GİRİŞ YAP",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
        ),
      ),
    );
  }
}
