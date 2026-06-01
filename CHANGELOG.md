# Changelog

All notable changes to the Futsal Booking App project will be documented in this file.

## [1.0.0] - 2024-06-01

### 🎉 Initial Release - Refactor from Inventory System to Futsal Booking

### Added
- **Authentication System**
  - User registration with email, password, name, and phone
  - User login with email and password
  - Auto-login functionality using SharedPreferences
  - Logout functionality
  - Token-based authentication (Bearer Token)

- **Field Management**
  - View all available futsal fields
  - View field details (name, type, price, description, image)
  - Field card with image, name, type, and price display

- **Booking System**
  - View available schedules
  - Create new booking
  - Select schedule from available slots
  - Booking confirmation dialog
  - Booking status tracking (pending, approved, rejected)

- **Booking History**
  - View user's booking history
  - Pagination support (10 items per page)
  - Status badges with color coding:
    - Yellow for pending
    - Green for approved
    - Red for rejected
  - Display field name and booking date

- **Dashboard**
  - Quick access to all features
  - Modern card-based UI
  - Smooth animations and transitions
  - User greeting with name

- **UI/UX**
  - Modern Material Design 3
  - Green color theme (futsal branding)
  - Smooth animations and transitions
  - Loading indicators
  - Error handling with user-friendly messages
  - Empty states for lists
  - Responsive layout

### Changed
- **Models**
  - `ItemModel` → `FieldModel`
    - Changed from inventory item to futsal field
    - Added: type, price, description
    - Removed: stock
  
  - `LoanModel` → `BookingModel`
    - Changed from loan tracking to booking
    - Added: userId, fieldId, scheduleId, status
    - Removed: name, totalItem

- **Services**
  - `ItemService` → `FieldService`
    - Endpoints changed from `/items` to `/fields`
    - Methods adapted for field management
  
  - `LoanService` → `BookingService`
    - Endpoints changed from `/loans` to `/bookings`
    - Methods adapted for booking management
  
  - `AuthService` (Updated)
    - Changed from username to email-based login
    - Added register functionality
    - Added logout and session management

- **Views**
  - `dashboard.dart` → `dashboard_page.dart`
    - Changed theme from blue to green
    - Updated icons from inventory to soccer
    - Changed menu items to futsal-related features
  
  - `data_barang_page.dart` → `field_page.dart`
    - Changed from item list to field list
    - Removed CRUD operations (admin only)
    - Added navigation to field detail
  
  - `peminjaman_page.dart` → `booking_history_page.dart`
    - Changed from loan list to booking history
    - Added status badges
    - Updated UI to match futsal theme
  
  - `buat_peminjaman_page.dart` → `booking_page.dart`
    - Changed from loan form to booking form
    - Added schedule selection
    - Removed item selection

- **Configuration**
  - Base URL changed to `http://10.0.2.2:9000` (Android Emulator)
  - App name changed from "InvenTrack" to "FutsalBooking"
  - Primary color changed from blue (#2563EB) to green (#22C55E)

### Removed
- Inventory-related terminology
- Stock management features
- Item CRUD operations (moved to admin panel)
- Loan return functionality

### Technical Details
- **Flutter Version**: 3.10.7
- **Dart Version**: 3.10.7
- **Dependencies**:
  - http: ^1.6.0
  - shared_preferences: ^2.5.5
  - image_picker: ^1.2.2
  - lottie: ^3.3.3
  - cupertino_icons: ^1.0.8

### File Structure
```
lib/
├── config/
│   └── api_config.dart (Updated)
├── models/
│   ├── user_model.dart (New)
│   ├── field_model.dart (Refactored from item_model.dart)
│   ├── schedule_model.dart (New)
│   └── booking_model.dart (Refactored from loan_model.dart)
├── services/
│   ├── auth_service.dart (Updated)
│   ├── field_service.dart (Refactored from item_service.dart)
│   ├── schedule_service.dart (New)
│   └── booking_service.dart (Refactored from loan_service.dart)
├── views/
│   ├── login_page.dart (Updated)
│   ├── register_page.dart (New)
│   ├── onboarding_page.dart (Kept)
│   ├── dashboard_page.dart (Refactored from dashboard.dart)
│   ├── field_page.dart (Refactored from data_barang_page.dart)
│   ├── field_detail_page.dart (New)
│   ├── booking_page.dart (Refactored from buat_peminjaman_page.dart)
│   └── booking_history_page.dart (Refactored from peminjaman_page.dart)
├── widgets/
│   ├── button/ (Kept)
│   ├── card/ (Kept)
│   ├── form/ (Kept)
│   ├── loading_widget.dart (New)
│   └── field_card.dart (New)
└── main.dart (Updated)
```

### Documentation
- Added `README.md` - Project overview and setup guide
- Added `REFACTOR_SUMMARY.md` - Detailed refactor documentation
- Added `TESTING_GUIDE.md` - Comprehensive testing guide
- Added `API_DOCUMENTATION.md` - Complete API reference
- Added `CHANGELOG.md` - This file

### Known Issues
None at this time.

### Migration Notes
For developers migrating from the inventory system:
1. Update all imports from `item_model` to `field_model`
2. Update all imports from `loan_model` to `booking_model`
3. Update service calls to use new endpoints
4. Update UI components to use green theme
5. Test authentication flow with email instead of username

### Breaking Changes
- Authentication now uses email instead of username
- All endpoints have changed (items → fields, loans → bookings)
- Model structure completely changed
- Token format may have changed (check with backend)

### Future Enhancements
- [ ] Payment integration
- [ ] Push notifications for booking status
- [ ] Field availability calendar view
- [ ] User profile management
- [ ] Booking cancellation
- [ ] Rating and review system
- [ ] Admin panel for field management
- [ ] Multi-language support
- [ ] Dark mode

---

## Version History

### [1.0.0] - 2024-06-01
- Initial release after refactor from inventory system

---

**Note**: This project was refactored from an inventory management system to a futsal field booking system. All inventory-related features have been replaced with booking-related features while maintaining the core architecture and reusable components.
