import 'dart:ui';
import 'package:flutter/material.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final Map<String, String> _answers = {};
  String? _resultTitle;
  String? _resultText;
  String? _resultType;

  final List<_CheckQuestion> _questions = const [
    _CheckQuestion(
      id: "energy",
      title: "Bugünkü enerjin nasıl?",
      options: ["Düşük", "Orta", "Yüksek"],
    ),
    _CheckQuestion(
      id: "goal",
      title: "Bugünkü hedefin ne?",
      options: ["Yağ yakım", "Kas", "Kondisyon", "Recovery"],
    ),
    _CheckQuestion(
      id: "time",
      title: "Ne kadar vaktin var?",
      options: ["15 dk", "30 dk", "45+ dk"],
    ),
    _CheckQuestion(
      id: "place",
      title: "Nerede çalışacaksın?",
      options: ["Ev", "Salon", "Dışarı"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _createRecommendation() {
    if (_answers.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0F172A),
          content: Text("PACE Check-In için tüm soruları cevapla."),
        ),
      );
      return;
    }

    final energy = _answers["energy"];
    final goal = _answers["goal"];
    final time = _answers["time"];
    final place = _answers["place"];

    String title = "Dengeli Performans";
    String type = "PACE PLAN";
    String text =
        "Bugün dengeli bir antrenman senin için ideal. Isınma, ana egzersiz ve kısa esneme ile kontrollü ilerleyebilirsin.";

    if (energy == "Düşük" || goal == "Recovery") {
      title = "Hafif Tempo Günü";
      type = "RECOVERY";
      text =
          "Bugün vücudunu çok zorlamadan ilerle. Hafif yürüyüş, mobility ve core aktivasyonu daha doğru olur.";
    } else if (goal == "Kas") {
      title = "Güç Odaklı Plan";
      type = "STRENGTH";
      text =
          "Bugün temel hareketlere odaklan. Squat, press, row ve kontrollü setlerle kas gelişimini destekleyebilirsin.";
    } else if (goal == "Yağ yakım") {
      title = "Yağ Yakım Seansı";
      type = "BURN";
      text =
          "Bugün kısa dinlenmeli full-body hareketler ve tempolu kardiyo iyi gider. Nabzı kontrollü şekilde yükselt.";
    } else if (goal == "Kondisyon") {
      title = "Kondisyon Boost";
      type = "CARDIO";
      text =
          "Bugün interval yürüyüş, koşu, bisiklet veya ip atlama ile kondisyon seviyeni yukarı çekebilirsin.";
    }

    if (time == "15 dk") {
      text += " Süren kısa olduğu için 15 dakikalık kompakt bir plan seç.";
    } else if (time == "30 dk") {
      text += " 30 dakikalık orta yoğunlukta bir seans yeterli olur.";
    } else {
      text += " 45 dakika ve üzeri vaktin varsa antrenman sonuna esneme ekle.";
    }

    if (place == "Ev") {
      text += " Evde vücut ağırlığı hareketleriyle ilerle.";
    } else if (place == "Salon") {
      text += " Salonda makine ve serbest ağırlıkları kontrollü kullan.";
    } else {
      text += " Dışarıda yürüyüş, koşu veya merdiven iyi seçim olur.";
    }

    setState(() {
      _resultTitle = title;
      _resultType = type;
      _resultText = text;
    });
  }

  void _resetCheckIn() {
    setState(() {
      _answers.clear();
      _resultTitle = null;
      _resultType = null;
      _resultText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          const _SocialGlowBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 14),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildFeed(), _buildCheckIn(), _buildFriends()],
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
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SOSYAL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Topluluk, paylaşım ve günlük analiz",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _glassIcon(Icons.notifications_none_rounded),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.35),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(text: "Akış"),
          Tab(text: "Check-In"),
          Tab(text: "Arkadaş"),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      physics: const BouncingScrollPhysics(),
      children: const [
        _SocialSummaryCard(),
        SizedBox(height: 18),
        _SectionTitle(title: "TOPLULUK AKIŞI"),
        SizedBox(height: 12),
        _FeedCard(
          name: "Mert",
          tag: "ANTRENMAN",
          title: "Push günü tamamlandı",
          subtitle: "Göğüs + Omuz + Triceps • 52 dk",
          stat: "Tamamlandı",
          icon: Icons.fitness_center_rounded,
        ),
        _FeedCard(
          name: "Zeynep",
          tag: "CHECK-IN",
          title: "Bugünkü önerisini paylaştı",
          subtitle: "Recovery günü: mobility + yürüyüş",
          stat: "12 beğeni",
          icon: Icons.psychology_alt_rounded,
        ),
        _FeedCard(
          name: "Can",
          tag: "CHALLENGE",
          title: "100 squat challenge bitti",
          subtitle: "Seri bozulmadan görev tamamlandı",
          stat: "Yeni paylaşım",
          icon: Icons.workspace_premium_rounded,
        ),
      ],
    );
  }

  Widget _buildCheckIn() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        const _CheckInHero(),
        const SizedBox(height: 18),
        const _SectionTitle(title: "GÜNLÜK DURUM ANALİZİ"),
        const SizedBox(height: 12),
        ..._questions.map(_buildQuestion),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _createRecommendation,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.35),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Önerimi Oluştur",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _resetCheckIn,
              child: Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: const Icon(Icons.refresh_rounded, color: Colors.white70),
              ),
            ),
          ],
        ),
        if (_resultText != null) ...[
          const SizedBox(height: 18),
          _ResultCard(
            title: _resultTitle!,
            type: _resultType!,
            text: _resultText!,
          ),
        ],
      ],
    );
  }

  Widget _buildQuestion(_CheckQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: question.options.map((option) {
              final selected = _answers[question.id] == option;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _answers[question.id] = option;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF3B82F6)
                        : Colors.white.withOpacity(0.045),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF60A5FA)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFriends() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      physics: const BouncingScrollPhysics(),
      children: const [
        _SearchFriendBox(),
        SizedBox(height: 18),
        _SectionTitle(title: "AKTİF ARKADAŞLAR"),
        SizedBox(height: 12),
        _FriendCard(
          name: "Zeynep",
          status: "Bugün aktif",
          detail: "Son aktivite: Recovery Check-In",
        ),
        _FriendCard(
          name: "Mert",
          status: "Antrenmanda",
          detail: "Son aktivite: Push günü",
        ),
        _FriendCard(
          name: "Ece",
          status: "Challenge tamamladı",
          detail: "Son aktivite: 10K adım",
        ),
      ],
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
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Icon(icon, color: Colors.white70, size: 19),
        ),
      ),
    );
  }
}

BoxDecoration _glassCardDecoration() {
  return BoxDecoration(
    color: const Color(0xFF0F172A).withOpacity(0.88),
    borderRadius: BorderRadius.circular(25),
    border: Border.all(color: Colors.white.withOpacity(0.06)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 22,
        offset: const Offset(0, 12),
      ),
    ],
  );
}

class _SocialGlowBackground extends StatelessWidget {
  const _SocialGlowBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -110,
          right: -90,
          child: _GlowBlob(
            size: 260,
            color: const Color(0xFF3B82F6).withOpacity(0.22),
          ),
        ),
        Positioned(
          bottom: -140,
          left: -90,
          child: _GlowBlob(
            size: 290,
            color: const Color(0xFF8B5CF6).withOpacity(0.13),
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 95, spreadRadius: 45)],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white24,
        fontSize: 10,
        letterSpacing: 2.4,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SocialSummaryCard extends StatelessWidget {
  const _SocialSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: _glassCardDecoration(),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.13),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Color(0xFF60A5FA),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PACE Community",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Arkadaşlarınla gelişimini paylaş, günlük durumunu analiz et.",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    height: 1.35,
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

class _FeedCard extends StatelessWidget {
  final String name;
  final String tag;
  final String title;
  final String subtitle;
  final String stat;
  final IconData icon;

  const _FeedCard({
    required this.name,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.stat,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.15),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Color(0xFF60A5FA),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                tag,
                style: const TextStyle(
                  color: Color(0xFF60A5FA),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(icon, color: Colors.white24, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                stat,
                style: const TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.favorite_border_rounded,
                color: Colors.white24,
                size: 20,
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.mode_comment_outlined,
                color: Colors.white24,
                size: 19,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckInHero extends StatelessWidget {
  const _CheckInHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.psychology_alt_rounded,
            color: Color(0xFF60A5FA),
            size: 35,
          ),
          SizedBox(height: 14),
          Text(
            "PACE Check-In",
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            "Kısa sorularla bugünkü durumunu analiz eder ve sana uygun antrenman önerisi üretir.",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String type;
  final String text;

  const _ResultCard({
    required this.title,
    required this.type,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.16),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: const TextStyle(
              color: Color(0xFF60A5FA),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.045),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Center(
              child: Text(
                "Sonucu Akışta Paylaş",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchFriendBox extends StatelessWidget {
  const _SearchFriendBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _glassCardDecoration(),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.white30),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Arkadaş ara...",
              style: TextStyle(
                color: Colors.white30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF60A5FA)),
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final String name;
  final String status;
  final String detail;

  const _FriendCard({
    required this.name,
    required this.status,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.14),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Color(0xFF60A5FA),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  height: 11,
                  width: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(color: Colors.white30, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        ],
      ),
    );
  }
}

class _CheckQuestion {
  final String id;
  final String title;
  final List<String> options;

  const _CheckQuestion({
    required this.id,
    required this.title,
    required this.options,
  });
}
