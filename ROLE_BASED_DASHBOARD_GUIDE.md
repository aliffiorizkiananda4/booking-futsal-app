# ROLE-BASED DASHBOARD IMPLEMENTATION GUIDE

## OVERVIEW

Aplikasi sekarang memiliki 2 dashboard berbeda berdasarkan role user:
- **Admin Dashboard** - Untuk role `admin`
- **User Dashboard** - Untuk role `user`

---

## ARSITEKTUR

### Flow Diagram
```
Login
  ↓
AuthService.login() → Simpan: token, name, role
  ↓
DashboardRouter
  ↓
  ├─→ role == "admin" → AdminDashboardPage
  └─→ role == "user"  → UserDashboardPage
```

### File Structure
```
lib/
├── services/
│   └── auth_service.dart          (UPDATED - tambah getRole())
├── views/
│   ├── admin_dashboard_page.dart  (NEW - Dashboard Admin)
│   ├── user_dashboard_page.dart   (NEW - Dashboard User)
│   ├── dashboard_router.dart      (NEW - Router berdasarkan role)
│   ├── login_page.dart            (UPDATED - gunakan DashboardRouter)
│   └── old_dashboard_page.dart.bak (BACKUP - dashboard lama)
└── main.dart                      (UPDATED - gunakan DashboardRouter)
```

---

## ROLE USER

### Menu yang Tampil
1. **Lapangan Futsal** - Lihat daftar lapangan
2. **Booking Lapangan** - Buat booking baru
3. **Riwayat Booking** - Lihat riwayat booking
4. **Upload Pembayaran** - Upload bukti pembayaran

### Hak Akses User
✅ **DAPAT:**
- Melihat lapangan yang tersedia
- Melakukan booking lapangan
- Melihat riwayat booking miliknya
- Mengupload bukti pembayaran

❌ **TIDAK DAPAT:**
- Tambah/edit/hapus lapangan
- Tambah/edit jadwal
- Approve/reject booking
- Approve/reject pembayaran
- Melihat booking user lain
- Akses menu admin

### UI Design
- **Warna Tema:** Hijau (`#22C55E`) dan Biru (`#0EA5E9`)
- **Icon Profile:** Person icon
- **Badge Role:** "User" dengan warna biru

---

## ROLE ADMIN

### Menu yang Tampil
1. **Dashboard Statistik** - Lihat statistik sistem
2. **Kelola Lapangan** - CRUD lapangan
3. **Kelola Jadwal** - CRUD jadwal
4. **Kelola Booking** - Approve/reject booking
5. **Kelola Pembayaran** - Verifikasi pembayaran
6. **Kelola User** - Manajemen user

### Hak Akses Admin
✅ **DAPAT:**
- Tambah/edit/hapus lapangan
- Tambah/edit jadwal
- Melihat seluruh booking
- Approve/reject booking
- Melihat bukti pembayaran
- Approve/reject pembayaran
- Manajemen user

❌ **TIDAK PERLU:**
- Menu booking lapangan (admin tidak booking)
- Menu upload pembayaran (admin tidak bayar)

### Dashboard Statistik
Admin dashboard menampilkan:
- **Total Lapangan** - Jumlah lapangan yang terdaftar
- **Total Booking** - Jumlah semua booking
- **Booking Pending** - Booking yang menunggu approval
- **Booking Approved** - Booking yang sudah disetujui
- **Pembayaran Pending** - Pembayaran yang menunggu verifikasi

### UI Design
- **Warna Tema:** Merah (`#EF4444`)
- **Icon Profile:** Admin panel icon
- **Badge Role:** "Administrator" dengan warna merah
- **AppBar:** Gradient merah dengan label "Admin Panel"

---

## IMPLEMENTASI TEKNIS

### 1. Auth Service Updates

**File:** `lib/services/auth_service.dart`

#### Menyimpan Role saat Login
```dart
static Future<bool> login(String email, String password) async {
  // ... existing code ...
  
  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    
    final String token = responseData['data']?['token'] ?? '';
    final String name = responseData['data']?['user']?['name'] ?? 'User';
    final String role = responseData['data']?['user']?['role'] ?? 'user';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("name", name);
    await prefs.setString("role", role);  // ← BARU
    
    return true;
  }
}
```

#### Method Baru: getRole()
```dart
static Future<String> getRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("role") ?? "user";
}
```

#### Update Logout
```dart
static Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("token");
  await prefs.remove("name");
  await prefs.remove("role");  // ← BARU
}
```

---

### 2. Dashboard Router

**File:** `lib/views/dashboard_router.dart`

Router ini menentukan dashboard mana yang ditampilkan berdasarkan role:

```dart
class DashboardRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AuthService.getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        final role = snapshot.data ?? 'user';

        if (role == 'admin') {
          return const AdminDashboardPage();
        } else {
          return const UserDashboardPage();
        }
      },
    );
  }
}
```

**Keuntungan:**
- Single source of truth untuk routing dashboard
- Mudah di-maintain
- Otomatis redirect berdasarkan role
- Loading state saat mengambil role

---

### 3. User Dashboard Page

**File:** `lib/views/user_dashboard_page.dart`

**Fitur:**
- 4 menu card untuk user
- Animasi smooth saat load
- Profile dialog dengan badge "User"
- Navigasi ke halaman yang sesuai

**Menu Cards:**
1. Lapangan Futsal (large card, hijau)
2. Booking Lapangan (small card, hijau)
3. Riwayat Booking (small card, hijau)
4. Upload Pembayaran (large card, biru)

---

### 4. Admin Dashboard Page

**File:** `lib/views/admin_dashboard_page.dart`

**Fitur:**
- Statistik real-time dari API
- Pull-to-refresh untuk update statistik
- 5 menu admin
- Profile dialog dengan badge "Administrator"
- AppBar dengan gradient merah

**Statistik Cards:**
- Total Lapangan
- Total Booking
- Booking Pending
- Booking Approved
- Pembayaran Pending

**Menu Admin:**
1. Kelola Lapangan
2. Kelola Jadwal
3. Kelola Booking
4. Kelola Pembayaran
5. Kelola User

**Note:** Menu admin saat ini menampilkan "Fitur dalam pengembangan". Implementasi CRUD akan dilakukan di fase berikutnya.

---

## BACKEND API REQUIREMENTS

### Login Response Format

Backend HARUS mengirim role dalam response login:

```json
{
  "status": 200,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Administrator",
      "email": "admin@gmail.com",
      "role": "admin"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Role Values
- `"admin"` - Untuk administrator
- `"user"` - Untuk user biasa

### Database Schema

Pastikan table `users` memiliki kolom `role`:

```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role ENUM('admin', 'user') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Sample Data

```sql
-- Admin user
INSERT INTO users (name, email, password, role) 
VALUES ('Administrator', 'admin@gmail.com', '$2b$10$...', 'admin');

-- Regular user
INSERT INTO users (name, email, password, role) 
VALUES ('John Doe', 'user@gmail.com', '$2b$10$...', 'user');
```

---

## TESTING GUIDE

### Test Case 1: Login sebagai Admin

**Steps:**
1. Login dengan email: `admin@gmail.com`
2. Password: (password admin)

**Expected Result:**
- ✅ Redirect ke Admin Dashboard
- ✅ AppBar berwarna merah dengan label "Admin Panel"
- ✅ Tampil statistik dashboard
- ✅ Tampil 5 menu admin
- ✅ Profile dialog menampilkan badge "Administrator"

### Test Case 2: Login sebagai User

**Steps:**
1. Login dengan email: `user@gmail.com`
2. Password: (password user)

**Expected Result:**
- ✅ Redirect ke User Dashboard
- ✅ AppBar berwarna putih dengan label "FutsalBooking"
- ✅ Tampil 4 menu user
- ✅ Profile dialog menampilkan badge "User"
- ✅ Tidak ada menu admin

### Test Case 3: Logout dan Login Ulang

**Steps:**
1. Login sebagai admin
2. Logout
3. Login sebagai user

**Expected Result:**
- ✅ Setelah logout, redirect ke login page
- ✅ SharedPreferences dibersihkan (token, name, role)
- ✅ Login ulang dengan role berbeda menampilkan dashboard yang sesuai

### Test Case 4: Direct Access (Refresh App)

**Steps:**
1. Login sebagai admin
2. Close app
3. Open app lagi

**Expected Result:**
- ✅ Langsung masuk ke Admin Dashboard (tidak perlu login lagi)
- ✅ Role tersimpan di SharedPreferences

---

## TROUBLESHOOTING

### Issue 1: Selalu masuk ke User Dashboard meskipun login sebagai admin

**Penyebab:**
- Backend tidak mengirim field `role` dalam response
- Role tidak tersimpan di SharedPreferences

**Solusi:**
1. Cek response login di backend
2. Pastikan format response sesuai dengan yang diharapkan
3. Clear app data dan login ulang:
   ```bash
   adb shell pm clear com.example.inventory_apps
   ```

**Debug:**
```dart
// Tambahkan print di auth_service.dart
final String role = responseData['data']?['user']?['role'] ?? 'user';
print('Role from API: $role');

// Tambahkan print di dashboard_router.dart
final role = snapshot.data ?? 'user';
print('Role from SharedPreferences: $role');
```

### Issue 2: Statistik tidak muncul di Admin Dashboard

**Penyebab:**
- API fields atau bookings error
- Token tidak valid

**Solusi:**
1. Cek endpoint `/fields` dan `/bookings`
2. Pastikan token dikirim dengan benar
3. Pull-to-refresh untuk reload data

**Debug:**
```dart
// Tambahkan print di admin_dashboard_page.dart
Future<void> _loadStatistics() async {
  try {
    final fields = await fieldService.getFields();
    print('Total fields: ${fields.length}');
    
    final bookingsData = await bookingService.fetchBookings(limit: 1000);
    print('Bookings data: $bookingsData');
  } catch (e) {
    print('Error loading statistics: $e');
  }
}
```

### Issue 3: Menu admin tidak berfungsi

**Expected Behavior:**
Menu admin saat ini menampilkan SnackBar "Fitur dalam pengembangan".

**Next Phase:**
Implementasi halaman CRUD untuk:
- Kelola Lapangan
- Kelola Jadwal
- Kelola Booking
- Kelola Pembayaran
- Kelola User

---

## SECURITY CONSIDERATIONS

### 1. Role Validation di Backend

**PENTING:** Frontend hanya menyembunyikan UI berdasarkan role. Backend HARUS melakukan validasi role untuk setiap endpoint.

**Contoh (Express.js):**
```javascript
// Middleware untuk cek role admin
const isAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({
      status: 403,
      message: 'Access denied. Admin only.'
    });
  }
  next();
};

// Protect admin endpoints
app.post('/fields', authenticateToken, isAdmin, createField);
app.put('/fields/:id', authenticateToken, isAdmin, updateField);
app.delete('/fields/:id', authenticateToken, isAdmin, deleteField);
```

### 2. Token Validation

Setiap request harus menyertakan token yang valid:
```dart
Future<Map<String, String>> _getHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token") ?? "";
  return {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}
```

### 3. Role Tampering Prevention

User tidak bisa mengubah role di SharedPreferences untuk mendapat akses admin karena:
1. Backend memvalidasi role dari token JWT
2. Token JWT di-sign oleh backend
3. Frontend hanya menggunakan role untuk UI, bukan authorization

---

## MIGRATION GUIDE

### Dari Dashboard Lama ke Role-Based Dashboard

**File yang Diubah:**
1. `lib/services/auth_service.dart` - Tambah getRole()
2. `lib/views/login_page.dart` - Gunakan DashboardRouter
3. `lib/main.dart` - Gunakan DashboardRouter

**File Baru:**
1. `lib/views/admin_dashboard_page.dart`
2. `lib/views/user_dashboard_page.dart`
3. `lib/views/dashboard_router.dart`

**File Backup:**
1. `lib/views/old_dashboard_page.dart.bak` - Dashboard lama (backup)

**Breaking Changes:**
- `DashboardScreen` tidak digunakan lagi
- Semua navigasi ke dashboard harus menggunakan `DashboardRouter`

**Migration Steps:**
1. Update backend untuk mengirim role dalam response login
2. Clear app data untuk reset SharedPreferences
3. Login ulang untuk mendapatkan role baru

---

## NEXT STEPS

### Phase 1: Admin CRUD Pages (Prioritas Tinggi)
- [ ] Kelola Lapangan Page (CRUD fields)
- [ ] Kelola Jadwal Page (CRUD schedules)
- [ ] Kelola Booking Page (Approve/Reject)
- [ ] Kelola Pembayaran Page (Verify payments)
- [ ] Kelola User Page (CRUD users)

### Phase 2: Enhanced Features
- [ ] Real-time notifications
- [ ] Export data to Excel/PDF
- [ ] Advanced filtering & search
- [ ] Bulk operations
- [ ] Activity logs

### Phase 3: UI/UX Improvements
- [ ] Dark mode
- [ ] Custom themes
- [ ] Animations & transitions
- [ ] Responsive design for tablet
- [ ] Accessibility improvements

---

## CHANGELOG

### Version 2.0.0 - Role-Based Dashboard

**Added:**
- Admin Dashboard dengan statistik real-time
- User Dashboard dengan menu yang sesuai
- Dashboard Router untuk routing berdasarkan role
- Role storage di SharedPreferences
- Profile dialog dengan badge role

**Changed:**
- Login flow sekarang redirect ke DashboardRouter
- Main.dart menggunakan DashboardRouter
- Auth service menyimpan role

**Deprecated:**
- `DashboardScreen` (diganti dengan AdminDashboardPage & UserDashboardPage)

**Removed:**
- None

**Fixed:**
- Role-based access control
- Proper navigation based on user role

---

**Last Updated:** 1 Juni 2026
**Version:** 2.0.0
**Author:** Development Team
