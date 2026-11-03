import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _heightController = TextEditingController();

  final TextEditingController _weightController = TextEditingController();

  String selectedActivity = "Orta";

  bool isLoading = true;
  bool isSaving = false;

  static const Color _bg = Color(0xFF020408);
  static const Color _card = Color(0xFF0F172A);

  static const Color _blue = Color(0xFF3B82F6);
  static const Color _green = Color(0xFF22C55E);
  static const Color _purple = Color(0xFFA855F7);

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

    _nameController.text =
        data?['full_name'] ?? user.userMetadata?['full_name'] ?? "";

    _usernameController.text =
        data?['username'] ?? user.userMetadata?['username'] ?? "";

    _emailController.text = user.email ?? "";

    _heightController.text = data?['height'] == null
        ? ""
        : data!['height'].toString();

    _weightController.text = data?['weight'] == null
        ? ""
        : data!['weight'].toString();

    selectedActivity = data?['activity_level'] ?? "Orta";

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'full_name': _nameController.text.trim(),
            'username': _usernameController.text.trim(),
            'height': int.tryParse(_heightController.text.trim()),
            'weight': int.tryParse(_weightController.text.trim()),
            'activity_level': selectedActivity,
          })
          .eq('id', user.id);

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameController.text.trim(),
            'username': _usernameController.text.trim(),
          },
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil güncellenirken bir hata oluştu."),
            backgroundColor: Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

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
                        const SizedBox(height: 28),
                        const Text(
                          "Profili Düzenle",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Kişisel bilgilerini güncelle.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildInput(
                          "Ad Soyad",
                          _nameController,
                          Icons.person_rounded,
                          _blue,
                        ),
                        const SizedBox(height: 18),
                        _buildInput(
                          "Kullanıcı adı",
                          _usernameController,
                          Icons.alternate_email_rounded,
                          _purple,
                        ),
                        const SizedBox(height: 18),
                        _buildInput(
                          "E-posta",
                          _emailController,
                          Icons.email_outlined,
                          _green,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInput(
                                "Boy",
                                _heightController,
                                Icons.height_rounded,
                                _blue,
                                suffix: "cm",
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInput(
                                "Kilo",
                                _weightController,
                                Icons.monitor_weight_outlined,
                                _green,
                                suffix: "kg",
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildActivitySelector(),
                        const SizedBox(height: 34),
                        _buildSaveButton(context),
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
            "EDIT PROFILE",
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

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon,
    Color color, {
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
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
                child: Icon(icon, color: color, size: 20),
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySelector() {
    final activities = ["Düşük", "Orta", "Yüksek"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AKTİVİTE SEVİYESİ",
          style: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: activities.map((activity) {
            final bool selected = selectedActivity == activity;

            Color color = _blue;
            if (activity == "Orta") color = _green;
            if (activity == "Yüksek") color = _purple;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedActivity = activity;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: activity == activities.last ? 0 : 10,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withOpacity(0.14)
                        : _card.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? color.withOpacity(0.35)
                          : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      activity,
                      style: TextStyle(
                        color: selected ? color : Colors.white54,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : _saveProfile,
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
          child: isSaving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "KAYDET",
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
