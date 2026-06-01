# Testing Guide - Futsal Booking App

Panduan lengkap untuk testing aplikasi Futsal Booking.

## 📋 Prerequisites Testing

### 1. Backend Setup
Pastikan backend API sudah running dengan endpoints berikut:

```
POST   /auth/login
POST   /auth/register
GET    /fields
GET    /fields/:id
GET    /schedules
GET    /schedules?field_id=:id
GET    /bookings
POST   /bookings
```

### 2. Test Data
Siapkan data test di backend:
- Minimal 3-5 lapangan futsal
- Minimal 5-10 jadwal tersedia
- User test untuk login

### 3. Environment
- Android Emulator / iOS Simulator / Physical Device
- Internet connection
- Backend running di `http://localhost:9000`

## 🧪 Test Scenarios

### 1. Authentication Flow

#### Test Case 1.1: Register User Baru
**Steps:**
1. Buka aplikasi
2. Klik "Daftar" di halaman login
3. Isi form:
   - Nama: "Test User"
   - Email: "test@example.com"
   - Phone: "081234567890"
   - Password: "password123"
4. Klik "Daftar"

**Expected Result:**
- ✅ Muncul snackbar "Registrasi berhasil! Silakan login."
- ✅ Redirect ke halaman login
- ✅ Data user tersimpan di backend

**Actual Result:** [ ]

---

#### Test Case 1.2: Login dengan Kredensial Valid
**Steps:**
1. Di halaman login, isi:
   - Email: "test@example.com"
   - Password: "password123"
2. Klik "Login"

**Expected Result:**
- ✅ Loading indicator muncul
- ✅ Token tersimpan di SharedPreferences
- ✅ Redirect ke Dashboard
- ✅ Nama user muncul di greeting

**Actual Result:** [ ]

---

#### Test Case 1.3: Login dengan Kredensial Invalid
**Steps:**
1. Di halaman login, isi:
   - Email: "wrong@example.com"
   - Password: "wrongpassword"
2. Klik "Login"

**Expected Result:**
- ✅ Muncul snackbar error "Login Gagal!"
- ✅ Tetap di halaman login
- ✅ Form tidak di-reset

**Actual Result:** [ ]

---

#### Test Case 1.4: Auto Login
**Steps:**
1. Login dengan kredensial valid
2. Close aplikasi
3. Buka aplikasi kembali

**Expected Result:**
- ✅ Langsung masuk ke Dashboard
- ✅ Tidak perlu login lagi
- ✅ Token masih valid

**Actual Result:** [ ]

---

#### Test Case 1.5: Logout
**Steps:**
1. Di Dashboard, klik icon logout
2. Konfirmasi logout

**Expected Result:**
- ✅ Token dihapus dari SharedPreferences
- ✅ Redirect ke halaman login
- ✅ Tidak bisa back ke Dashboard

**Actual Result:** [ ]

---

### 2. Field (Lapangan) Flow

#### Test Case 2.1: Lihat Daftar Lapangan
**Steps:**
1. Login ke aplikasi
2. Di Dashboard, klik card "Lapangan Futsal"

**Expected Result:**
- ✅ Muncul loading indicator
- ✅ Menampilkan list lapangan
- ✅ Setiap card menampilkan: gambar, nama, tipe, harga
- ✅ Gambar ter-load dengan benar

**Actual Result:** [ ]

---

#### Test Case 2.2: Lihat Detail Lapangan
**Steps:**
1. Di halaman daftar lapangan
2. Klik salah satu card lapangan

**Expected Result:**
- ✅ Navigasi ke halaman detail
- ✅ Menampilkan gambar full width
- ✅ Menampilkan nama, tipe, harga, deskripsi
- ✅ Tombol "BOOKING SEKARANG" muncul

**Actual Result:** [ ]

---

#### Test Case 2.3: Handle Error Load Lapangan
**Steps:**
1. Matikan backend
2. Buka halaman daftar lapangan
3. Atau refresh halaman

**Expected Result:**
- ✅ Muncul error message
- ✅ Tombol "Coba Lagi" muncul
- ✅ Klik "Coba Lagi" akan retry request

**Actual Result:** [ ]

---

### 3. Booking Flow

#### Test Case 3.1: Booking dari Detail Lapangan
**Steps:**
1. Buka detail lapangan
2. Klik "BOOKING SEKARANG"
3. Pilih salah satu jadwal tersedia
4. Klik "Konfirmasi Booking"

**Expected Result:**
- ✅ Navigasi ke halaman booking
- ✅ Menampilkan jadwal tersedia
- ✅ Jadwal yang dipilih ter-highlight
- ✅ Muncul dialog sukses
- ✅ Booking tersimpan di backend

**Actual Result:** [ ]

---

#### Test Case 3.2: Booking dari Dashboard
**Steps:**
1. Di Dashboard, klik "Booking Sekarang"
2. Pilih jadwal (tanpa memilih lapangan terlebih dahulu)
3. Klik "Konfirmasi Booking"

**Expected Result:**
- ✅ Menampilkan semua jadwal tersedia
- ✅ Bisa pilih jadwal dari lapangan manapun
- ✅ Booking berhasil dibuat

**Actual Result:** [ ]

---

#### Test Case 3.3: Booking Tanpa Pilih Jadwal
**Steps:**
1. Buka halaman booking
2. Langsung klik "Konfirmasi Booking" tanpa pilih jadwal

**Expected Result:**
- ✅ Muncul snackbar "Pilih jadwal terlebih dahulu!"
- ✅ Tidak ada request ke backend
- ✅ Tetap di halaman booking

**Actual Result:** [ ]

---

#### Test Case 3.4: Booking Jadwal yang Sudah Dibooking
**Steps:**
1. Booking jadwal A
2. Logout
3. Login dengan user lain
4. Coba booking jadwal A yang sama

**Expected Result:**
- ✅ Jadwal A tidak muncul di list (status = booked)
- ✅ Atau muncul error jika tetap bisa dipilih

**Actual Result:** [ ]

---

### 4. Booking History Flow

#### Test Case 4.1: Lihat Riwayat Booking
**Steps:**
1. Login ke aplikasi
2. Di Dashboard, klik "Riwayat Booking"

**Expected Result:**
- ✅ Menampilkan list booking user
- ✅ Setiap item menampilkan: nama lapangan, tanggal, status
- ✅ Status badge dengan warna yang sesuai:
  - Pending: Kuning
  - Approved: Hijau
  - Rejected: Merah

**Actual Result:** [ ]

---

#### Test Case 4.2: Pagination Riwayat Booking
**Steps:**
1. Buat lebih dari 10 booking
2. Buka halaman riwayat booking
3. Klik tombol next page

**Expected Result:**
- ✅ Menampilkan 10 booking per page
- ✅ Tombol prev/next berfungsi
- ✅ Indicator page number benar
- ✅ Total data benar

**Actual Result:** [ ]

---

#### Test Case 4.3: Riwayat Booking Kosong
**Steps:**
1. Login dengan user baru (belum pernah booking)
2. Buka halaman riwayat booking

**Expected Result:**
- ✅ Menampilkan empty state
- ✅ Icon inbox dengan text "Belum ada riwayat booking"

**Actual Result:** [ ]

---

### 5. UI/UX Testing

#### Test Case 5.1: Responsive Layout
**Steps:**
1. Test di berbagai ukuran layar:
   - Small (320x568)
   - Medium (375x667)
   - Large (414x896)

**Expected Result:**
- ✅ Layout tidak overflow
- ✅ Text terbaca dengan jelas
- ✅ Button tidak terpotong
- ✅ Image ter-scale dengan baik

**Actual Result:** [ ]

---

#### Test Case 5.2: Loading States
**Steps:**
1. Test semua halaman yang melakukan API call
2. Perhatikan loading indicator

**Expected Result:**
- ✅ Loading indicator muncul saat fetch data
- ✅ Loading indicator hilang setelah data loaded
- ✅ Tidak ada double loading

**Actual Result:** [ ]

---

#### Test Case 5.3: Error Handling
**Steps:**
1. Matikan internet
2. Coba akses berbagai fitur

**Expected Result:**
- ✅ Muncul error message yang jelas
- ✅ Ada opsi retry
- ✅ Aplikasi tidak crash

**Actual Result:** [ ]

---

#### Test Case 5.4: Navigation Flow
**Steps:**
1. Test navigasi antar halaman
2. Test back button

**Expected Result:**
- ✅ Navigasi smooth tanpa lag
- ✅ Back button berfungsi dengan benar
- ✅ Tidak ada memory leak

**Actual Result:** [ ]

---

### 6. Performance Testing

#### Test Case 6.1: App Launch Time
**Steps:**
1. Close aplikasi
2. Buka aplikasi
3. Ukur waktu sampai halaman pertama muncul

**Expected Result:**
- ✅ Launch time < 3 detik
- ✅ Splash screen smooth

**Actual Result:** [ ]

---

#### Test Case 6.2: Image Loading
**Steps:**
1. Buka halaman dengan banyak gambar
2. Perhatikan loading time

**Expected Result:**
- ✅ Image loading smooth
- ✅ Placeholder muncul saat loading
- ✅ Tidak ada lag saat scroll

**Actual Result:** [ ]

---

#### Test Case 6.3: Memory Usage
**Steps:**
1. Buka aplikasi
2. Navigasi ke berbagai halaman
3. Check memory usage di profiler

**Expected Result:**
- ✅ Memory usage stabil
- ✅ Tidak ada memory leak
- ✅ Memory release setelah back

**Actual Result:** [ ]

---

## 📊 Test Summary

### Test Results
- Total Test Cases: 23
- Passed: [ ]
- Failed: [ ]
- Skipped: [ ]

### Critical Issues
1. [ ] Issue 1
2. [ ] Issue 2
3. [ ] Issue 3

### Minor Issues
1. [ ] Issue 1
2. [ ] Issue 2
3. [ ] Issue 3

### Recommendations
1. [ ] Recommendation 1
2. [ ] Recommendation 2
3. [ ] Recommendation 3

---

## 🔧 Debug Tips

### Enable Debug Mode
```dart
// Di main.dart
void main() {
  debugPrint('App started');
  runApp(const FutsalBookingApp());
}
```

### Check API Response
```dart
// Di service
print('Response: ${response.body}');
print('Status Code: ${response.statusCode}');
```

### Check Token
```dart
// Di auth_service
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString("token");
print('Token: $token');
```

### Check Navigation
```dart
// Di widget
print('Current Route: ${ModalRoute.of(context)?.settings.name}');
```

---

## 📝 Test Report Template

```
Test Date: [Date]
Tester: [Name]
Device: [Device Name]
OS Version: [OS Version]
App Version: [Version]

Test Results:
- Authentication: [Pass/Fail]
- Field Management: [Pass/Fail]
- Booking: [Pass/Fail]
- History: [Pass/Fail]
- UI/UX: [Pass/Fail]
- Performance: [Pass/Fail]

Issues Found:
1. [Issue description]
2. [Issue description]

Notes:
[Additional notes]
```

---

**Happy Testing! 🧪✅**
