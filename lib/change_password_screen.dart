import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _isLoading = false;

  static const Color _bg = Color(0xFF020408);
  static const Color _card = Color(0xFF0F172A);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _purple = Color(0xFFA855F7);
  static const Color _red = Color(0xFFEF4444);
  static const Color _green = Color(0xFF22C55E);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showMessage("Tüm alanları doldurmalısın.", _red);
      return;
    }

    if (newPass.length < 6) {
      _showMessage("Yeni şifre en az 6 karakter olmalı.", _red);
      return;
    }

    if (newPass != confirm) {
      _showMessage("Yeni şifreler eşleşmiyor.", _red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPass),
      );

      if (!mounted) return;

      _showMessage("Şifre güncellendi.", _green);

      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } on AuthException catch (e) {
      _showMessage(e.message, _red);
    } catch (_) {
      _showMessage("Şifre güncellenirken bir hata oluştu.", _red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 28),
                  const Text(
                    "Şifreyi Değiştir",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hesabını güvende tutmak için güçlü bir şifre belirle.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildPasswordInput(
                    label: "Mevcut şifre",
                    controller: _currentPasswordController,
                    hidden: _hideCurrent,
                    color: _blue,
                    onToggle: () {
                      setState(() => _hideCurrent = !_hideCurrent);
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildPasswordInput(
                    label: "Yeni şifre",
                    controller: _newPasswordController,
                    hidden: _hideNew,
                    color: _purple,
                    onToggle: () {
                      setState(() => _hideNew = !_hideNew);
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildPasswordInput(
                    label: "Yeni şifre tekrar",
                    controller: _confirmPasswordController,
                    hidden: _hideConfirm,
                    color: _green,
                    onToggle: () {
                      setState(() => _hideConfirm = !_hideConfirm);
                    },
                  ),
                  const SizedBox(height: 26),
                  _buildSecurityNote(),
                  const SizedBox(height: 34),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -140,
          right: -120,
          child: _glowCircle(340, _blue.withOpacity(0.07)),
        ),
        Positioned(
          bottom: -180,
          left: -130,
          child: _glowCircle(380, _purple.withOpacity(0.04)),
        ),
      ],
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
        child: Container(),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: const Text(
            "PASSWORD",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput({
    required String label,
    required TextEditingController controller,
    required bool hidden,
    required Color color,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _card.withOpacity(0.82),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: TextField(
            controller: controller,
            obscureText: hidden,
            cursorColor: color,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.lock_outline_rounded, color: color, size: 20),
              ),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _blue.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, color: _blue, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "Şifren en az 6 karakter olmalı. Daha güvenli olması için harf, sayı ve sembol kullan.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _savePassword,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_blue, _purple]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
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
                  "ŞİFREYİ GÜNCELLE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}
