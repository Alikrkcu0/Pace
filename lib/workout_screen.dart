import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Map<String, List<Map<String, dynamic>>> _weeklySchedule = {
    "Pzt": [],
    "Sal": [],
    "Çar": [],
    "Per": [],
    "Cum": [],
    "Cmt": [],
    "Paz": [],
  };

  String _selectedDay = "Pzt";

  final Map<String, Map<String, dynamic>> _bodyPartMeta = {
    "Göğüs": {
      "image": "assets/muscles/gogus.png",
      "subtitle": "İtiş gücü ve hacim",
    },
    "Sırt": {
      "image": "assets/muscles/SIRT.png",
      "subtitle": "Genişlik ve kalınlık",
    },
    "Omuz": {"image": "assets/muscles/omuz.png", "subtitle": "Geniş görünüm"},
    "Bacak": {
      "image": "assets/muscles/bacak.png",
      "subtitle": "Alt vücut gücü",
    },
    "Kol": {"image": "assets/muscles/kol.png", "subtitle": "Biceps & triceps"},
    "Bilek": {
      "image": "assets/muscles/bilek.png",
      "subtitle": "Ön kol ve tutuş",
    },
  };

  final Map<String, List<Map<String, dynamic>>> _exerciseLibrary = {
    "Göğüs": [
      {
        "name": "Flat Bench Press",
        "icon": Icons.fitness_center,
        "desc":
            "🎯 Hedef: Tüm göğüs, ön omuz ve triceps\n\n"
            "1. Sehpaya sırt üstü uzan, ayaklarını yere sağlam bas.\n"
            "2. Barı omuz genişliğinden biraz daha geniş tut.\n"
            "3. Barı kontrollü şekilde göğsünün orta hizasına indir.\n"
            "4. Göğsünü sıkıp barı yukarı doğru güçlü şekilde it.\n"
            "5. Dirseklerini tamamen kilitlemeden hareketi tekrar et.\n\n"
            "⚠️ Belini aşırı kamburlaştırma, barı sektirme.",
      },
      {
        "name": "Incline Dumbbell Press",
        "icon": Icons.trending_up,
        "desc":
            "🎯 Hedef: Üst göğüs, ön omuz ve triceps\n\n"
            "1. Sehpayı yaklaşık 30-45 derece eğime getir.\n"
            "2. Dumbbelları göğüs üst hizasında tutarak başlangıç pozisyonu al.\n"
            "3. Ağırlıkları kontrollü şekilde aşağı indir.\n"
            "4. Üst göğsünü sıkarak dumbbelları yukarı doğru it.\n"
            "5. Tepede dumbbelları çarpıştırmadan kontrollü şekilde tekrar indir.\n\n"
            "⚠️ Sehpa açısını çok dik yaparsan omuz daha fazla devreye girer.",
      },
      {
        "name": "Decline Bench Press",
        "icon": Icons.trending_down,
        "desc":
            "🎯 Hedef: Alt göğüs ve itiş gücü\n\n"
            "1. Decline sehpaya uzan ve ayaklarını sabitle.\n"
            "2. Barı omuz genişliğinden biraz geniş kavra.\n"
            "3. Barı alt göğüs hizasına kontrollü indir.\n"
            "4. Göğsünü sıkarak barı yukarı doğru it.\n"
            "5. Hareket boyunca bileklerini düz tut.\n\n"
            "⚠️ Ağır kilolarda mutlaka güvenlik desteği kullan.",
      },
      {
        "name": "Cable Fly",
        "icon": Icons.unfold_more,
        "desc":
            "🎯 Hedef: İç göğüs, göğüs sıkıştırma ve form\n\n"
            "1. Kablo makaralarını göğüs hizasına veya biraz yukarı ayarla.\n"
            "2. Kollarını hafif kırık tutarak öne doğru pozisyon al.\n"
            "3. Elleri yay çizer gibi göğüs önünde birleştir.\n"
            "4. Tepede göğsünü 1 saniye sık.\n"
            "5. Kolları kontrollü şekilde tekrar yana aç.\n\n"
            "⚠️ Dirsekleri fazla bükme, hareketi omuzla değil göğüsle yap.",
      },
      {
        "name": "Chest Press (Machine)",
        "icon": Icons.settings,
        "desc":
            "🎯 Hedef: Göğüs kası ve kontrollü itiş\n\n"
            "1. Makinenin koltuğunu tutamaklar göğüs hizasına gelecek şekilde ayarla.\n"
            "2. Sırtını tamamen yasla ve göğsünü dik tut.\n"
            "3. Tutamakları öne doğru güçlü ama kontrollü şekilde it.\n"
            "4. Tepede dirseklerini kilitlemeden dur.\n"
            "5. Ağırlığı yavaşça başlangıç pozisyonuna getir.\n\n"
            "⚠️ Ağırlığı bırakma; dönüş kısmını da kontrol et.",
      },
      {
        "name": "Dips",
        "icon": Icons.vertical_align_bottom,
        "desc":
            "🎯 Hedef: Alt göğüs, triceps ve omuz stabilitesi\n\n"
            "1. Paralel barlara tutun ve vücudunu yukarı kaldır.\n"
            "2. Göğüs odaklı çalışmak için hafif öne eğil.\n"
            "3. Dirseklerini bükerek kontrollü şekilde aşağı in.\n"
            "4. Göğsünü ve tricepsini kullanarak tekrar yukarı çık.\n"
            "5. Hareket boyunca omuzlarını kulaklarına yaklaştırma.\n\n"
            "⚠️ Çok aşağı inmek omuzları zorlayabilir.",
      },
    ],
    "Sırt": [
      {
        "name": "Deadlift",
        "icon": Icons.straighten,
        "desc":
            "🎯 Hedef: Sırt, kalça, hamstring ve core\n\n"
            "1. Barı ayaklarının orta hizasına yerleştir.\n"
            "2. Kalçanı geriye al, sırtını düz tut ve barı kavra.\n"
            "3. Göğsünü yukarı çıkar, core bölgeni sık.\n"
            "4. Barı vücuduna yakın tutarak bacaklarınla yerden kaldır.\n"
            "5. Tepede dik dur, sonra barı kontrollü şekilde yere indir.\n\n"
            "⚠️ Sırtını yuvarlama; hareket belden değil kalça ve bacaklardan gelmeli.",
      },
      {
        "name": "Lat Pulldown",
        "icon": Icons.arrow_downward,
        "desc":
            "🎯 Hedef: Kanat kasları ve sırt genişliği\n\n"
            "1. Barı omuz genişliğinden biraz geniş tut.\n"
            "2. Göğsünü yukarı çıkar ve hafif geriye yaslan.\n"
            "3. Barı çene altına değil, üst göğüs hizasına çek.\n"
            "4. Aşağıda sırtını sık, dirseklerini geriye doğru götür.\n"
            "5. Barı yavaşça yukarı bırak ve kanatların esnemesine izin ver.\n\n"
            "⚠️ Barı enseye çekme; boyun ve omuz için risklidir.",
      },
      {
        "name": "Bent Over Row",
        "icon": Icons.waves,
        "desc":
            "🎯 Hedef: Sırt kalınlığı, trapez ve arka omuz\n\n"
            "1. Dizlerini hafif kır ve kalçanı geriye al.\n"
            "2. Gövdeni öne eğ, sırtını düz tut.\n"
            "3. Barı veya dumbbelları karın hizana doğru çek.\n"
            "4. Dirsekleri geriye götürerek kürek kemiklerini sık.\n"
            "5. Ağırlığı kontrollü şekilde aşağı indir.\n\n"
            "⚠️ Belini oynatma, momentum kullanma.",
      },
      {
        "name": "Seated Row",
        "icon": Icons.settings_ethernet,
        "desc":
            "🎯 Hedef: Orta sırt ve kürek kemiği kontrolü\n\n"
            "1. Makineye otur ve ayaklarını sabitle.\n"
            "2. Tutacağı kavra, sırtını dik ve göğsünü açık tut.\n"
            "3. Tutacağı karnına doğru çek.\n"
            "4. Dirseklerini geriye götürüp kürek kemiklerini sık.\n"
            "5. Kontrollü şekilde başlangıca dön.\n\n"
            "⚠️ Geriye fazla yaslanıp belden çekme.",
      },
      {
        "name": "Pull-ups",
        "icon": Icons.upload,
        "desc":
            "🎯 Hedef: Kanat, biceps ve üst sırt\n\n"
            "1. Barı omuz genişliğinden biraz geniş kavra.\n"
            "2. Vücudunu sallamadan core bölgeni sık.\n"
            "3. Dirseklerini aşağı doğru çekerek kendini yukarı kaldır.\n"
            "4. Çenen bar hizasına yaklaşınca sırtını sık.\n"
            "5. Kontrollü şekilde tamamen sarkmadan aşağı in.\n\n"
            "⚠️ Sallanarak tekrar yapmak yerine kontrollü tekrar yap.",
      },
      {
        "name": "T-Bar Row",
        "icon": Icons.architecture,
        "desc":
            "🎯 Hedef: Sırt kalınlığı ve orta sırt\n\n"
            "1. Ayaklarını sabitle ve gövdeni öne eğ.\n"
            "2. Tutacağı sıkıca kavra, sırtını düz tut.\n"
            "3. Ağırlığı gövdene doğru çek.\n"
            "4. Tepede kürek kemiklerini güçlü şekilde sık.\n"
            "5. Ağırlığı kontrollü şekilde aşağı bırak.\n\n"
            "⚠️ Belden savurma yapma, sırt açını koru.",
      },
    ],
    "Omuz": [
      {
        "name": "Military Press",
        "icon": Icons.upgrade,
        "desc":
            "🎯 Hedef: Ön omuz, yan omuz ve triceps\n\n"
            "1. Barı üst göğüs hizasında omuz genişliğinde tut.\n"
            "2. Core bölgeni sık ve belini aşırı geriye yatırma.\n"
            "3. Barı başının üstüne doğru düz bir çizgide it.\n"
            "4. Tepede dirseklerini kilitlemeden kontrol et.\n"
            "5. Barı yavaşça başlangıç pozisyonuna indir.\n\n"
            "⚠️ Bel çukurunu aşırı artırma; karın kaslarını sık.",
      },
      {
        "name": "Lateral Raise",
        "icon": Icons.swap_horiz,
        "desc":
            "🎯 Hedef: Yan omuz ve geniş omuz görünümü\n\n"
            "1. Dumbbelları yanlarında tut, dizleri hafif kır.\n"
            "2. Dirsekleri hafif bükülü tut.\n"
            "3. Kolları yana doğru omuz hizasına kadar kaldır.\n"
            "4. Tepede kısa süre kontrol et.\n"
            "5. Ağırlıkları yavaşça aşağı indir.\n\n"
            "⚠️ Çok ağır kilo seçip trapezle kaldırma.",
      },
      {
        "name": "Rear Delt Fly",
        "icon": Icons.settings_overscan,
        "desc":
            "🎯 Hedef: Arka omuz ve postür desteği\n\n"
            "1. Gövdeni öne eğ veya reverse pec deck makinesine otur.\n"
            "2. Kollarını hafif kırık tut.\n"
            "3. Ağırlıkları yana ve geriye doğru aç.\n"
            "4. Tepede arka omuzlarını sık.\n"
            "5. Kontrollü şekilde başlangıca dön.\n\n"
            "⚠️ Hareketi sırtla değil arka omuzla hissetmeye çalış.",
      },
      {
        "name": "Arnold Press",
        "icon": Icons.autorenew,
        "desc":
            "🎯 Hedef: Ön, yan omuz ve stabilizasyon\n\n"
            "1. Dumbbelları avuç içlerin sana bakacak şekilde çene hizasında tut.\n"
            "2. Yukarı iterken bileklerini dışa doğru döndür.\n"
            "3. Dumbbelları baş üstüne kadar kaldır.\n"
            "4. Tepede kontrollü dur.\n"
            "5. Aynı rotasyonla başlangıç pozisyonuna dön.\n\n"
            "⚠️ Hareketi hızlı değil kontrollü ve akıcı yap.",
      },
      {
        "name": "Front Raise",
        "icon": Icons.north,
        "desc":
            "🎯 Hedef: Ön omuz\n\n"
            "1. Dumbbelları veya plakayı önünde tut.\n"
            "2. Core bölgeni sık ve dik dur.\n"
            "3. Ağırlığı omuz hizasına kadar kaldır.\n"
            "4. Tepede kısa süre kontrol et.\n"
            "5. Ağırlığı yavaşça aşağı indir.\n\n"
            "⚠️ Belden savurarak kaldırma.",
      },
    ],
    "Bacak": [
      {
        "name": "Back Squat",
        "icon": Icons.accessibility_new,
        "desc":
            "🎯 Hedef: Quadriceps, kalça, hamstring ve core\n\n"
            "1. Barı trapez kaslarının üstüne rahatça yerleştir.\n"
            "2. Ayaklarını omuz genişliğinde aç.\n"
            "3. Kalçanı geriye ve aşağıya doğru indir.\n"
            "4. Dizlerini ayak uçlarınla aynı yöne doğru takip ettir.\n"
            "5. Topuklarından güç alarak tekrar yukarı kalk.\n\n"
            "⚠️ Dizlerin içeri kapanmasın, sırtını düz tut.",
      },
      {
        "name": "Leg Press",
        "icon": Icons.layers,
        "desc":
            "🎯 Hedef: Ön bacak, kalça ve hamstring\n\n"
            "1. Makineye otur ve sırtını tamamen yasla.\n"
            "2. Ayaklarını platforma omuz genişliğinde yerleştir.\n"
            "3. Platformu kontrollü şekilde aşağı indir.\n"
            "4. Dizlerin göğsüne yaklaşınca kontrollü dur.\n"
            "5. Topuklarından güç alarak platformu yukarı it.\n\n"
            "⚠️ Dizlerini tepede tamamen kilitleme.",
      },
      {
        "name": "Leg Extension",
        "icon": Icons.shutter_speed,
        "desc":
            "🎯 Hedef: Ön bacak izolasyonu\n\n"
            "1. Makineye otur ve sırtını yasla.\n"
            "2. Pedleri ayak bileği hizasına ayarla.\n"
            "3. Bacaklarını yukarı doğru düzleştir.\n"
            "4. Tepede quadriceps kasını 1 saniye sık.\n"
            "5. Ağırlığı kontrollü şekilde aşağı indir.\n\n"
            "⚠️ Ağırlığı savurma, dizlerini zorlayacak kilolardan kaçın.",
      },
      {
        "name": "Leg Curl",
        "icon": Icons.airline_seat_flat,
        "desc":
            "🎯 Hedef: Arka bacak yani hamstring\n\n"
            "1. Makineye doğru pozisyonda yerleş.\n"
            "2. Pedleri ayak bileğinin arkasına hizala.\n"
            "3. Topuklarını kalçana doğru çek.\n"
            "4. Tepede hamstring kasını sık.\n"
            "5. Ağırlığı yavaşça başlangıca bırak.\n\n"
            "⚠️ Kalçanı makineden kaldırma.",
      },
      {
        "name": "Romanian Deadlift",
        "icon": Icons.straighten,
        "desc":
            "🎯 Hedef: Hamstring, kalça ve bel stabilitesi\n\n"
            "1. Barı veya dumbbelları önünde tut.\n"
            "2. Dizlerini hafif kır, sırtını düz tut.\n"
            "3. Kalçanı geriye iterek ağırlığı aşağı indir.\n"
            "4. Hamstringlerinde gerilme hissedince dur.\n"
            "5. Kalçanı öne sürerek başlangıca dön.\n\n"
            "⚠️ Sırtını yuvarlama, hareket kalçadan başlamalı.",
      },
      {
        "name": "Calf Raise",
        "icon": Icons.vertical_align_top,
        "desc":
            "🎯 Hedef: Kalf kasları\n\n"
            "1. Ayak uçlarını platforma veya yere sağlam yerleştir.\n"
            "2. Topuklarını kontrollü şekilde aşağı indir.\n"
            "3. Ayak uçlarından güç alarak yüksel.\n"
            "4. Tepede kalf kaslarını 1 saniye sık.\n"
            "5. Kontrollü şekilde tekrar aşağı in.\n\n"
            "⚠️ Yarım tekrar yerine tam hareket açıklığı kullan.",
      },
    ],
    "Kol": [
      {
        "name": "Barbell Curl",
        "icon": Icons.add_task,
        "desc":
            "🎯 Hedef: Biceps yani pazı\n\n"
            "1. Barı omuz genişliğinde kavra.\n"
            "2. Dirseklerini vücudunun yanında sabit tut.\n"
            "3. Barı kontrollü şekilde yukarı kaldır.\n"
            "4. Tepede biceps kasını sık.\n"
            "5. Barı yavaşça başlangıç pozisyonuna indir.\n\n"
            "⚠️ Belden savurma yapma.",
      },
      {
        "name": "Hammer Curl",
        "icon": Icons.gavel,
        "desc":
            "🎯 Hedef: Brachialis, ön kol ve biceps\n\n"
            "1. Dumbbelları avuç içlerin birbirine bakacak şekilde tut.\n"
            "2. Dirseklerini vücudunun yanında sabitle.\n"
            "3. Ağırlıkları yukarı doğru kaldır.\n"
            "4. Tepede kolunu sık.\n"
            "5. Kontrollü şekilde aşağı indir.\n\n"
            "⚠️ Bileklerini döndürmeden nötr pozisyonda tut.",
      },
      {
        "name": "Preacher Curl",
        "icon": Icons.airline_seat_recline_normal,
        "desc":
            "🎯 Hedef: İzole biceps çalışması\n\n"
            "1. Preacher sehpasına otur ve kollarını pede yerleştir.\n"
            "2. Barı veya dumbbellı kontrollü şekilde kavra.\n"
            "3. Ağırlığı yukarı kaldırırken dirseklerini oynatma.\n"
            "4. Tepede biceps kasını sık.\n"
            "5. Ağırlığı tamamen kontrol ederek aşağı indir.\n\n"
            "⚠️ En altta dirseklerini sert şekilde kilitleme.",
      },
      {
        "name": "Triceps Pushdown",
        "icon": Icons.arrow_downward,
        "desc":
            "🎯 Hedef: Triceps yani arka kol\n\n"
            "1. Kablo makinesinde barı veya ipi kavra.\n"
            "2. Dirseklerini gövdene yakın ve sabit tut.\n"
            "3. Barı aşağı doğru iterek kollarını düzleştir.\n"
            "4. Altta triceps kasını sık.\n"
            "5. Kontrollü şekilde başlangıç pozisyonuna dön.\n\n"
            "⚠️ Omuzlarını oynatma, hareket sadece dirsekten gelsin.",
      },
      {
        "name": "Skull Crusher",
        "icon": Icons.psychology,
        "desc":
            "🎯 Hedef: Triceps uzun başı\n\n"
            "1. Sehpaya uzan ve EZ barı veya dumbbelları tut.\n"
            "2. Kollarını yukarıda sabit pozisyona getir.\n"
            "3. Dirseklerini bükerek ağırlığı alnına doğru indir.\n"
            "4. Tricepsini kullanarak ağırlığı tekrar yukarı it.\n"
            "5. Hareket boyunca dirseklerini fazla açma.\n\n"
            "⚠️ Ağırlığı yüzüne düşürmemek için kontrollü çalış.",
      },
      {
        "name": "Overhead Extension",
        "icon": Icons.vertical_align_top,
        "desc":
            "🎯 Hedef: Triceps uzun başı\n\n"
            "1. Dumbbellı iki elle başının üzerinde tut.\n"
            "2. Dirseklerini mümkün olduğunca sabit tut.\n"
            "3. Ağırlığı başının arkasına doğru indir.\n"
            "4. Tricepsini kullanarak ağırlığı tekrar yukarı kaldır.\n"
            "5. Tepede kolunu kontrollü şekilde düzleştir.\n\n"
            "⚠️ Belini aşırı çukurlaştırma.",
      },
    ],
    "Bilek": [
      {
        "name": "Wrist Curl",
        "icon": Icons.pan_tool_alt,
        "desc":
            "🎯 Hedef: Ön kol ve bilek fleksörleri\n\n"
            "1. Ön kollarını dizlerine veya sehpaya yerleştir.\n"
            "2. Avuç içlerin yukarı bakacak şekilde ağırlığı tut.\n"
            "3. Bileğini aşağı doğru kontrollü indir.\n"
            "4. Bileğini yukarı doğru bükerek ağırlığı kaldır.\n"
            "5. Tepede ön kolunu sık ve tekrar indir.\n\n"
            "⚠️ Hareketi kolunla değil sadece bileğinle yap.",
      },
      {
        "name": "Farmer's Walk",
        "icon": Icons.directions_walk,
        "desc":
            "🎯 Hedef: Tutuş gücü, ön kol, trapez ve core\n\n"
            "1. İki eline ağır dumbbell veya kettlebell al.\n"
            "2. Göğsünü dik tut ve omuzlarını geriye al.\n"
            "3. Core bölgeni sık ve kontrollü adımlarla yürü.\n"
            "4. Ağırlıkların vücuduna çarpmasına izin verme.\n"
            "5. Belirlenen mesafe veya süre boyunca formunu koru.\n\n"
            "⚠️ Öne eğilme, omuzları düşürme.",
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_workout_schedule', jsonEncode(_weeklySchedule));

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    try {
      await Supabase.instance.client
          .from('workout_logs')
          .delete()
          .eq('user_id', user.id);

      for (final dayEntry in _weeklySchedule.entries) {
        final day = dayEntry.key;
        final exercises = dayEntry.value;

        for (final ex in exercises) {
          final sets = List<Map<String, dynamic>>.from(ex['sets'] ?? []);

          for (final set in sets) {
            await Supabase.instance.client.from('workout_logs').insert({
              'user_id': user.id,
              'workout_day': day,
              'exercise_name': ex['name'],
              'sets': 1,
              'reps': set['rep'],
              'weight': set['kg'],
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Supabase workout save error: $e");
    }
  }

  Future<void> _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString('user_workout_schedule');

    if (savedData != null) {
      final decoded = jsonDecode(savedData) as Map<String, dynamic>;

      setState(() {
        _weeklySchedule = decoded.map(
          (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
        );
      });
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('workout_logs')
          .select()
          .eq('user_id', user.id);

      Map<String, List<Map<String, dynamic>>> loadedSchedule = {
        "Pzt": [],
        "Sal": [],
        "Çar": [],
        "Per": [],
        "Cum": [],
        "Cmt": [],
        "Paz": [],
      };

      for (final item in data) {
        final day = item['workout_day'];

        final existingExercise = loadedSchedule[day]!.firstWhere(
          (e) => e['name'] == item['exercise_name'],
          orElse: () => {},
        );

        if (existingExercise.isEmpty) {
          loadedSchedule[day]!.add({
            "name": item['exercise_name'],
            "sets": [
              {"kg": (item['weight'] as num).toDouble(), "rep": item['reps']},
            ],
          });
        } else {
          existingExercise['sets'].add({
            "kg": (item['weight'] as num).toDouble(),
            "rep": item['reps'],
          });
        }
      }

      setState(() {
        _weeklySchedule = loadedSchedule;
      });
    } catch (e) {
      debugPrint("Supabase workout load error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDayList = _weeklySchedule[_selectedDay]!;
    final totalSets = currentDayList.fold<int>(
      0,
      (sum, ex) => sum + ((ex['sets'] as List?)?.length ?? 0),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildDaySelector(),
                        const SizedBox(height: 22),
                        _buildSummaryCard(currentDayList.length, totalSets),
                        const SizedBox(height: 24),
                        _buildSectionTitle("BUGÜNÜN PLANI"),
                        const SizedBox(height: 14),
                        if (currentDayList.isEmpty)
                          _buildEmptyState()
                        else
                          ...List.generate(
                            currentDayList.length,
                            (index) => _buildExerciseCard(
                              currentDayList[index],
                              index,
                              currentDayList,
                            ),
                          ),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomAddButton(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        Positioned(top: -120, right: -100, child: _glowCircle(320, 0.08)),
        Positioned(bottom: -180, left: -100, child: _glowCircle(360, 0.05)),
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
        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 20, 0),
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
              "PACE TRAINING",
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
          "ANTRENMAN",
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontSize: 10,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Programını Yönet",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Bölge seç, hareket ekle, setlerini takip et.",
          style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _weeklySchedule.keys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = _weeklySchedule.keys.elementAt(index);
          final isSelected = _selectedDay == day;
          final count = _weeklySchedule[day]!.length;

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 58,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$count",
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white70
                          : Colors.white.withOpacity(0.18),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int exerciseCount, int totalSets) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFF3B82F6), size: 34),
          const SizedBox(width: 18),
          Text(
            "$exerciseCount hareket • $totalSets set",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
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
        fontWeight: FontWeight.w900,
        letterSpacing: 2.5,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.65),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Center(
        child: Text(
          "PLAN BOŞ",
          style: TextStyle(
            color: Colors.white24,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    Map<String, dynamic> ex,
    int exIndex,
    List<Map<String, dynamic>> currentDayList,
  ) {
    final sets = List<Map<String, dynamic>>.from(ex['sets'] ?? []);
    final category = ex['category'] ?? _findCategoryByExerciseName(ex['name']);
    final meta = _bodyPartMeta[category];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 12, 14),
            child: Row(
              children: [
                Icon(
                  meta?["icon"] ?? Icons.fitness_center_rounded,
                  color: const Color(0xFF3B82F6),
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    ex['name'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showTutorial(ex['name']),
                  icon: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => currentDayList.removeAt(exIndex));
                    _saveSchedule();
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(
            sets.length,
            (sIndex) => _buildSetRow(
              currentDayList[exIndex]['sets'][sIndex],
              sIndex,
              currentDayList[exIndex]['sets'],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currentDayList[exIndex]['sets'].add({"kg": 20.0, "rep": 10});
              });
              _saveSchedule();
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  "+ SET EKLE",
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(Map<String, dynamic> set, int sIndex, List allSets) {
    final double kg = (set['kg'] as num).toDouble();
    final int rep = (set['rep'] as num).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "${sIndex + 1}. SET",
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() => allSets.removeAt(sIndex));
                  _saveSchedule();
                },
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white24,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEditableValueBox(
                  label: "KİLO",
                  value: kg.toStringAsFixed(1),
                  unit: "KG",
                  onTap: () {
                    _showNumberInputSheet(
                      title: "KİLO GİR",
                      initialValue: kg.toStringAsFixed(1),
                      isDecimal: true,
                      onSave: (value) {
                        final parsed = double.tryParse(
                          value.replaceAll(',', '.'),
                        );

                        if (parsed == null) return;

                        setState(() {
                          set['kg'] = parsed.clamp(0.0, 500.0);
                        });

                        _saveSchedule();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEditableValueBox(
                  label: "TEKRAR",
                  value: rep.toString(),
                  unit: "REP",
                  onTap: () {
                    _showNumberInputSheet(
                      title: "TEKRAR GİR",
                      initialValue: rep.toString(),
                      isDecimal: false,
                      onSave: (value) {
                        final parsed = int.tryParse(value);

                        if (parsed == null) return;

                        setState(() {
                          set['rep'] = parsed.clamp(1, 100);
                        });

                        _saveSchedule();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableValueBox({
    required String label,
    required String value,
    required String unit,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.025),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: TextStyle(
                color: Colors.white.withOpacity(0.28),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Düzenlemek için dokun",
              style: TextStyle(
                color: Colors.white.withOpacity(0.18),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNumberInputSheet({
    required String title,
    required String initialValue,
    required bool isDecimal,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: isDecimal,
                  signed: false,
                ),
                textAlign: TextAlign.center,
                cursorColor: const Color(0xFF3B82F6),
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  onSave(value);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  onSave(controller.text);
                  Navigator.pop(context);
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      "KAYDET",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomAddButton() {
    return Positioned(
      left: 22,
      right: 22,
      bottom: 22,
      child: GestureDetector(
        onTap: _showBodyPartPicker,
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              "+ HAREKET EKLE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBodyPartPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF020408),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  const Text(
                    "BÖLGE SEÇ",
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hangi bölgeyi çalışıyoruz?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _exerciseLibrary.keys.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.92,
                        ),
                    itemBuilder: (context, index) {
                      final category = _exerciseLibrary.keys.elementAt(index);
                      return _buildBodyPartCard(category);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBodyPartCard(String category) {
    final meta = _bodyPartMeta[category]!;
    final availableCount = _exerciseLibrary[category]!
        .where(
          (ex) => !_weeklySchedule[_selectedDay]!.any(
            (s) => s['name'] == ex['name'],
          ),
        )
        .length;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showExerciseList(category);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          image: DecorationImage(
            image: AssetImage(meta["image"]),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(meta["icon"], color: const Color(0xFF3B82F6), size: 30),
                  const Spacer(),
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$availableCount hareket uygun",
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
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

  void _showExerciseList(String category) {
    final availableExercises = _exerciseLibrary[category]!
        .where(
          (ex) => !_weeklySchedule[_selectedDay]!.any(
            (s) => s['name'] == ex['name'],
          ),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF020408),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hareket Seç",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ...availableExercises.map(
                    (item) => _buildExercisePickTile(category, item),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExercisePickTile(String category, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _weeklySchedule[_selectedDay]!.add({
            "name": item['name'],
            "category": category,
            "sets": [
              {"kg": 20.0, "rep": 10},
            ],
          });
        });
        _saveSchedule();
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(item["icon"], color: const Color(0xFF3B82F6), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item["name"],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  void _showTutorial(String name) {
    String description = "Rehber henüz eklenmedi.";

    _exerciseLibrary.forEach((key, value) {
      for (final ex in value) {
        if (ex['name'] == name) description = ex['desc'];
      }
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "HAREKET REHBERİ",
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 26),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "ANLADIM",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _findCategoryByExerciseName(String name) {
    for (final entry in _exerciseLibrary.entries) {
      for (final ex in entry.value) {
        if (ex['name'] == name) return entry.key;
      }
    }
    return "Antrenman";
  }
}
