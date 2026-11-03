# Pace - Kişisel Performans ve Yaşam Takip Uygulaması

![Uygulama Durumu](https://img.shields.io/badge/Durum-Aktif_Geliştirme-success)
![Flutter](https://img.shields.io/badge/Flutter-Bileşenler-blue)
![Supabase](https://img.shields.io/badge/Supabase-Veritabanı-green)

**Pace**, kullanıcıların günlük yaşam alışkanlıklarını, fitness hedeflerini, fiziksel ve zihinsel gelişimlerini tek bir merkezden, kesintisiz bir deneyimle takip etmelerini sağlayan modern bir mobil uygulamadır.

Minimalist karanlık teması (Dark Mode) ve veri odaklı grafikleriyle Pace, kullanıcının motivasyonunu yüksek tutmayı ve kişisel gelişimini ölçülebilir hale getirmeyi hedefler.

## 🚀 Öne Çıkan Özellikler

### 1. Günlük Odak Panosu (Dashboard)

Kullanıcının güne motivasyonla başlamasını sağlayan ana kontrol merkezidir.

- **Motivasyon Mottoları:** Her gün değişen, "Zirve sabır ister" gibi dinamik ve motive edici başlıklar.
- **Genel İlerleme Çubuğu:** Günlük hedeflerin yüzde kaçının tamamlandığını gösteren ana gösterge.
- **Hızlı Bakış:** Adım hedefleri, antrenman durumu ve aktif meydan okumaların tek ekrandan özet takibi.

### 2. Kapsamlı Antrenman Yönetimi

Vücut geliştirme ve fitness süreçlerini organize eden spesifik çalışma modülü.

- **Bölgesel Odak:** Göğüs, Sırt, Omuz, Bacak, Kol ve Bilek gibi kas gruplarına özel olarak ayrılmış çalışma ekranları.
- **Hareket Kütüphanesi:** Her bölge için uygun hareket sayısını (örn: 6 hareket uygun) ve program detaylarını listeleme.

### 3. Dinamik Meydan Okumalar (Challenges)

Sıradan bir günü oyunlaştırarak (gamification) kullanıcıyı harekete geçiren görev sistemi.

- **Kategorize Edilmiş Görevler:**
  - 🏋️ _Fiziksel_ (örn: 90 Squat Yap)
  - 🧠 _Zihinsel_ (örn: 80 Sayfa Kitap Oku)
  - 💧 _Sağlık_ (örn: 1.5 Litre Su İç)
  - 🥗 _Beslenme_ (örn: Sıfır Şeker)
- **Zamanlayıcı:** Görevlerin yenilenmesi için 24 saatlik geri sayım sayacı.

### 4. Gelişmiş Performans ve Adım Takibi

Günlük hareketliliği ölçen ve analiz eden veri merkezi.

- **Dairesel İlerleme Grafiği:** Atılan adımların hedefe oranını görselleştiren şık UI bileşeni.
- **Detaylı Metrikler:** Sadece adım değil; **Mesafe (km)**, **Süre (dk)** ve yakılan **Kalori (kcal)** verilerinin anlık analizi.

---

## 📸 Ekran Görüntüleri

|               Ana Ekran (Dashboard)                |                Antrenman Yönetimi                 |                   Meydan Okumalar                   |               Performans Takibi                |
| :------------------------------------------------: | :-----------------------------------------------: | :-------------------------------------------------: | :--------------------------------------------: |
| <img src="docs/images/dashboard.png" width="220"/> | <img src="docs/images/training.jpg" width="220"/> | <img src="docs/images/challenges.png" width="220"/> | <img src="docs/images/steps.jpg" width="220"/> |

---

## 🛠️ Teknik Altyapı ve Teknolojiler

Proje, modern mobil uygulama geliştirme standartlarına uygun olarak tasarlanmıştır.

- **Frontend:** Flutter & Dart
- **UI/UX:** Özel tasarlanmış karanlık tema (Dark Mode), Glassmorphism esintili kart yapıları ve dairesel ilerleme çubukları.
- **Backend as a Service (BaaS):** Supabase
- **Veritabanı:** PostgreSQL (Supabase üzerinden barındırılan)
- **Kimlik Doğrulama:** Supabase Auth (E-posta, şifre ve potansiyel OAuth entegrasyonları için hazır altyapı)

---

## ⚙️ Kurulum ve Geliştirme Ortamı

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz.

### Ön Koşullar

- [Flutter SDK](https://docs.flutter.dev/get-started/install)'nın bilgisayarınızda kurulu olması.
- Bir [Supabase](https://supabase.com/) hesabı ve projesi.

### Adımlar

1. **Projeyi Klonlayın:**
   ```bash
   git clone [https://github.com/Alikrkcu0/Pace.git](https://github.com/Alikrkcu0/Pace.git)
   cd Pace
   ```
