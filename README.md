# 🎬 Sinema Keyfi

**Sinema Keyfi**, en popüler filmleri keşfedebileceğiniz, detaylarını inceleyip fragmanlarını izleyebileceğiniz modern bir Flutter uygulamasıdır. TMDB (The Movie Database) API altyapısını kullanır.

<p align="center">
  <img src="assets/icon/app_icon.png" width="150" alt="Sinema Keyfi Logo">
</p>

## ✨ Özellikler

Bu proje, bir modern mobil uygulamada olması gereken birçok temel ve ileri seviye özelliği barındırır:

* **🚀 Sonsuz Kaydırma (Infinite Scroll):** Liste sonuna gelindiğinde yeni filmler otomatik yüklenir.
* **🎲 Şaşırt Beni:** Ne izleyeceğine karar veremeyenler için rastgele film önerme motoru.
* **🔍 Detaylı Arama:** Anlık olarak film arama özelliği.
* **📂 Kategori Filtreleme:** Aksiyon, Komedi, Bilim Kurgu gibi türlere göre listeleme.
* **❤️ Favoriler Sistemi:** Beğendiğiniz filmleri internet yokken bile görebilmeniz için **Hive** veritabanı ile yerel depolama.
* **🎥 Fragman İzle:** Filmin fragmanını doğrudan YouTube üzerinden açar.
* **📤 Paylaş:** Beğendiğiniz filmleri arkadaşlarınızla tek tıkla paylaşın.
* **🎭 Oyuncu Kadrosu:** Filmin başrol oyuncularını görüntüleme.
* **🌑 Dark Mode:** Göz yormayan şık ve modern karanlık tema.

## 🛠️ Kullanılan Teknolojiler ve Paketler

* **Flutter & Dart**
* **Http:** API istekleri için.
* **Hive & Hive Flutter:** Yerel veritabanı (Favoriler) için.
* **Cached Network Image:** Resim önbellekleme ve performans için.
* **Url Launcher:** Fragman linklerini açmak için.
* **Share Plus:** İçerik paylaşımı için.
* **Google Fonts:** Modern tipografi için.

## 📸 Ekran Görüntüleri

*(Buraya uygulamanızın ekran görüntülerini ekleyebilirsiniz)*

| Ana Sayfa | Detay Sayfası | Arama |
|-----------|---------------|-------|
| ![Home](https://via.placeholder.com/200x400) | ![Detail](https://via.placeholder.com/200x400) | ![Search](https://via.placeholder.com/200x400) |

## 🚀 Kurulum

Projeyi kendi bilgisayarınızda çalıştırmak için:

1.  **Projeyi klonlayın:**
    ```bash
    git clone [https://github.com/KULLANICI_ADINIZ/sinema_keyfi.git](https://github.com/KULLANICI_ADINIZ/sinema_keyfi.git)
    ```
2.  **Paketleri yükleyin:**
    ```bash
    flutter pub get
    ```
3.  **API Anahtarı:**
    * `lib/services/api_service.dart` dosyasını açın.
    * `apiKey` değişkenine kendi TMDB API anahtarınızı yapıştırın.
4.  **Çalıştırın:**
    ```bash
    flutter run
    ```

## 📱 APK İndir

Uygulamanın derlenmiş APK sürümünü `build/app/outputs/flutter-apk/app-release.apk` dizininde bulabilirsiniz veya release kısmından indirebilirsiniz.

---
**Geliştirici:** [İlker İpek]
