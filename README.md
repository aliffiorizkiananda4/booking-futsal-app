# Futsal Booking App

Aplikasi mobile untuk booking lapangan futsal yang dibangun dengan Flutter. Aplikasi ini merupakan hasil refactor dari sistem inventaris menjadi sistem booking lapangan futsal.

## 🎯 Fitur Utama

### User Features
- ✅ **Authentication**
  - Register akun baru
  - Login dengan email & password
  - Auto-login jika sudah pernah login
  - Logout

- ⚽ **Lapangan Futsal**
  - Lihat daftar lapangan futsal
  - Lihat detail lapangan (gambar, tipe, harga, deskripsi)
  - Filter lapangan berdasarkan tipe

- 📅 **Booking**
  - Pilih jadwal yang tersedia
  - Booking lapangan dengan jadwal tertentu
  - Lihat riwayat booking
  - Status booking (Pending, Approved, Rejected)

- 📱 **Dashboard**
  - Quick access ke semua fitur
  - Informasi total lapangan
  - Navigasi mudah

## 🛠️ Teknologi

- **Framework**: Flutter (Dart)
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences
- **Image Picker**: image_picker
- **Animation**: Lottie

## 📋 Prerequisites

- Flutter SDK (3.10.7 atau lebih baru)
- Dart SDK
- Android Studio / VS Code
- Android Emulator / iOS Simulator / Physical Device
- Backend API running di `http://localhost:9000`

## 🚀 Instalasi

### 1. Clone Repository
```bash
git clone <repository-url>
cd invenTrack
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Backend
Pastikan backend API sudah running di:
- **Android Emulator**: `http://10.0.2.2:9000`
- **iOS Simulator**: `http://localhost:9000`
- **Physical Device**: Sesuaikan IP di `lib/config/api_config.dart`

### 4. Run Application
```bash
flutter run
```

## 📱 Cara Penggunaan

### 1. Register & Login
1. Buka aplikasi
2. Klik "Daftar" untuk membuat akun baru
3. Isi form registrasi (nama, email, phone, password)
4. Setelah berhasil, login dengan email & password

### 2. Lihat Lapangan
1. Dari dashboard, klik card "Lapangan Futsal"
2. Browse daftar lapangan yang tersedia
3. Klik lapangan untuk melihat detail

### 3. Booking Lapangan
1. Dari detail lapangan, klik "BOOKING SEKARANG"
2. Atau dari dashboard, klik "Booking Sekarang"
3. Pilih jadwal yang tersedia
4. Klik "Konfirmasi Booking"
5. Tunggu konfirmasi dari admin

### 4. Lihat Riwayat Booking
1. Dari dashboard, klik "Riwayat Booking"
2. Lihat semua booking Anda
3. Status booking:
   - 🟡 **Pending**: Menunggu konfirmasi
   - 🟢 **Approved**: Booking disetujui
   - 🔴 **Rejected**: Booking ditolak

## 🎨 Tema & Design

### Color Palette
- **Primary**: `#22C55E` (Green)
- **Secondary**: `#16A34A` (Dark Green)
- **Accent**: `#15803D` (Darker Green)
- **Background**: `#F4F6FA` (Light Gray)
- **Text Primary**: `#1E293B` (Dark Slate)
- **Text Secondary**: `#94A3B8` (Slate Gray)

### Design System
- **Border Radius**: 16-24px (rounded corners)
- **Shadows**: Soft shadows untuk depth
- **Typography**: Bold headers, regular body text
- **Icons**: Material Design Icons
- **Animations**: Smooth transitions & fade effects

## 📂 Struktur Project

```
lib/
├── config/
│   └── api_config.dart          # Konfigurasi API base URL
├── models/
│   ├── user_model.dart          # Model User
│   ├── field_model.dart         # Model Lapangan
│   ├── schedule_model.dart      # Model Jadwal
│   └── booking_model.dart       # Model Booking
├── services/
│   ├── auth_service.dart        # Service Authentication
│   ├── field_service.dart       # Service Lapangan
│   ├── schedule_service.dart    # Service Jadwal
│   └── booking_service.dart     # Service Booking
├── views/
│   ├── login_page.dart          # Halaman Login
│   ├── register_page.dart       # Halaman Register
│   ├── onboarding_page.dart     # Halaman Onboarding
│   ├── dashboard_page.dart      # Halaman Dashboard
│   ├── field_page.dart          # Halaman Daftar Lapangan
│   ├── field_detail_page.dart   # Halaman Detail Lapangan
│   ├── booking_page.dart        # Halaman Booking
│   └── booking_history_page.dart # Halaman Riwayat Booking
├── widgets/
│   ├── button/                  # Custom buttons
│   ├── card/                    # Custom cards
│   ├── form/                    # Custom form fields
│   ├── loading_widget.dart      # Loading indicator
│   └── field_card.dart          # Card lapangan
├── utils/
│   └── color.dart               # Color constants
└── main.dart                    # Entry point
```

## 🔌 API Endpoints

### Authentication
```
POST /auth/login
POST /auth/register
```

### Fields
```
GET  /fields           # Get all fields
GET  /fields/:id       # Get field detail
```

### Schedules
```
GET  /schedules                    # Get all schedules
GET  /schedules?field_id=:id       # Get schedules by field
```

### Bookings
```
GET  /bookings         # Get user bookings (with pagination)
POST /bookings         # Create new booking
```

## 🔐 Authentication

Aplikasi menggunakan **Bearer Token Authentication**:
1. Token disimpan di SharedPreferences setelah login
2. Setiap request API menyertakan token di header:
   ```
   Authorization: Bearer <token>
   ```
3. Token otomatis dihapus saat logout

## 📝 Notes

### Android Emulator
- Base URL: `http://10.0.2.2:9000`
- `10.0.2.2` adalah alias untuk `localhost` di Android Emulator

### iOS Simulator
- Base URL: `http://localhost:9000`

### Physical Device
- Pastikan device dan backend dalam network yang sama
- Update base URL di `lib/config/api_config.dart` dengan IP komputer Anda

### Image Upload
- Mendukung format: JPG, PNG
- Max size: 1MB (recommended)
- Menggunakan `image_picker` package

## 🐛 Troubleshooting

### Error: Connection Refused
- Pastikan backend sudah running
- Check base URL di `api_config.dart`
- Untuk Android Emulator, gunakan `10.0.2.2` bukan `localhost`

### Error: Token Invalid
- Logout dan login kembali
- Clear app data jika masih error

### Error: Image Not Showing
- Check URL gambar dari backend
- Pastikan backend mengembalikan full URL
- Check internet permission di AndroidManifest.xml

## 📄 License

This project is created for educational purposes (UKEL Project).

## 👥 Contributors

- Developer: [Your Name]
- Project: UKEL Booking Lapangan Futsal

## 📞 Support

Jika ada pertanyaan atau issue, silakan hubungi:
- Email: [your-email]
- GitHub Issues: [repository-url]/issues

---

**Happy Coding! ⚽🎉**
