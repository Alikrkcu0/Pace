import 'dart:ui';
import 'package:flutter/material.dart';

class StepScreen extends StatefulWidget {
  const StepScreen({super.key});

  @override
  State<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends State<StepScreen> with TickerProviderStateMixin {
  late final AnimationController _entryController;

  final int _currentSteps = 3215;
  final int _goalSteps = 7000;

  final List<int> _weeklySteps = const [
    4200,
    7100,
    5300,
    9000,
    6400,
    8200,
    7500,
  ];

  final List<String> _weekDays = const [
    "Pzt",
    "Sal",
    "Çar",
    "Per",
    "Cum",
    "Cmt",
    "Paz",
  ];

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentSteps / _goalSteps).clamp(0.0, 1.0);
    final double distance = _currentSteps * 0.0007;
    final int activeMinutes = 42;
    final int calories = (_currentSteps * 0.045).round();
    final int remainingSteps = (_goalSteps - _currentSteps).clamp(
      0,
      _goalSteps,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildGoalSummary(progress, remainingSteps),
                        const SizedBox(height: 32),
                        _buildAnimatedMainCircle(progress),
                        const SizedBox(height: 34),
                        _buildStatGrid(
                          distance: distance,
                          activeMinutes: activeMinutes,
                          calories: calories,
                        ),
                        const SizedBox(height: 34),
                        _buildWeeklyChartSection(),
                        const SizedBox(height: 28),
                        _buildInsightCard(progress),
                        const SizedBox(height: 26),
                      ],
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

  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        Positioned(top: -140, right: -120, child: _glowCircle(340, 0.075)),
        Positioned(bottom: -180, left: -130, child: _glowCircle(380, 0.045)),
      ],
    );
  }

  Widget _glowCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF3B82F6).withOpacity(opacity),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
        child: Container(),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
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
              "PACE STEPS",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _entryController,
                curve: Curves.easeOutCubic,
              ),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PERFORMANS",
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 10,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Günlük Adım",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Bugünkü hareket seviyeni takip et.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSummary(double progress, int remainingSteps) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withOpacity(0.12),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.22),
                  ),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Color(0xFF3B82F6),
                  size: 30,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "GÜNLÜK HEDEF",
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "%${(progress * 100).round()} tamamlandı",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remainingSteps == 0
                          ? "Hedef tamamlandı. Güzel iş."
                          : "Hedefe $remainingSteps adım kaldı.",
                      style: const TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildAnimatedMainCircle(double targetProgress) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: targetProgress),
        duration: const Duration(milliseconds: 1900),
        curve: Curves.easeOutQuart,
        builder: (context, value, child) {
          final animatedSteps = (value * _goalSteps).toInt();

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.12),
                      blurRadius: 50,
                      spreadRadius: 8,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.05),
                    width: 22,
                  ),
                ),
              ),
              SizedBox(
                width: 230,
                height: 230,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 15,
                  color: const Color(0xFF3B82F6),
                  backgroundColor: Colors.white.withOpacity(0.055),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF020408).withOpacity(0.55),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animatedSteps.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "ADIM",
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Hedef $_goalSteps",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.28),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatGrid({
    required double distance,
    required int activeMinutes,
    required int calories,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _buildSmallStatCard(
              label: "MESAFE",
              value: "${distance.toStringAsFixed(1)} km",
              icon: Icons.map_outlined,
            ),
            const SizedBox(width: 14),
            _buildSmallStatCard(
              label: "SÜRE",
              value: "$activeMinutes dk",
              icon: Icons.timer_outlined,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildSmallStatCard(
              label: "KALORİ",
              value: "$calories kcal",
              icon: Icons.local_fire_department_outlined,
            ),
            const SizedBox(width: 14),
            _buildSmallStatCard(
              label: "TEMPO",
              value: "Orta",
              icon: Icons.speed_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.78),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.11),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: const Color(0xFF3B82F6), size: 19),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChartSection() {
    final int maxSteps = _weeklySteps.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "HAFTALIK TREND",
          style: TextStyle(
            color: Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 245,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.72),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Bu Hafta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${_weeklySteps.reduce((a, b) => a + b)} adım",
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    _weeklySteps.length,
                    (index) => _buildBar(index, maxSteps),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(int index, int maxSteps) {
    final double heightRatio = _weeklySteps[index] / maxSteps;
    final bool isToday = index == 6;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: heightRatio),
          duration: Duration(milliseconds: 900 + (index * 90)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _weeklySteps[index] >= 1000
                      ? "${(_weeklySteps[index] / 1000).toStringAsFixed(1)}k"
                      : _weeklySteps[index].toString(),
                  style: TextStyle(
                    color: isToday
                        ? const Color(0xFF3B82F6)
                        : Colors.white.withOpacity(0.26),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 13,
                  height: 95 * value,
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF3B82F6)
                        : Colors.white.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _weekDays[index],
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.white24,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInsightCard(double progress) {
    final bool completed = progress >= 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: completed
            ? const Color(0xFF3B82F6).withOpacity(0.10)
            : Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: completed
              ? const Color(0xFF3B82F6).withOpacity(0.22)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle_rounded : Icons.trending_up_rounded,
            color: const Color(0xFF3B82F6),
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              completed
                  ? "Bugünkü adım hedefi tamamlandı. Seriyi bozma."
                  : "Kısa bir yürüyüşle hedefe yaklaşabilirsin.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
