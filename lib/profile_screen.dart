import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'login_page.dart';
import 'settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _bg = Color(0xFF020408);
  static const Color _card = Color(0xFF0F172A);

  static const Color _blue = Color(0xFF3B82F6);
  static const Color _green = Color(0xFF22C55E);
  static const Color _purple = Color(0xFFA855F7);
  static const Color _red = Color(0xFFEF4444);

  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      profile = data;
      isLoading = false;
    });
  }

  String get fullName =>
      profile?['full_name'] ??
      Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ??
      "Kullanıcı";

  String get username =>
      profile?['username'] ??
      Supabase.instance.client.auth.currentUser?.userMetadata?['username'] ??
      "username";

  String get email =>
      Supabase.instance.client.auth.currentUser?.email ?? "E-posta bulunamadı";

  String get phone {
    final rawPhone =
        profile?['phone'] ??
        Supabase.instance.client.auth.currentUser?.userMetadata?['phone'];

    if (rawPhone == null || rawPhone.toString().length != 11) {
      return "-";
    }

    final phone = rawPhone.toString();

    return "${phone.substring(0, 4)} "
        "${phone.substring(4, 7)} "
        "${phone.substring(7, 9)} "
        "${phone.substring(9, 11)}";
  }

  String get height =>
      profile?['height'] == null ? "-" : "${profile!['height']} cm";

  String get weight =>
      profile?['weight'] == null ? "-" : "${profile!['weight']} kg";

  String get activityLevel => profile?['activity_level'] ?? "Orta";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          _buildBackgroundGlow(),

          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: _blue))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBar(context),

                        const SizedBox(height: 24),

                        _buildProfileHeader(),

                        const SizedBox(height: 34),

                        _buildSectionTitle("KİŞİSEL BİLGİLER"),

                        const SizedBox(height: 14),

                        _buildInfoCard(),

                        const SizedBox(height: 30),

                        _buildSectionTitle("AYARLAR"),

                        const SizedBox(height: 14),

                        _buildSettingsCard(context),

                        const SizedBox(height: 26),

                        _buildLogoutButton(),
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
            "PACE PROFILE",

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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            height: 96,
            width: 96,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _card,

              border: Border.all(color: _blue.withOpacity(0.35), width: 2),

              boxShadow: [
                BoxShadow(
                  color: _blue.withOpacity(0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: const Icon(Icons.person_rounded, color: _blue, size: 48),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          fullName,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "@$username",

          style: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,

          children: [
            _chip("DISCIPLINE", _purple, Icons.shield_rounded),

            _chip("AKTİF", _green, Icons.check_circle_rounded),
          ],
        ),
      ],
    );
  }

  Widget _chip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),

        border: Border.all(color: color.withOpacity(0.15)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),

          const SizedBox(width: 6),

          Text(
            text,

            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,

      style: const TextStyle(
        color: Colors.white24,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildInfoCard() {
    return _baseCard(
      children: [
        _row(Icons.person_rounded, "Ad Soyad", fullName, _blue),

        _divider(),

        _row(Icons.alternate_email_rounded, "Kullanıcı adı", username, _purple),

        _divider(),

        _row(Icons.email_outlined, "E-posta", email, _green),

        _divider(),

        _row(Icons.phone_android_rounded, "Telefon", phone, _blue),

        _divider(),

        _row(Icons.lock_outline_rounded, "Şifre", "••••••••", _red),

        _divider(),

        _row(Icons.height_rounded, "Boy", height, _blue),

        _divider(),

        _row(Icons.monitor_weight_outlined, "Kilo", weight, _green),

        _divider(),

        _row(Icons.speed_rounded, "Aktivite seviyesi", activityLevel, _purple),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return _baseCard(
      children: [
        _settingsRow(
          Icons.edit_rounded,
          "Profili düzenle",
          _blue,

          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );

            _loadProfile();
          },
        ),

        _divider(),

        _settingsRow(
          Icons.lock_reset_rounded,
          "Şifreyi değiştir",
          _red,

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          },
        ),

        _divider(),

        _settingsRow(Icons.notifications_none_rounded, "Bildirimler", _green),

        _divider(),

        _settingsRow(
          Icons.settings_rounded,
          "Uygulama ayarları",
          _purple,

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _baseCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: _card.withOpacity(0.82),
        borderRadius: BorderRadius.circular(26),

        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),

      child: Column(children: children),
    );
  }

  Widget _row(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,

          decoration: BoxDecoration(
            color: color.withOpacity(0.11),
            borderRadius: BorderRadius.circular(14),
          ),

          child: Icon(icon, color: color, size: 20),
        ),

        const SizedBox(width: 14),

        Text(
          title,

          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _settingsRow(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,

      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,

            decoration: BoxDecoration(
              color: color.withOpacity(0.11),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withOpacity(0.18),
            size: 15,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.white.withOpacity(0.06), height: 28);
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
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

                      border: Border.all(color: Colors.white.withOpacity(0.13)),
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Container(
                          height: 74,
                          width: 74,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF3B82F6).withOpacity(0.10),
                          ),

                          child: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFF3B82F6),
                            size: 34,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Çıkış Yap",
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          "Hesabından çıkış yapmak istediğine emin misin?",
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
                              color: const Color(0xFF3B82F6).withOpacity(0.14),

                              borderRadius: BorderRadius.circular(18),

                              border: Border.all(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withOpacity(0.18),
                              ),
                            ),

                            child: const Center(
                              child: Text(
                                "ÇIKIŞ YAP",
                                style: TextStyle(
                                  color: Color(0xFF3B82F6),
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

        if (confirm != true) return;

        await Supabase.instance.client.auth.signOut();

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },

      child: Container(
        height: 58,
        width: double.infinity,

        decoration: BoxDecoration(
          color: _red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: _red.withOpacity(0.16)),
        ),

        child: Center(
          child: Text(
            "ÇIKIŞ YAP",

            style: TextStyle(
              color: _red.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
