# QUICK FIX CHECKLIST

Gunakan checklist ini untuk memverifikasi bahwa semua perbaikan sudah diterapkan dengan benar.

## ✅ CHECKLIST PERBAIKAN

### 1. Auth Service - Nama User
- [x] File: `lib/services/auth_service.dart`
- [x] Mengambil nama dari `response.data.user.name`
- [x] Fallback yang benar untuk berbagai format response
- [x] Menyimpan nama ke SharedPreferences dengan key "name"

**Cara Test:**
1. Login dengan akun admin
2. Buka dashboard
3. Pastikan tampil: "Selamat datang, Administrator" (bukan "Selamat datang, User")

---

### 2. Field Model - URL Gambar
- [x] File: `lib/models/field_model.dart`
- [x] Menangani nama file saja (contoh: `lapangan1.jpg`)
- [x] Menangani URL lengkap (contoh: `http://localhost:9000/uploads/lapangan1.jpg`)
- [x] Mengubah nama file menjadi `${baseUrl}/uploads/filename`

**Cara Test:**
1. Buka halaman Lapangan
2. Pastikan gambar lapangan tampil
3. Jika tidak tampil, cek URL gambar di network inspector

---

### 3. Payment Service - BARU
- [x] File: `lib/services/payment_service.dart` (DIBUAT BARU)
- [x] Method `uploadPaymentProof()`
- [x] Menggunakan multipart/form-data
- [x] Field: `booking_id`, `payment_proof`
- [x] Endpoint: `POST /payments`

**Cara Test:**
1. Buka halaman Pembayaran
2. Pilih booking
3. Pilih gambar
4. Klik Upload
5. Pastikan berhasil atau tampil error yang jelas

---

### 4. Payment Model - BARU
- [x] File: `lib/models/payment_model.dart` (DIBUAT BARU)
- [x] Properties: id, bookingId, paymentProof, status, createdAt
- [x] Method `fromJson()`

---

### 5. Payment Page - BARU
- [x] File: `lib/views/payment_page.dart` (DIBUAT BARU)
- [x] Menampilkan daftar booking
- [x] Pilih booking untuk pembayaran
- [x] Upload bukti pembayaran dengan ImagePicker
- [x] Loading state saat upload
- [x] Error handling
- [x] Success/error notification

**Cara Test:**
1. Pastikan ada booking di database
2. Buka halaman Pembayaran dari dashboard
3. Pastikan daftar booking tampil
4. Klik salah satu booking (harus ada indikator "Dipilih")
5. Klik "Pilih Gambar" dan pilih gambar dari galeri
6. Pastikan preview gambar tampil
7. Klik "Upload"
8. Pastikan ada loading indicator
9. Pastikan ada notifikasi sukses/gagal

---

### 6. Dashboard - Menu Pembayaran
- [x] File: `lib/views/dashboard_page.dart`
- [x] Import `payment_page.dart`
- [x] Menambahkan menu card "Pembayaran"
- [x] Navigasi ke PaymentPage saat diklik
- [x] Design konsisten dengan menu lain

**Cara Test:**
1. Buka dashboard
2. Pastikan ada 4 menu:
   - Lapangan Futsal (card besar, hijau)
   - Booking Sekarang (card kecil kiri, hijau)
   - Riwayat Booking (card kecil kanan, hijau)
   - Pembayaran (card besar, biru) ← BARU
3. Klik menu Pembayaran
4. Pastikan membuka halaman Payment

---

## 🔍 VERIFICATION STEPS

### Step 1: Compile Check
```bash
flutter analyze
```
**Expected:** No critical errors (info/warnings are OK)

### Step 2: Build Check
```bash
flutter build apk --debug
# atau
flutter build web
```
**Expected:** Build berhasil tanpa error

### Step 3: Run App
```bash
flutter run
```
**Expected:** App berjalan tanpa crash

---

## 🧪 TESTING SCENARIOS

### Scenario 1: Login & Dashboard
1. ✅ Buka app
2. ✅ Login dengan admin@gmail.com
3. ✅ Redirect ke dashboard
4. ✅ Nama user tampil: "Selamat datang, Administrator"
5. ✅ Ada 4 menu di dashboard

### Scenario 2: Lihat Lapangan
1. ✅ Klik menu "Lapangan Futsal"
2. ✅ Data lapangan muncul dari database
3. ✅ Gambar lapangan tampil
4. ✅ Nama, tipe, dan harga tampil dengan benar
5. ✅ Klik card membuka detail lapangan

### Scenario 3: Pembayaran
1. ✅ Klik menu "Pembayaran" di dashboard
2. ✅ Halaman pembayaran terbuka
3. ✅ Daftar booking tampil
4. ✅ Klik salah satu booking
5. ✅ Indikator "Dipilih untuk pembayaran" muncul
6. ✅ Section upload muncul
7. ✅ Klik "Pilih Gambar"
8. ✅ Galeri terbuka
9. ✅ Pilih gambar
10. ✅ Preview gambar tampil
11. ✅ Klik "Upload"
12. ✅ Loading indicator muncul
13. ✅ Notifikasi sukses/gagal muncul

---

## 🐛 COMMON ISSUES

### Issue: "Selamat datang, User" (bukan nama asli)
**Fix:**
1. Cek response login di backend
2. Pastikan format: `{ data: { user: { name: "..." }, token: "..." } }`
3. Clear app data dan login ulang

### Issue: Gambar lapangan tidak tampil
**Fix:**
1. Cek response `/fields` di backend
2. Pastikan field `image` ada
3. Pastikan backend serve static files: `app.use('/uploads', express.static('uploads'))`
4. Cek URL gambar di network inspector

### Issue: Menu Pembayaran tidak muncul
**Fix:**
1. Pastikan `payment_page.dart` sudah di-import di `dashboard_page.dart`
2. Pastikan kode menu Pembayaran sudah ditambahkan di `_buildMenuCards()`
3. Hot reload atau restart app

### Issue: Upload pembayaran gagal
**Fix:**
1. Pastikan endpoint `/payments` sudah dibuat di backend
2. Pastikan backend menerima multipart/form-data
3. Cek field names: `booking_id`, `payment_proof`
4. Cek response error dari backend

### Issue: Daftar booking kosong
**Fix:**
1. Pastikan ada data booking di database
2. Cek endpoint `/bookings` di backend
3. Pastikan response format: `{ data: { data: [...] } }`
4. Cek token authorization

---

## 📱 PLATFORM SPECIFIC

### Android
- Base URL: `http://10.0.2.2:9000`
- Permissions: Internet, Camera, Storage (sudah ada di AndroidManifest.xml)

### iOS
- Base URL: `http://localhost:9000`
- Permissions: Camera, Photo Library (perlu ditambahkan di Info.plist)

### Web
- Base URL: `http://localhost:9000`
- CORS: Backend harus enable CORS

---

## 🔧 TROUBLESHOOTING COMMANDS

### Clear Flutter Cache
```bash
flutter clean
flutter pub get
```

### Clear App Data (Android)
```bash
adb shell pm clear com.example.inventory_apps
```

### Restart Backend
```bash
# Stop backend
# Start backend
npm start
# atau
node server.js
```

### Check Backend Logs
```bash
# Lihat log backend untuk error
tail -f backend.log
```

---

## 📋 FILES MODIFIED/CREATED

### Modified Files
1. `lib/services/auth_service.dart` - Perbaikan parsing nama user
2. `lib/models/field_model.dart` - Perbaikan URL gambar
3. `lib/views/dashboard_page.dart` - Tambah menu Pembayaran

### New Files
1. `lib/services/payment_service.dart` - Service upload pembayaran
2. `lib/models/payment_model.dart` - Model pembayaran
3. `lib/views/payment_page.dart` - Halaman pembayaran

### Documentation Files
1. `REVISION_SUMMARY.md` - Ringkasan revisi
2. `DEBUG_GUIDE.md` - Panduan debugging
3. `BACKEND_API_REQUIREMENTS.md` - Spesifikasi API backend
4. `QUICK_FIX_CHECKLIST.md` - Checklist ini

---

## ✨ NEXT STEPS (Optional Improvements)

1. [ ] Tambahkan validasi ukuran file (max 5MB)
2. [ ] Tambahkan crop/resize gambar sebelum upload
3. [ ] Tambahkan history pembayaran
4. [ ] Tambahkan filter booking berdasarkan status
5. [ ] Tambahkan notifikasi push untuk status pembayaran
6. [ ] Tambahkan dark mode
7. [ ] Tambahkan multi-language support
8. [ ] Tambahkan unit tests
9. [ ] Tambahkan integration tests
10. [ ] Tambahkan CI/CD pipeline

---

## 📞 SUPPORT

Jika masih ada masalah setelah mengikuti checklist ini:

1. Periksa log console untuk error messages
2. Periksa network inspector untuk API calls
3. Periksa backend logs
4. Gunakan `DEBUG_GUIDE.md` untuk debugging lebih detail
5. Periksa `BACKEND_API_REQUIREMENTS.md` untuk format API yang benar

---

**Last Updated:** 1 Juni 2026
**Flutter Version:** 3.41.7
**Dart Version:** 3.11.5
