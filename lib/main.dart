import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'step_screen.dart';
import 'challenge_screen.dart';
import 'workout_screen.dart';
import 'profile_screen.dart';
import 'social_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://afchlikgeumyfwvfgahq.supabase.co',
    anonKey: 'sb_publishable_qqfuLsgeRomoVTFiCUTlZA_IVgL5yVN',
  );

  runApp(const PaceApp());
}

class PaceApp extends StatelessWidget {
  const PaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _shimmerController;

  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _startAnimation = true);
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _openStep() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StepScreen()),
    );
  }

  void _openChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChallengeScreen()),
    );
  }

  void _openWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutScreen()),
    );
  }

  void _openSocial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SocialScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          _AmbientGlow(controller: _glowController),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimatedTopBar(controller: _shimmerController),
                  const SizedBox(height: 34),
                  _HeroSection(isAnimated: _startAnimation),
                  const SizedBox(height: 28),
                  const _GlassStatsCard(),
                  const SizedBox(height: 30),
                  _buildFocusSection(),
                  const SizedBox(height: 30),
                  const _SectionLabel(text: "KEŞFET"),
                  const SizedBox(height: 15),
                  _FeatureGrid(
                    isAnimated: _startAnimation,
                    onStepTap: _openStep,
                    onChallengeTap: _openChallenge,
                    onWorkoutTap: _openWorkout,
                    onSocialTap: _openSocial,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "BUGÜNKÜ ODAK",
          style: TextStyle(
            color: Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        _buildFocusCard(
          icon: Icons.directions_walk_rounded,
          title: "Adım hedefi",
          subtitle: "3.2k / 7k tamamlandı",
          progress: 0.45,
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 12),
        _buildFocusCard(
          icon: Icons.fitness_center_rounded,
          title: "Antrenman",
          subtitle: "Bugünkü setler hazır",
          progress: 0.8,
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 12),
        _buildFocusCard(
          icon: Icons.workspace_premium_rounded,
          title: "Challenge",
          subtitle: "4 görev aktif",
          progress: 0.33,
          color: const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildFocusCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: color,
                    backgroundColor: Colors.white.withOpacity(0.06),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  final AnimationController controller;

  const _AmbientGlow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Transform.rotate(
        angle: controller.value * 2 * 3.14,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                const Color(0xFF3B82F6).withOpacity(0.12),
                Colors.transparent,
              ],
              center: const Alignment(0.8, -0.5),
              radius: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedTopBar extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) => ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              stops: [
                controller.value - 0.3,
                controller.value,
                controller.value + 0.3,
              ],
              colors: const [Colors.white30, Colors.white, Colors.white30],
            ).createShader(bounds),
            child: const Text(
              "P A C E",
              style: TextStyle(
                letterSpacing: 8,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },

          child: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatefulWidget {
  final bool isAnimated;

  const _HeroSection({required this.isAnimated});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> _quotes = const [
    {"top": "MENTAL DİSİPLİN", "main": "Zayıflık tercihtir."},
    {"top": "MUTLAK GELİŞİM", "main": "Acı yoksa sonuç yok."},
    {"top": "SINIRSIZ POTANSİYEL", "main": "Sınırlarını yok et."},
    {"top": "SARSILMAZ İRADE", "main": "Disiplin özgürlüktür."},
    {"top": "KARARLILIK", "main": "Pes etmek ölmektir."},
    {"top": "YÜKSEK HEDEF", "main": "Daha fazlasını iste."},
    {"top": "SABIR VE GÜÇ", "main": "Zirve sabır ister."},
    {"top": "ODAK NOKTASI", "main": "Korkunu yakıt yap."},
    {"top": "AKSİYON ZAMANI", "main": "Bugün ya da asla."},
    {"top": "NET SONUÇLAR", "main": "Bahane güç hırsızıdır."},
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        setState(() => _currentIndex = (_currentIndex + 1) % _quotes.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.isAnimated ? 1 : 0.96,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Column(
          key: ValueKey<int>(_currentIndex),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _quotes[_currentIndex]["top"]!,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFF64748B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Text(
                _quotes[_currentIndex]["main"]!,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassStatsCard extends StatelessWidget {
  const _GlassStatsCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              const SizedBox(
                height: 55,
                width: 55,
                child: CircularProgressIndicator(
                  value: 0.45,
                  strokeWidth: 6,
                  color: Color(0xFF3B82F6),
                  backgroundColor: Colors.white10,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "GÜNLÜK HEDEF",
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "%45 Tamam",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Hedefe 3.8k kaldı",
                      style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final bool isAnimated;
  final VoidCallback onStepTap;
  final VoidCallback onChallengeTap;
  final VoidCallback onWorkoutTap;
  final VoidCallback onSocialTap;

  const _FeatureGrid({
    required this.isAnimated,
    required this.onStepTap,
    required this.onChallengeTap,
    required this.onWorkoutTap,
    required this.onSocialTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _FeatureItem(
        title: "ADIM",
        subtitle: "Günlük takip",
        icon: Icons.directions_run_rounded,
        progressText: "3.2k",
        onTap: onStepTap,
      ),
      _FeatureItem(
        title: "CHALLENGE",
        subtitle: "Anlık görevler",
        icon: Icons.workspace_premium_rounded,
        progressText: "4 aktif",
        onTap: onChallengeTap,
      ),
      _FeatureItem(
        title: "ANTRENMAN",
        subtitle: "Plan ve setler",
        icon: Icons.fitness_center_rounded,
        progressText: "Bugün",
        onTap: onWorkoutTap,
      ),
      _FeatureItem(
        title: "SOSYAL",
        subtitle: "Yakında",
        icon: Icons.language_rounded,
        progressText: "Beta",
        onTap: onSocialTap,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        return _ActionCard(
          item: items[index],
          index: index,
          isAnimated: isAnimated,
        );
      },
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String progressText;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progressText,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _FeatureItem item;
  final int index;
  final bool isAnimated;

  const _ActionCard({
    required this.item,
    required this.index,
    required this.isAnimated,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: AnimatedScale(
        scale: isAnimated ? 1.0 : 0.85,
        duration: Duration(milliseconds: 600 + (index * 120)),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: const Color(0xFF3B82F6), size: 28),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.32),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.progressText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF60A5FA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        letterSpacing: 4,
        fontSize: 10,
        color: Colors.white24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
