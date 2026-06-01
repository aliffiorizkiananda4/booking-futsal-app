# REFACTOR SUMMARY - INVENTARIS TO FUTSAL BOOKING

## Overview
Project Flutter Inventaris telah berhasil direfactor menjadi aplikasi Booking Lapangan Futsal dengan mempertahankan struktur project yang sudah ada.

## Perubahan Konfigurasi

### API Configuration
- **File**: `lib/config/api_config.dart`
- **Base URL**: Diubah menjadi `http://10.0.2.2:9000` (Android Emulator) dan `http://localhost:9000` (Web)

## Perubahan Models

### 1. ItemModel → FieldModel
- **File**: `lib/models/item_model.dart` → `lib/models/field_model.dart`
- **Fields**:
  - `id`: int
  - `name`: String
  - `type`: String (tipe lapangan)
  - `price`: int (harga per jam)
  - `description`: String? (deskripsi lapangan)
  - `image`: String? (URL gambar)

### 2. LoanModel → BookingModel
- **File**: `lib/models/loan_model.dart` → `lib/models/booking_model.dart`
- **Fields**:
  - `id`: int
  - `userId`: int
  - `fieldId`: int
  - `scheduleId`: int
  - `status`: String (pending/approved/rejected)
  - `date`: String?
  - `field`: FieldModel?

### 3. Model Baru

#### ScheduleModel
- **File**: `lib/models/schedule_model.dart`
- **Fields**:
  - `id`: int
  - `fieldId`: int
  - `date`: String
  - `startTime`: String
  - `endTime`: String
  - `status`: String (available/booked)

#### UserModel
- **File**: `lib/models/user_model.dart`
- **Fields**:
  - `id`: int
  - `name`: String
  - `email`: String
  - `phone`: String?
  - `role`: String?

## Perubahan Services

### 1. ItemService → FieldService
- **File**: `lib/services/item_service.dart` → `lib/services/field_service.dart`
- **Endpoints**:
  - `GET /fields` - Mendapatkan semua lapangan
  - `GET /fields/:id` - Mendapatkan detail lapangan
  - `POST /fields` - Menambah lapangan (admin)
  - `PUT /fields/:id` - Update lapangan (admin)
  - `DELETE /fields/:id` - Hapus lapangan (admin)

### 2. LoanService → BookingService
- **File**: `lib/services/loan_service.dart` → `lib/services/booking_service.dart`
- **Endpoints**:
  - `GET /bookings` - Mendapatkan riwayat booking
  - `POST /bookings` - Membuat booking baru

### 3. Service Baru

#### ScheduleService
- **File**: `lib/services/schedule_service.dart`
- **Endpoints**:
  - `GET /schedules` - Mendapatkan jadwal tersedia
  - `GET /schedules?field_id=:id` - Mendapatkan jadwal per lapangan

#### AuthService (Updated)
- **File**: `lib/services/auth_service.dart`
- **Endpoints**:
  - `POST /auth/login` - Login dengan email & password
  - `POST /auth/register` - Register user baru
- **Methods**:
  - `login(email, password)` - Login user
  - `register(name, email, password, phone)` - Register user
  - `logout()` - Logout user
  - `isLoggedIn()` - Check status login
  - `getName()` - Get nama user

## Perubahan Views

### 1. dashboard.dart → dashboard_page.dart
- **Perubahan**:
  - Tema warna dari biru ke hijau (futsal theme)
  - Icon dari inventory ke soccer
  - Menu cards:
    - Total Barang → Lapangan Futsal
    - Data Peminjaman → Riwayat Booking
    - Buat Peminjaman → Booking Sekarang
  - Greeting message disesuaikan dengan tema futsal

### 2. data_barang_page.dart → field_page.dart
- **Perubahan**:
  - Menampilkan daftar lapangan futsal
  - Card menampilkan: gambar, nama, tipe, harga per jam
  - Navigasi ke detail lapangan saat card diklik
  - Removed: form tambah/edit/hapus (untuk admin)

### 3. field_detail_page.dart (Baru)
- **Fitur**:
  - Menampilkan detail lengkap lapangan
  - Gambar lapangan (full width)
  - Informasi: nama, tipe, harga, deskripsi
  - Tombol "BOOKING SEKARANG"

### 4. peminjaman_page.dart → booking_history_page.dart
- **Perubahan**:
  - Menampilkan riwayat booking user
  - Status badge: pending (kuning), approved (hijau), rejected (merah)
  - Informasi: nama lapangan, tanggal, status
  - Pagination support

### 5. buat_peminjaman_page.dart → booking_page.dart
- **Perubahan**:
  - Form untuk memilih jadwal booking
  - Menampilkan jadwal tersedia (tanggal, jam mulai, jam selesai)
  - User memilih jadwal yang diinginkan
  - Konfirmasi booking
  - Dialog sukses setelah booking

### 6. register_page.dart (Baru)
- **Fitur**:
  - Form registrasi: nama, email, phone, password
  - Validasi input
  - Redirect ke login setelah berhasil register

### 7. login_page.dart (Updated)
- **Perubahan**:
  - Tema warna hijau (futsal)
  - Branding: "FutsalBooking"
  - Tagline: "Book Your Futsal Field Easily"
  - Link ke halaman register

## Perubahan Widgets

### Widget Baru

#### 1. loading_widget.dart
- **File**: `lib/widgets/loading_widget.dart`
- **Fungsi**: Widget loading dengan warna hijau (futsal theme)

#### 2. field_card.dart
- **File**: `lib/widgets/field_card.dart`
- **Fungsi**: Card untuk menampilkan lapangan futsal

### Widget yang Dipertahankan
- `custom_button.dart` - Button reusable
- `custom_text_field.dart` - Text field reusable
- `build_form_field.dart` - Form field builder
- `build_text_field.dart` - Text field builder
- `stat_card.dart` - Card statistik
- `quick_action_button.dart` - Quick action button

## Perubahan Main App

### main.dart
- **App Name**: `FoodNinjaApp` → `FutsalBookingApp`
- **Title**: `InvenTrack` → `Futsal Booking`
- **Theme**: Primary color hijau (#22C55E)
- **Initial Route**: Check login status
  - Jika sudah login → Dashboard
  - Jika belum login → Onboarding

## Tema Warna

### Warna Utama
- **Primary Green**: `#22C55E` (hijau futsal)
- **Secondary Green**: `#16A34A`
- **Dark Green**: `#15803D`
- **Light Green Background**: `#DCFCE7`

### Status Colors
- **Pending**: `#F59E0B` (kuning)
- **Approved**: `#22C55E` (hijau)
- **Rejected**: `#EF4444` (merah)

## Backend API Endpoints

### Authentication
- `POST /auth/login` - Login
- `POST /auth/register` - Register

### Fields
- `GET /fields` - Get all fields
- `GET /fields/:id` - Get field detail

### Schedules
- `GET /schedules` - Get all schedules
- `GET /schedules?field_id=:id` - Get schedules by field

### Bookings
- `GET /bookings` - Get user bookings
- `POST /bookings` - Create new booking

## File yang Dihapus
Tidak ada file yang dihapus, semua file lama telah direfactor atau diganti.

## Dependencies
Semua dependencies yang sudah ada dipertahankan:
- `flutter`
- `cupertino_icons`
- `lottie`
- `image_picker`
- `http`
- `shared_preferences`

## Testing
Untuk testing aplikasi:
1. Pastikan backend sudah running di `http://localhost:9000`
2. Jalankan `flutter pub get`
3. Jalankan aplikasi dengan `flutter run`
4. Test flow:
   - Register akun baru
   - Login dengan akun yang sudah dibuat
   - Lihat daftar lapangan
   - Klik detail lapangan
   - Booking lapangan dengan memilih jadwal
   - Lihat riwayat booking

## Catatan Penting
1. **Token Authentication**: Semua request API (kecuali login/register) menggunakan Bearer token yang disimpan di SharedPreferences
2. **Image Handling**: Gambar lapangan diambil dari backend, pastikan backend mengembalikan URL yang benar
3. **Status Booking**: Status booking dikelola oleh backend (pending → approved/rejected)
4. **Pagination**: Riwayat booking mendukung pagination
5. **Error Handling**: Semua service memiliki try-catch untuk error handling

## Struktur Folder Akhir
```
lib/
├── config/
│   └── api_config.dart
├── models/
│   ├── user_model.dart
│   ├── field_model.dart
│   ├── schedule_model.dart
│   └── booking_model.dart
├── services/
│   ├── auth_service.dart
│   ├── field_service.dart
│   ├── schedule_service.dart
│   └── booking_service.dart
├── views/
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── onboarding_page.dart
│   ├── dashboard_page.dart
│   ├── field_page.dart
│   ├── field_detail_page.dart
│   ├── booking_page.dart
│   └── booking_history_page.dart
├── widgets/
│   ├── button/
│   │   ├── custom_button.dart
│   │   └── quick_action_button.dart
│   ├── card/
│   │   ├── stat_card.dart
│   │   └── item_status_tile.dart
│   ├── form/
│   │   ├── build_form_field.dart
│   │   ├── build_text_field.dart
│   │   └── custom_text_field.dart
│   ├── loading_widget.dart
│   └── field_card.dart
├── utils/
│   └── color.dart
└── main.dart
```

## Status Refactor
✅ **SELESAI** - Semua file telah direfactor dan siap digunakan untuk project UKEL Booking Lapangan Futsal.
