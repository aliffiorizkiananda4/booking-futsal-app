# ROLE-BASED DASHBOARD TESTING CHECKLIST

## PRE-TESTING SETUP

### Backend Requirements
- [ ] Backend berjalan di port 9000
- [ ] Database memiliki kolom `role` di table `users`
- [ ] Ada user dengan role `admin`
- [ ] Ada user dengan role `user`
- [ ] Login API mengirim field `role` dalam response

### Sample Users
```sql
-- Admin User
INSERT INTO users (name, email, password, role) 
VALUES ('Administrator', 'admin@gmail.com', '$2b$10$hashedpassword', 'admin');

-- Regular User
INSERT INTO users (name, email, password, role) 
VALUES ('John Doe', 'user@gmail.com', '$2b$10$hashedpassword', 'user');
```

### Clear App Data (Recommended)
```bash
# Android
adb shell pm clear com.example.inventory_apps

# iOS
# Uninstall and reinstall app
```

---

## TEST SUITE 1: ADMIN ROLE

### Test 1.1: Login sebagai Admin
**Steps:**
1. Buka aplikasi
2. Klik "Login" di onboarding
3. Input email: `admin@gmail.com`
4. Input password: (password admin)
5. Klik tombol "Login"

**Expected Results:**
- [ ] Loading indicator muncul
- [ ] Redirect ke Admin Dashboard
- [ ] AppBar berwarna merah gradient
- [ ] AppBar menampilkan "Admin Panel"
- [ ] Icon admin panel di AppBar
- [ ] Nama admin tampil: "Halo, Administrator 👋"
- [ ] Subtitle: "Kelola sistem booking futsal"

### Test 1.2: Admin Dashboard Statistik
**Expected Results:**
- [ ] Section "Statistik" tampil
- [ ] Card "Total Lapangan" tampil dengan icon hijau
- [ ] Card "Total Booking" tampil dengan icon biru
- [ ] Card "Pending" tampil dengan icon kuning
- [ ] Card "Approved" tampil dengan icon ungu
- [ ] Card "Pembayaran Pending" tampil dengan icon merah
- [ ] Angka statistik sesuai dengan data di database
- [ ] Pull-to-refresh berfungsi

### Test 1.3: Admin Menu
**Expected Results:**
- [ ] Section "Menu Admin" tampil
- [ ] Menu "Kelola Lapangan" tampil (icon hijau)
- [ ] Menu "Kelola Jadwal" tampil (icon biru)
- [ ] Menu "Kelola Booking" tampil (icon kuning)
- [ ] Menu "Kelola Pembayaran" tampil (icon ungu)
- [ ] Menu "Kelola User" tampil (icon merah)
- [ ] Klik menu menampilkan "Fitur dalam pengembangan"

### Test 1.4: Admin Profile Dialog
**Steps:**
1. Klik icon logout di AppBar

**Expected Results:**
- [ ] Dialog muncul
- [ ] Icon admin panel dengan gradient merah
- [ ] Nama admin tampil
- [ ] Badge "Administrator" dengan warna merah tampil
- [ ] Text "Anda yakin ingin logout?"
- [ ] Tombol "Batal" dan "Logout" tampil

### Test 1.5: Admin Logout
**Steps:**
1. Klik icon logout di AppBar
2. Klik tombol "Logout"

**Expected Results:**
- [ ] Dialog tertutup
- [ ] Redirect ke Login page
- [ ] SharedPreferences dibersihkan
- [ ] Tidak bisa back ke dashboard

---

## TEST SUITE 2: USER ROLE

### Test 2.1: Login sebagai User
**Steps:**
1. Buka aplikasi
2. Klik "Login" di onboarding
3. Input email: `user@gmail.com`
4. Input password: (password user)
5. Klik tombol "Login"

**Expected Results:**
- [ ] Loading indicator muncul
- [ ] Redirect ke User Dashboard
- [ ] AppBar berwarna putih
- [ ] AppBar menampilkan "FutsalBooking"
- [ ] Icon futsal di AppBar (hijau)
- [ ] Nama user tampil: "Selamat datang, John Doe 👋"
- [ ] Subtitle: "Booking lapangan futsal dengan mudah"

### Test 2.2: User Dashboard Menu
**Expected Results:**
- [ ] Menu "Lapangan Futsal" tampil (large card, hijau)
- [ ] Menu "Booking Lapangan" tampil (small card, hijau kiri)
- [ ] Menu "Riwayat Booking" tampil (small card, hijau kanan)
- [ ] Menu "Upload Pembayaran" tampil (large card, biru)
- [ ] TIDAK ada menu admin
- [ ] TIDAK ada statistik dashboard

### Test 2.3: User Menu Navigation
**Steps:**
1. Klik menu "Lapangan Futsal"

**Expected Results:**
- [ ] Redirect ke Field Page
- [ ] Data lapangan tampil

**Steps:**
2. Back ke dashboard
3. Klik menu "Booking Lapangan"

**Expected Results:**
- [ ] Redirect ke Booking Page

**Steps:**
4. Back ke dashboard
5. Klik menu "Riwayat Booking"

**Expected Results:**
- [ ] Redirect ke Booking History Page
- [ ] Hanya tampil booking milik user yang login

**Steps:**
6. Back ke dashboard
7. Klik menu "Upload Pembayaran"

**Expected Results:**
- [ ] Redirect ke Payment Page
- [ ] Tampil daftar booking user

### Test 2.4: User Profile Dialog
**Steps:**
1. Klik icon logout di AppBar

**Expected Results:**
- [ ] Dialog muncul
- [ ] Icon person dengan gradient hijau
- [ ] Nama user tampil
- [ ] Badge "User" dengan warna biru tampil
- [ ] Text "Anda yakin ingin logout?"
- [ ] Tombol "Batal" dan "Logout" tampil

### Test 2.5: User Logout
**Steps:**
1. Klik icon logout di AppBar
2. Klik tombol "Logout"

**Expected Results:**
- [ ] Dialog tertutup
- [ ] Redirect ke Login page
- [ ] SharedPreferences dibersihkan
- [ ] Tidak bisa back ke dashboard

---

## TEST SUITE 3: ROLE SWITCHING

### Test 3.1: Admin → User
**Steps:**
1. Login sebagai admin
2. Verifikasi masuk Admin Dashboard
3. Logout
4. Login sebagai user
5. Verifikasi masuk User Dashboard

**Expected Results:**
- [ ] Dashboard berubah sesuai role
- [ ] Menu berubah sesuai role
- [ ] AppBar berubah sesuai role
- [ ] Profile badge berubah sesuai role

### Test 3.2: User → Admin
**Steps:**
1. Login sebagai user
2. Verifikasi masuk User Dashboard
3. Logout
4. Login sebagai admin
5. Verifikasi masuk Admin Dashboard

**Expected Results:**
- [ ] Dashboard berubah sesuai role
- [ ] Menu berubah sesuai role
- [ ] AppBar berubah sesuai role
- [ ] Profile badge berubah sesuai role

---

## TEST SUITE 4: PERSISTENCE

### Test 4.1: Admin Session Persistence
**Steps:**
1. Login sebagai admin
2. Verifikasi masuk Admin Dashboard
3. Close app (kill process)
4. Open app lagi

**Expected Results:**
- [ ] Langsung masuk ke Admin Dashboard (tidak perlu login)
- [ ] Role tersimpan di SharedPreferences
- [ ] Token masih valid

### Test 4.2: User Session Persistence
**Steps:**
1. Login sebagai user
2. Verifikasi masuk User Dashboard
3. Close app (kill process)
4. Open app lagi

**Expected Results:**
- [ ] Langsung masuk ke User Dashboard (tidak perlu login)
- [ ] Role tersimpan di SharedPreferences
- [ ] Token masih valid

---

## TEST SUITE 5: ERROR HANDLING

### Test 5.1: Backend Tidak Mengirim Role
**Scenario:** Backend response tidak ada field `role`

**Expected Results:**
- [ ] Default role = "user"
- [ ] Masuk ke User Dashboard
- [ ] Tidak ada crash

### Test 5.2: Invalid Role Value
**Scenario:** Backend mengirim role = "superadmin" (tidak valid)

**Expected Results:**
- [ ] Fallback ke "user"
- [ ] Masuk ke User Dashboard
- [ ] Tidak ada crash

### Test 5.3: Network Error saat Load Statistik
**Scenario:** Admin dashboard, backend down

**Expected Results:**
- [ ] Loading indicator muncul
- [ ] Setelah timeout, statistik = 0
- [ ] Menu admin tetap tampil
- [ ] Pull-to-refresh bisa retry

---

## TEST SUITE 6: UI/UX

### Test 6.1: Admin Dashboard Animations
**Expected Results:**
- [ ] Fade in animation saat load
- [ ] Slide up animation untuk cards
- [ ] Smooth transitions

### Test 6.2: User Dashboard Animations
**Expected Results:**
- [ ] Fade in animation saat load
- [ ] Slide up animation untuk menu cards
- [ ] Smooth transitions

### Test 6.3: Responsive Layout
**Test on different screen sizes:**
- [ ] Small phone (320x568)
- [ ] Medium phone (375x667)
- [ ] Large phone (414x896)
- [ ] Tablet (768x1024)

**Expected Results:**
- [ ] Layout tidak overflow
- [ ] Text readable
- [ ] Cards proportional

---

## TEST SUITE 7: SECURITY

### Test 7.1: User Cannot Access Admin Features
**Steps:**
1. Login sebagai user
2. Coba akses endpoint admin via API (manual test)

**Expected Results:**
- [ ] Backend return 403 Forbidden
- [ ] User tidak bisa CRUD lapangan
- [ ] User tidak bisa approve booking
- [ ] User tidak bisa verify payment

### Test 7.2: Role Tampering
**Steps:**
1. Login sebagai user
2. Manually change role in SharedPreferences to "admin"
3. Restart app

**Expected Results:**
- [ ] UI menampilkan Admin Dashboard (karena role di SharedPreferences)
- [ ] Tapi API calls tetap gagal (karena token JWT masih role user)
- [ ] Backend reject requests dengan 403

**Note:** Ini menunjukkan pentingnya validasi role di backend!

---

## DEBUGGING CHECKLIST

### Issue: Selalu masuk User Dashboard
**Debug Steps:**
1. [ ] Cek response login di backend
2. [ ] Print role di auth_service.dart
3. [ ] Print role di dashboard_router.dart
4. [ ] Cek SharedPreferences value
5. [ ] Clear app data dan login ulang

**Debug Code:**
```dart
// auth_service.dart
final String role = responseData['data']?['user']?['role'] ?? 'user';
print('🔍 Role from API: $role');

// dashboard_router.dart
final role = snapshot.data ?? 'user';
print('🔍 Role from SharedPreferences: $role');
```

### Issue: Statistik tidak muncul
**Debug Steps:**
1. [ ] Cek endpoint /fields
2. [ ] Cek endpoint /bookings
3. [ ] Print response di admin_dashboard_page.dart
4. [ ] Cek token authorization
5. [ ] Pull-to-refresh untuk retry

**Debug Code:**
```dart
// admin_dashboard_page.dart
Future<void> _loadStatistics() async {
  try {
    final fields = await fieldService.getFields();
    print('📊 Total fields: ${fields.length}');
    
    final bookingsData = await bookingService.fetchBookings(limit: 1000);
    print('📊 Bookings data: $bookingsData');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## PERFORMANCE CHECKLIST

### Load Time
- [ ] Admin Dashboard load < 2 seconds
- [ ] User Dashboard load < 1 second
- [ ] Statistik load < 3 seconds
- [ ] Navigation smooth (no lag)

### Memory Usage
- [ ] No memory leaks
- [ ] Animations dispose properly
- [ ] Controllers dispose properly

### Network
- [ ] API calls optimized
- [ ] No unnecessary requests
- [ ] Proper caching

---

## ACCEPTANCE CRITERIA

### Must Have ✅
- [x] Admin dan User memiliki dashboard berbeda
- [x] Role disimpan di SharedPreferences
- [x] Login redirect ke dashboard yang sesuai
- [x] Admin dashboard menampilkan statistik
- [x] User dashboard menampilkan menu user
- [x] Logout membersihkan role
- [x] Session persistence

### Should Have ✅
- [x] Smooth animations
- [x] Pull-to-refresh statistik
- [x] Profile dialog dengan badge role
- [x] Error handling
- [x] Loading states

### Nice to Have (Future)
- [ ] Admin CRUD pages
- [ ] Real-time statistics
- [ ] Push notifications
- [ ] Dark mode
- [ ] Multi-language

---

## SIGN-OFF

### Developer
- [ ] All tests passed
- [ ] Code reviewed
- [ ] Documentation complete
- [ ] No critical bugs

**Signature:** ________________  
**Date:** ________________

### QA
- [ ] All test cases executed
- [ ] No blocking issues
- [ ] Performance acceptable
- [ ] Ready for deployment

**Signature:** ________________  
**Date:** ________________

---

**Test Report Generated:** 1 Juni 2026  
**App Version:** 2.0.0  
**Flutter Version:** 3.41.7  
**Test Environment:** Development
