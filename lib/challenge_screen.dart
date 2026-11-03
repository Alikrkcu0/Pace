import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

// 1. GÖREV MODELİ
class Task {
  final String title;
  final String category;
  bool isCompleted;

  Task({required this.title, required this.category, this.isCompleted = false});
}

// 2. GELİŞMİŞ GÖREV YÖNETİCİSİ
class ChallengeManager {
  static final ChallengeManager _instance = ChallengeManager._internal();

  factory ChallengeManager() => _instance;

  final List<Task> _taskPool = [
    // --- FİZİKSEL ---
    ...List.generate(
      10,
      (i) => Task(title: "${(i + 1) * 10} Şınav Çek", category: "Fiziksel"),
    ),

    ...List.generate(
      10,
      (i) => Task(title: "${(i + 1) * 15} Squat Yap", category: "Fiziksel"),
    ),

    ...List.generate(
      5,
      (i) => Task(title: "${i + 1} Dakika Plank Dur", category: "Fiziksel"),
    ),

    ...List.generate(
      5,
      (i) => Task(title: "${(i + 1) * 20} Mekik Çek", category: "Fiziksel"),
    ),

    Task(title: "50 Burpee Yap", category: "Fiziksel"),
    Task(title: "10 Barfiks Çek", category: "Fiziksel"),
    Task(title: "5KM Koşu Yap", category: "Kardiyo"),
    Task(title: "15 Dakika Esneme", category: "Fiziksel"),

    // --- BESLENME ---
    Task(title: "Bugün Tatlı Yeme", category: "Beslenme"),
    Task(title: "Sıfır Şeker", category: "Beslenme"),

    ...List.generate(
      5,
      (i) => Task(title: "${i + 1.5} Litre Su İç", category: "Sağlık"),
    ),

    Task(title: "Sadece Sebze Ye", category: "Beslenme"),
    Task(title: "Akşam 8'den Sonra Yemek Yeme", category: "Beslenme"),
    Task(title: "Yeşil Çay İç", category: "Sağlık"),
    Task(title: "Ekransız Yemek Ye", category: "Odak"),

    // --- ZİHİNSEL & DİSİPLİN ---
    Task(title: "Soğuk Duş Yap", category: "İrade"),
    Task(title: "10 Dakika Meditasyon", category: "Zihinsel"),

    ...List.generate(
      5,
      (i) =>
          Task(title: "${(i + 1) * 20} Sayfa Kitap Oku", category: "Zihinsel"),
    ),

    Task(title: "Sosyal Medya Kullanma (1 Saat)", category: "Odak"),

    Task(title: "Yatağını Topla", category: "Disiplin"),
    Task(title: "Odanı Temizle", category: "Disiplin"),
    Task(title: "Sabah 06:00'da Kalk", category: "Disiplin"),
    Task(title: "Telefona 2 Saat Bakma", category: "Odak"),
    Task(title: "Günün Planını Yaz", category: "Disiplin"),
    Task(title: "Hiç Şikayet Etme", category: "Zihinsel"),
  ];

  List<Task> todaysTasks = [];

  int secondsLeft = 86400;

  Timer? _timer;

  final StreamController<int> _timerController =
      StreamController<int>.broadcast();

  Stream<int> get timerStream => _timerController.stream;

  ChallengeManager._internal() {
    _generateTasks();
    _startGlobalTimer();
  }

  void _generateTasks() {
    final shuffledPool = List<Task>.from(_taskPool)..shuffle();

    final List<Task> selectedTasks = [];
    final Set<String> usedGroups = {};

    for (final task in shuffledPool) {
      final groupKey = _getTaskGroupKey(task);

      if (usedGroups.contains(groupKey)) continue;

      selectedTasks.add(Task(title: task.title, category: task.category));

      usedGroups.add(groupKey);

      if (selectedTasks.length == 6) break;
    }

    todaysTasks = selectedTasks;
  }

  String _getTaskGroupKey(Task task) {
    final title = task.title.toLowerCase();

    if (title.contains("şınav")) return "sinav";
    if (title.contains("squat")) return "squat";
    if (title.contains("plank")) return "plank";
    if (title.contains("mekik")) return "mekik";
    if (title.contains("litre su")) return "su";
    if (title.contains("sayfa kitap")) return "kitap";

    return "${task.category}_${task.title}";
  }

  void _startGlobalTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft > 0) {
        secondsLeft--;
      } else {
        secondsLeft = 86400;
        _generateTasks();
      }

      if (!_timerController.isClosed) {
        _timerController.add(secondsLeft);
      }
    });
  }

  void toggleTask(int index) {
    todaysTasks[index].isCompleted = !todaysTasks[index].isCompleted;

    _timerController.add(secondsLeft);
  }

  int get completedCount {
    return todaysTasks.where((t) => t.isCompleted).length;
  }

  double get progress {
    if (todaysTasks.isEmpty) return 0;
    return completedCount / todaysTasks.length;
  }
}

// 3. UI SAYFASI
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = ChallengeManager();

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          _AnimatedChallengeGlow(controller: _glowController),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),

                    child: StreamBuilder<int>(
                      stream: manager.timerStream,

                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            _buildHeader(),

                            const SizedBox(height: 24),

                            _buildProgressPanel(manager),

                            const SizedBox(height: 28),

                            const Text(
                              "DİNAMİK MEYDAN OKUMALAR",
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),

                                itemCount: manager.todaysTasks.length,

                                itemBuilder: (context, index) =>
                                    _buildMissionItem(
                                      manager.todaysTasks[index],
                                      index,
                                      manager,
                                    ),
                              ),
                            ),

                            _buildBottomTimer(manager.secondsLeft),
                          ],
                        );
                      },
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
              "PACE CHALLENGE",
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "ANLIK SİSTEM",
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontSize: 10,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Hızlı Görevler",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "6 benzersiz günlük görev.",
          style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildProgressPanel(ChallengeManager manager) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),

        borderRadius: BorderRadius.circular(28),

        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),

      child: Row(
        children: [
          SizedBox(
            height: 62,
            width: 62,

            child: Stack(
              alignment: Alignment.center,

              children: [
                CircularProgressIndicator(
                  value: manager.progress,
                  strokeWidth: 6,
                  color: const Color(0xFF3B82F6),
                  backgroundColor: Colors.white.withOpacity(0.08),
                ),

                Text(
                  "${manager.completedCount}/${manager.todaysTasks.length}",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "GÖREV İLERLEMESİ",
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  manager.completedCount == manager.todaysTasks.length
                      ? "Tüm görevler tamamlandı."
                      : "${manager.todaysTasks.length - manager.completedCount} görev kaldı.",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTimer(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final formattedTime =
        "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${secs.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.autorenew_rounded,
                color: Color(0xFF3B82F6),
                size: 18,
              ),
              const SizedBox(width: 10),
              const Text(
                "LİSTE YENİLENİYOR",
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                formattedTime,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: seconds / 86400,
              minHeight: 6,
              color: const Color(0xFF3B82F6),
              backgroundColor: Colors.white.withOpacity(0.06),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionItem(Task task, int index, ChallengeManager manager) {
    final meta = _categoryMeta(task.category);

    return GestureDetector(
      onTap: () => manager.toggleTask(index),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: task.isCompleted
              ? const Color(0xFF3B82F6).withOpacity(0.10)
              : const Color(0xFF0F172A),

          borderRadius: BorderRadius.circular(22),

          border: Border.all(
            color: task.isCompleted
                ? const Color(0xFF3B82F6).withOpacity(0.35)
                : Colors.white.withOpacity(0.05),
          ),
        ),

        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,

              decoration: BoxDecoration(
                color: task.isCompleted
                    ? const Color(0xFF3B82F6).withOpacity(0.18)
                    : Colors.white.withOpacity(0.035),

                borderRadius: BorderRadius.circular(16),
              ),

              child: Icon(
                task.isCompleted ? Icons.check_circle_rounded : meta["icon"],

                color: task.isCompleted
                    ? const Color(0xFF3B82F6)
                    : Colors.white54,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    task.title,

                    style: TextStyle(
                      color: task.isCompleted ? Colors.white : Colors.white70,

                      fontWeight: FontWeight.w900,

                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: (meta["color"] as Color).withOpacity(0.12),

                      borderRadius: BorderRadius.circular(100),
                    ),

                    child: Text(
                      task.category.toUpperCase(),

                      style: TextStyle(
                        color: (meta["color"] as Color).withOpacity(0.95),

                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _categoryMeta(String category) {
    switch (category) {
      case "Fiziksel":
        return {
          "icon": Icons.fitness_center_rounded,
          "color": const Color(0xFF3B82F6),
        };

      case "Kardiyo":
        return {
          "icon": Icons.directions_run_rounded,
          "color": const Color(0xFF38BDF8),
        };

      case "Beslenme":
        return {
          "icon": Icons.restaurant_rounded,
          "color": const Color(0xFF22C55E),
        };

      case "Sağlık":
        return {
          "icon": Icons.water_drop_rounded,
          "color": const Color(0xFF06B6D4),
        };

      case "Odak":
        return {
          "icon": Icons.center_focus_strong_rounded,
          "color": const Color(0xFFA855F7),
        };

      case "İrade":
        return {
          "icon": Icons.local_fire_department_rounded,
          "color": const Color(0xFFF97316),
        };

      case "Zihinsel":
        return {
          "icon": Icons.psychology_rounded,
          "color": const Color(0xFFEAB308),
        };

      case "Disiplin":
        return {"icon": Icons.shield_rounded, "color": const Color(0xFF60A5FA)};

      default:
        return {"icon": Icons.bolt_rounded, "color": const Color(0xFF3B82F6)};
    }
  }
}

class _AnimatedChallengeGlow extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedChallengeGlow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,

      builder: (context, child) {
        return Transform.rotate(
          angle: controller.value * 6.28,

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
        );
      },
    );
  }
}
