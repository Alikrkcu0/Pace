import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool privateAccount = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                    children: [
                      const _SectionTitle("HESAP"),
                      const SizedBox(height: 10),

                      _settingsGroup(
                        children: [
                          _tile(
                            icon: Icons.person_outline_rounded,
                            color: const Color(0xFF3B82F6),
                            title: "Profil",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),

                          _divider(),

                          _tile(
                            icon: Icons.delete_outline_rounded,
                            color: const Color(0xFFEF4444),
                            title: "Hesabı Sil",
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.45),

                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                    ),

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(32),

                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 26,
                                          sigmaY: 26,
                                        ),

                                        child: Container(
                                          padding: const EdgeInsets.all(24),

                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.075,
                                            ),

                                            borderRadius: BorderRadius.circular(
                                              32,
                                            ),

                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.13,
                                              ),
                                            ),
                                          ),

                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,

                                            children: [
                                              Container(
                                                height: 74,
                                                width: 74,

                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.redAccent
                                                      .withOpacity(0.10),
                                                ),

                                                child: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.redAccent,
                                                  size: 36,
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              const Text(
                                                "Hesabı Devre Dışı Bırak",
                                                textAlign: TextAlign.center,

                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),

                                              const SizedBox(height: 14),

                                              Text(
                                                "Hesabın devre dışı bırakılacak.\n\nDaha sonra tekrar aktif hale getirebilirsin.",
                                                textAlign: TextAlign.center,

                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.68),
                                                  fontSize: 14,
                                                  height: 1.55,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              const SizedBox(height: 26),

                                              GestureDetector(
                                                onTap: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),

                                                child: Container(
                                                  height: 52,
                                                  width: double.infinity,

                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent
                                                        .withOpacity(0.14),

                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),

                                                    border: Border.all(
                                                      color: Colors.redAccent
                                                          .withOpacity(0.18),
                                                    ),
                                                  ),

                                                  child: const Center(
                                                    child: Text(
                                                      "DEVRE DIŞI BIRAK",
                                                      style: TextStyle(
                                                        color: Colors.redAccent,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 14),

                                              GestureDetector(
                                                onTap: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),

                                                child: Text(
                                                  "Vazgeç",

                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.50),
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

                              final user =
                                  Supabase.instance.client.auth.currentUser;

                              if (user == null) return;

                              try {
                                await Supabase.instance.client
                                    .from('profiles')
                                    .update({'status': 'inactive'})
                                    .eq('id', user.id);

                                await Supabase.instance.client.auth.signOut();

                                if (!mounted) return;

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Hata oluştu: $e"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            isDanger: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const _SectionTitle("TERCİHLER"),
                      const SizedBox(height: 10),

                      _settingsGroup(
                        children: [
                          _switchTile(
                            icon: Icons.notifications_none_rounded,
                            color: const Color(0xFF3B82F6),
                            title: "Bildirimler",
                            value: notifications,
                            onChanged: (v) {
                              setState(() {
                                notifications = v;
                              });
                            },
                          ),

                          _divider(),

                          _switchTile(
                            icon: Icons.lock_outline_rounded,
                            color: const Color(0xFF8B5CF6),
                            title: "Gizli Hesap",
                            value: privateAccount,
                            onChanged: (v) {
                              setState(() {
                                privateAccount = v;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const _SectionTitle("DİĞER"),
                      const SizedBox(height: 10),

                      _settingsGroup(
                        children: [
                          _tile(
                            icon: Icons.info_outline_rounded,
                            color: const Color(0xFF22C55E),
                            title: "Hakkında",
                            onTap: () {},
                          ),

                          _divider(),

                          _tile(
                            icon: Icons.logout_rounded,
                            color: const Color(0xFFEF4444),
                            title: "Çıkış Yap",
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.45),

                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                    ),

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(32),

                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 26,
                                          sigmaY: 26,
                                        ),

                                        child: Container(
                                          padding: const EdgeInsets.all(24),

                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.075,
                                            ),

                                            borderRadius: BorderRadius.circular(
                                              32,
                                            ),

                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.13,
                                              ),
                                            ),
                                          ),

                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,

                                            children: [
                                              Container(
                                                height: 74,
                                                width: 74,

                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color(
                                                    0xFF3B82F6,
                                                  ).withOpacity(0.10),
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
                                                  color: Colors.white
                                                      .withOpacity(0.68),
                                                  fontSize: 14,
                                                  height: 1.55,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              const SizedBox(height: 26),

                                              GestureDetector(
                                                onTap: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),

                                                child: Container(
                                                  height: 52,
                                                  width: double.infinity,

                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF3B82F6,
                                                    ).withOpacity(0.14),

                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),

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
                                                        color: Color(
                                                          0xFF3B82F6,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 14),

                                              GestureDetector(
                                                onTap: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),

                                                child: Text(
                                                  "Vazgeç",

                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.50),
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
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                            isDanger: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _glassIcon(Icons.arrow_back_ios_new_rounded),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Text(
              "Ayarlar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _iconBox(icon, color),
      title: Text(
        title,
        style: TextStyle(
          color: isDanger ? const Color(0xFFEF4444) : Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDanger ? const Color(0xFFEF4444) : Colors.white24,
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _iconBox(icon, color),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: color,
        inactiveThumbColor: Colors.white38,
        inactiveTrackColor: Colors.white10,
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 74),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _glassIcon(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Icon(icon, color: Colors.white70, size: 19),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white24,
        fontSize: 10,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -90,
          child: _glow(const Color(0xFF3B82F6).withOpacity(0.18), 250),
        ),

        Positioned(
          bottom: -140,
          left: -100,
          child: _glow(const Color(0xFF1D4ED8).withOpacity(0.10), 280),
        ),
      ],
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 40)],
      ),
    );
  }
}
