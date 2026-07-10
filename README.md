<p align="center">
  <img src="assets/images/splash.png" alt="ReuseU Logo" width="120"/>
</p>

<h1 align="center">ReuseU</h1>

<p align="center">
  <strong>Marketplace Barang Bekas Mahasiswa</strong><br/>
  Jual & beli barang bekas sesama mahasiswa dengan mudah, aman, dan terpercaya.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"/>
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white"/>
  <img alt="Supabase" src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white"/>
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green"/>
</p>

---

## 📖 Tentang ReuseU

**ReuseU** adalah aplikasi mobile marketplace yang dirancang khusus untuk komunitas mahasiswa. Platform ini memungkinkan mahasiswa untuk menjual dan membeli barang bekas secara mudah di dalam lingkungan kampus. Nama "ReuseU" berasal dari kata **Reuse** (gunakan kembali) + **U** (University/You) — mencerminkan semangat ekonomi sirkular di lingkungan kampus.

---

## ✨ Fitur Utama

### 🛒 Marketplace Barang Bekas
- Jual & beli barang bekas antar mahasiswa
- Kategori produk: **Fashion, Alat Tulis, Elektronik, Furnitur, Dapur, Lainnya**
- Filter kondisi barang: Baru, Seperti Baru, Baik, Layak Pakai
- Status produk: Available, Reserved, Sold

### 🖼️ Manajemen Produk
- Upload hingga **5 foto** per produk
- Edit detail produk (nama, harga, deskripsi, kondisi, lokasi)
- Hapus produk milik sendiri
- Riwayat barang yang dijual (Lapak Saya)

### 💬 Real-time Chat
- Chat langsung antara pembeli dan penjual per produk
- Riwayat percakapan tersimpan otomatis
- Update `last_message_at` secara real-time via trigger database

### ❤️ Wishlist / Bookmark
- Simpan produk favorit ke dalam daftar wishlist
- Satu user tidak bisa bookmark produk yang sama dua kali

### 👤 Profil Pengguna
- Profil lengkap: nama, NIM (username), no. WhatsApp, lokasi/universitas
- Upload & ganti foto profil (avatar)
- Edit informasi profil kapan saja

### 🔐 Autentikasi
- Registrasi dengan email, NIM, nomor HP, dan lokasi
- Login / Logout dengan session management
- Session otomatis dipertahankan (tidak perlu login ulang)

### 🔔 Notifikasi
- Sistem notifikasi in-app untuk aktivitas terkait produk dan transaksi

### ⚙️ Pengaturan
- Halaman pengaturan lengkap (ubah password, tema, dll.)
- Manajemen akun

---

## 🛠️ Tech Stack

| Layer | Teknologi |
|-------|-----------|
| **Framework** | [Flutter](https://flutter.dev/) (Dart SDK ^3.11.1) |
| **Bahasa** | [Dart](https://dart.dev/) |
| **Backend & Database** | [Supabase](https://supabase.com/) (PostgreSQL) |
| **Autentikasi** | Supabase Auth |
| **Storage** | Supabase Storage (bucket: `product-images`, `avatars`) |
| **State Management** | [Provider](https://pub.dev/packages/provider) ^6.1.5 |
| **UI/Font** | [Google Fonts](https://pub.dev/packages/google_fonts) — Inter |
| **Icon** | [Font Awesome Flutter](https://pub.dev/packages/font_awesome_flutter) |
| **Image Picker** | [image_picker](https://pub.dev/packages/image_picker) ^1.2.0 |
| **Cached Image** | [cached_network_image](https://pub.dev/packages/cached_network_image) ^3.4.1 |
| **Carousel** | [carousel_slider](https://pub.dev/packages/carousel_slider) ^5.1.1 |
| **Splash Screen** | [flutter_native_splash](https://pub.dev/packages/flutter_native_splash) |

---

## 🗄️ Skema Database

Database menggunakan **PostgreSQL** melalui Supabase. Berikut tabel-tabel utama:

```
profiles          — Data publik user (extends auth.users)
products          — Daftar barang yang dijual
product_images    — Foto-foto produk (maks 5 per produk)
wishlists         — Bookmark produk oleh user
chats             — Room percakapan antara buyer & seller
messages          — Isi pesan dalam setiap chat room
transactions      — Riwayat transaksi jual-beli
```

### Relasi Database

```
auth.users
    └── profiles (1:1)
            ├── products (1:N)
            │       └── product_images (1:N)
            ├── wishlists (1:N) → products
            ├── chats (buyer/seller) ↔ products
            │       └── messages (1:N)
            └── transactions (buyer/seller) → products
```

### Security (Row Level Security)
Semua tabel dilindungi oleh **RLS (Row Level Security)** Supabase:
- Produk & profil dapat dilihat publik
- Hanya pemilik yang bisa edit/hapus data miliknya
- Chat & pesan hanya bisa diakses oleh participant yang terlibat
- Transaksi hanya bisa dilihat oleh buyer/seller yang bersangkutan

---

## 📁 Struktur Project

```
ReuseU-main/
├── lib/
│   ├── main.dart                   # Entry point + launch animation
│   ├── endpoints/
│   │   └── endpoints.dart          # Konfigurasi URL Supabase
│   ├── models/
│   │   ├── product_model.dart      # Model data produk
│   │   ├── chat_model.dart         # Model data chat
│   │   └── transaction_model.dart  # Model data transaksi
│   ├── dto/                        # Data Transfer Objects
│   ├── service/
│   │   ├── datas_service.dart      # Service layer (CRUD Supabase)
│   │   └── notification_service.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── product_detail_screen.dart
│   │   ├── lapak/
│   │   │   ├── lapak_screen.dart       # Produk milik user
│   │   │   └── edit_product_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_screen.dart
│   │   │   └── chat_detailed_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   ├── wishlist/
│   │   │   └── wishlist_screen.dart
│   │   ├── splash_screen.dart
│   │   ├── notification_screen.dart
│   │   └── setting_screen.dart
│   ├── navigation/
│   │   └── main_navigation.dart    # Bottom Navigation Bar
│   └── widgets/                    # Reusable widgets
├── assets/
│   ├── images/                     # Gambar (splash, dll.)
│   └── logo/                       # Logo aplikasi
├── database.sql                    # Skema lengkap database Supabase
├── pubspec.yaml
└── README.md
```

---

## 🚀 Memulai (Getting Started)

### Prasyarat

Pastikan tools berikut sudah terinstall:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.x
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.11.1
- IDE: [VS Code](https://code.visualstudio.com/) atau [Android Studio](https://developer.android.com/studio)
- Akun [Supabase](https://supabase.com/) (gratis)
- Device/Emulator Android atau iOS

### 1. Clone Repository

```bash
git clone https://github.com/ariawiduraa/ReuseU.git
cd ReuseU
```

### 2. Setup Supabase

1. Buat project baru di [supabase.com](https://supabase.com/)
2. Buka **SQL Editor** di dashboard Supabase
3. Jalankan seluruh isi file `database.sql` untuk membuat semua tabel, trigger, RLS policy, dan storage bucket
4. Buka **Settings → API** dan salin:
   - `Project URL`
   - `anon public key`

### 3. Konfigurasi Endpoints

Buka file `lib/endpoints/endpoints.dart` dan isi dengan credential Supabase kamu:

```dart
class Endpoints {
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Jalankan Aplikasi

```bash
flutter run
```

Atau pilih device spesifik:

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Chrome (Web)
flutter run -d chrome
```

---

## 🗃️ Setup Database

File `database.sql` sudah mencakup:

| Komponen | Keterangan |
|----------|-----------|
| **Tabel** | `profiles`, `products`, `product_images`, `wishlists`, `chats`, `messages`, `transactions` |
| **Triggers** | Auto-create profil saat register, auto-update `last_message_at`, auto-update `updated_at` |
| **RLS Policies** | Keamanan data per user |
| **Storage Buckets** | `product-images` & `avatars` (dengan policy akses) |
| **Indexes** | Optimasi performa query |
| **Migrasi** | Script untuk database yang sudah ada sebelumnya |

> **Fresh Install (Database Baru):**  
> Jalankan seluruh isi `database.sql` dari awal.

> **Database Sudah Ada:**  
> Jalankan hanya bagian **MIGRASI** di bagian paling bawah file `database.sql`.

---

## 📱 Screenshot Aplikasi

| Splash | Home | Detail Produk |
|--------|------|---------------|
| *(Splash screen dengan animasi scale)* | *(Daftar produk dengan carousel & kategori)* | *(Foto, harga, kondisi, & tombol chat)* |

| Chat | Lapak Saya | Profil |
|------|------------|--------|
| *(Chat real-time per produk)* | *(Kelola produk milik sendiri)* | *(Edit profil & avatar)* |

---

## 🏗️ Arsitektur Aplikasi

```
Presentation Layer (Screens & Widgets)
          ↓
  Service Layer (datas_service.dart)
          ↓
  Supabase Flutter SDK
          ↓
  Supabase Cloud (Auth + Database + Storage)
```

- **Provider** digunakan untuk state management antar widget
- **Service layer** mengabstraksi semua komunikasi dengan Supabase
- **Model classes** merepresentasikan entitas data dari database
- **Endpoints** terpusat di satu file untuk kemudahan konfigurasi

---

## 🤝 Kontribusi

Kontribusi sangat disambut! Berikut langkah-langkahnya:

1. Fork repository ini
2. Buat branch fitur baru: `git checkout -b feature/NamaFitur`
3. Commit perubahan: `git commit -m 'Add: Deskripsi fitur'`
4. Push ke branch: `git push origin feature/NamaFitur`
5. Buat **Pull Request**

---

## 📄 Lisensi

Project ini menggunakan lisensi [MIT](LICENSE).

---

## 👨‍💻 Developer

Dibuat dengan ❤️ oleh **ariawiduraa** dan tim.

> *"Barang lama, nilai baru — untuk sesama mahasiswa."*
