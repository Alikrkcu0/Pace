import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final Random _random = Random();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  double _glow1Top = 200;
  double _glow1Left = 50;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _glow1Top = _random.nextInt(600).toDouble() - 100;
          _glow1Left = _random.nextInt(400).toDouble() - 100;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage("Tüm alanları doldurmalısın.");
      return;
    }

    if (!email.contains("@")) {
      _showMessage("Geçerli bir e-posta adresi gir.");
      return;
    }

    final phoneRegex = RegExp(r'^(05)[0-9]{9}$');

    if (!phoneRegex.hasMatch(phone)) {
      _showMessage("Telefon numarası 05 ile başlamalı ve 11 haneli olmalı.");
      return;
    }

    if (password.length < 6) {
      _showMessage("Şifre en az 6 karakter olmalı.");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Şifreler eşleşmiyor.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'username': username, 'phone': phone},
      );

      final user = response.user;

      if (user == null) {
        _showMessage("Kullanıcı oluşturulamadı.");
        return;
      }

      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'full_name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'activity_level': 'Orta',
      }, onConflict: 'id');
      if (!mounted) return;

      _showMessage("Kayıt başarılı. Şimdi giriş yapabilirsin.");

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } on AuthException catch (e) {
      _showMessage(_translateAuthError(e.message));
    } catch (_) {
      _showMessage("Kayıt olurken bir hata oluştu.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _translateAuthError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains("already registered") ||
        lower.contains("already exists") ||
        lower.contains("user already registered")) {
      return "Bu e-posta zaten kayıtlı.";
    }

    if (lower.contains("invalid email")) {
      return "Geçerli bir e-posta adresi gir.";
    }

    if (lower.contains("password")) {
      return "Şifre en az 6 karakter olmalı.";
    }

    return message;
  }

  void _showMessage(String message) {
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
                Icons.info_outline_rounded,
                color: Color(0xFF3B82F6),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
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
          AnimatedPositioned(
            duration: const Duration(seconds: 4),
            top: _glow1Top,
            left: _glow1Left,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withOpacity(0.08),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 110, sigmaY: 110),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            "YENİ HESAP.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Profilinizi oluşturmak için detayları girin.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildInput(
                            "TAM ADINIZ",
                            Icons.person_outline_rounded,
                            controller: _nameController,
                          ),
                          const SizedBox(height: 25),
                          _buildInput(
                            "KULLANICI ADI",
                            Icons.alternate_email_rounded,
                            controller: _usernameController,
                          ),
                          const SizedBox(height: 25),
                          _buildInput(
                            "E-POSTA",
                            Icons.mail_outline_rounded,
                            controller: _emailController,
                          ),
                          const SizedBox(height: 25),
                          _buildInput(
                            "TELEFON",
                            Icons.phone_android_rounded,
                            controller: _phoneController,
                          ),
                          const SizedBox(height: 25),
                          _buildInput(
                            "ŞİFRE",
                            Icons.lock_outline_rounded,
                            controller: _passwordController,
                            isPass: true,
                          ),
                          const SizedBox(height: 25),
                          _buildInput(
                            "ŞİFRE TEKRAR",
                            Icons.shield_outlined,
                            controller: _confirmPasswordController,
                            isPass: true,
                          ),
                          const SizedBox(height: 40),
                          GestureDetector(
                            onTap: _isLoading ? null : _signUp,
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
                                        "KAYDI TAMAMLA",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
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
              : label == "E-POSTA"
              ? TextInputType.emailAddress
              : label == "TELEFON"
              ? TextInputType.phone
              : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: const Color(0xFF3B82F6),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: Icon(icon, color: Colors.white10, size: 20),
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
}
