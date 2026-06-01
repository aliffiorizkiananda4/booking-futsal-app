# Quick Start Guide - Futsal Booking App

Panduan cepat untuk menjalankan aplikasi Futsal Booking dalam 5 menit.

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- ✅ Flutter SDK installed
- ✅ Android Studio / VS Code installed
- ✅ Android Emulator / iOS Simulator / Physical Device
- ✅ Backend API running

### Step 1: Clone & Install (1 minute)
```bash
# Clone repository
git clone <repository-url>
cd invenTrack

# Install dependencies
flutter pub get
```

### Step 2: Start Backend (1 minute)
```bash
# Pastikan backend running di port 9000
# Contoh:
cd backend
npm start
# atau
node server.js
```

### Step 3: Run App (1 minute)
```bash
# Start emulator (jika belum running)
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

### Step 4: Test Login (2 minutes)
1. **Register** akun baru:
   - Nama: Test User
   - Email: test@example.com
   - Phone: 081234567890
   - Password: password123

2. **Login** dengan akun yang baru dibuat

3. **Explore** fitur:
   - Lihat daftar lapangan
   - Klik detail lapangan
   - Booking lapangan
   - Lihat riwayat booking

---

## 📱 Platform-Specific Setup

### Android Emulator
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

**Base URL:** `http://10.0.2.2:9000`

### iOS Simulator (Mac only)
```bash
# Open simulator
open -a Simulator

# Run app
flutter run
```

**Base URL:** `http://localhost:9000`

### Physical Device

#### Android
1. Enable Developer Options
2. Enable USB Debugging
3. Connect via USB
4. Run `flutter run`

#### iOS
1. Trust computer
2. Connect via USB
3. Run `flutter run`

**Important:** Update base URL di `lib/config/api_config.dart` dengan IP komputer Anda.

---

## 🔧 Common Issues & Solutions

### Issue 1: "Connection Refused"
```bash
# Check backend is running
curl http://localhost:9000/health

# For Android Emulator, use 10.0.2.2
# For iOS Simulator, use localhost
# For Physical Device, use computer's IP (e.g., 192.168.1.100)
```

### Issue 2: "Build Failed"
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Issue 3: "No Device Found"
```bash
# Check connected devices
flutter devices

# If no device, start emulator
flutter emulators --launch <emulator_id>
```

### Issue 4: "Token Invalid"
```bash
# Solution: Logout and login again
# Or clear app data from device settings
```

---

## 📚 Project Structure

```
lib/
├── config/          # API configuration
├── models/          # Data models
├── services/        # API services
├── views/           # UI screens
├── widgets/         # Reusable widgets
└── main.dart        # Entry point
```

---

## 🎯 Key Features

### 1. Authentication
- Register new account
- Login with email & password
- Auto-login
- Logout

### 2. Fields
- View all futsal fields
- View field details
- See field images, type, price

### 3. Booking
- View available schedules
- Select schedule
- Create booking
- View booking status

### 4. History
- View all bookings
- See booking status (pending/approved/rejected)
- Pagination support

---

## 🔑 Test Credentials

### Default Admin (if seeded)
```
Email: admin@gmail.com
Password: admin123
```

### Create Your Own
Use the register feature to create a new user account.

---

## 📖 Documentation

- **README.md** - Full project documentation
- **API_DOCUMENTATION.md** - API endpoints reference
- **TESTING_GUIDE.md** - Comprehensive testing guide
- **REFACTOR_SUMMARY.md** - Refactor details
- **DEPLOYMENT_CHECKLIST.md** - Deployment guide

---

## 🆘 Need Help?

### Check Logs
```bash
# Flutter logs
flutter logs

# Android logs
adb logcat

# iOS logs
idevicesyslog
```

### Debug Mode
```bash
# Run in debug mode
flutter run --debug

# Run in profile mode
flutter run --profile

# Run in release mode
flutter run --release
```

### Common Commands
```bash
# Check Flutter doctor
flutter doctor

# Check devices
flutter devices

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## 🎨 Customization

### Change Theme Color
Edit `lib/main.dart`:
```dart
theme: ThemeData(
  primaryColor: const Color(0xFF22C55E), // Change this
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF22C55E), // And this
  ),
),
```

### Change API URL
Edit `lib/config/api_config.dart`:
```dart
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:9000'; // Web URL
  } else {
    return 'http://10.0.2.2:9000'; // Mobile URL
  }
}
```

### Change App Name
Edit `pubspec.yaml`:
```yaml
name: futsal_booking_app # Change this
```

---

## 📱 Screenshots

### Login Screen
- Modern UI with green theme
- Email & password fields
- Register link

### Dashboard
- Quick access cards
- Lapangan Futsal
- Riwayat Booking
- Booking Sekarang

### Field List
- Grid/List of fields
- Field images
- Field type & price

### Booking
- Schedule selection
- Date & time display
- Confirmation dialog

---

## 🚀 Next Steps

1. ✅ Run the app
2. ✅ Test all features
3. ✅ Read full documentation
4. ✅ Customize as needed
5. ✅ Deploy to production

---

## 💡 Tips

1. **Use Hot Reload**: Press `r` in terminal for hot reload
2. **Use Hot Restart**: Press `R` in terminal for hot restart
3. **Check Logs**: Always check logs for errors
4. **Test on Real Device**: Test on physical device before production
5. **Read Documentation**: Check all documentation files

---

## ✅ Checklist

- [ ] Backend running
- [ ] Dependencies installed
- [ ] App running on device/emulator
- [ ] Can register new user
- [ ] Can login
- [ ] Can view fields
- [ ] Can create booking
- [ ] Can view booking history

---

**Ready to go! 🎉**

If you completed all steps above, your app is ready for development and testing.

For detailed information, check the other documentation files:
- README.md
- API_DOCUMENTATION.md
- TESTING_GUIDE.md
- DEPLOYMENT_CHECKLIST.md
