# 🐾 PetPerks - Setup Guide untuk Login & Register

## 📋 Daftar Perubahan

Telah ditambahkan fitur autentikasi lengkap untuk aplikasi PetPerks:

### ✅ Yang Sudah Dibuat:

1. **Halaman Login** (`lib/auth/login_page.dart`)
   - UI modern dengan validasi
   - Firebase Authentication integration
   - Forgot password functionality
   - Navigation ke halaman register

2. **Halaman Register** (`lib/auth/register_page.dart`)
   - Form registrasi dengan validasi
   - Password confirmation
   - Auto-login setelah register

3. **Auth Service** (`lib/services/auth_service.dart`)
   - Firebase Authentication wrapper
   - Register, login, logout functionality
   - Password reset
   - Token refresh
   - Account deletion

4. **API Service** (`lib/services/api_service.dart`)
   - HTTP client untuk backend API
   - Token management
   - All API endpoints (auth, profile, etc.)

5. **Main App Update** (`lib/main.dart`)
   - Firebase initialization
   - Auth state management
   - Auto-redirect based on login status

6. **Profile Screen Update** (`lib/profile/profile_screen.dart`)
   - Logout button
   - Display user name dari Firebase
   - Confirmation dialog untuk logout

7. **Postman Collection** (`PetPerks_API_Collection.postman_collection.json`)
   - Complete API testing collection
   - All endpoints dengan examples
   - Test scripts

---

## 🚀 Setup Instructions

### 1. Install Dependencies

Jalankan perintah berikut di terminal:

```bash
cd PetPerks
flutter pub get
```

Dependencies yang ditambahkan:
- `firebase_core` - Firebase initialization
- `firebase_auth` - Firebase Authentication
- `http` - HTTP requests ke backend
- `shared_preferences` - Local storage untuk token
- `provider` - State management (opsional untuk future use)

### 2. Setup Firebase

#### A. Buat Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add project" atau gunakan project yang sudah ada
3. Ikuti wizard setup

#### B. Enable Authentication

1. Di Firebase Console, pilih project Anda
2. Pilih **Authentication** dari menu sidebar
3. Klik tab **Sign-in method**
4. Enable **Email/Password**

#### C. Register Apps di Firebase

**Untuk Android:**
1. Klik icon Android di Project Overview
2. Register app dengan package name: `com.example.petperks`
3. Download `google-services.json`
4. Letakkan file di: `android/app/google-services.json`

**Untuk iOS (Optional):**
1. Klik icon iOS di Project Overview
2. Register app dengan bundle ID dari `ios/Runner/Info.plist`
3. Download `GoogleService-Info.plist`
4. Tambahkan ke Xcode project

**Untuk Web (Optional):**
1. Klik icon Web
2. Copy Firebase config
3. Paste ke `web/index.html`

#### D. Update Firebase Config Files

File `google-services.json` sudah harus ada di `android/app/`.

Jika belum, pastikan struktur seperti ini:
```
PetPerks/
├── android/
│   ├── app/
│   │   ├── google-services.json  ← File ini harus ada!
│   │   └── build.gradle
```

### 3. Konfigurasi Backend API

Update URL backend di `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP:8000/api/v1';
```

**Untuk testing:**
- **Android Emulator**: `http://10.0.2.2:8000/api/v1`
- **iOS Simulator**: `http://localhost:8000/api/v1`
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000/api/v1` (gunakan IP lokal Anda)

### 4. Setup Backend

Pastikan backend Laravel sudah running:

```bash
cd petperks-be

# Install dependencies (jika belum)
composer install

# Setup Firebase credentials
# Download dari Firebase Console > Project Settings > Service Accounts
# Save to: storage/app/firebase-credentials.json

# Update .env
# FIREBASE_CREDENTIALS=storage/app/firebase-credentials.json
# FIREBASE_PROJECT_ID=your-project-id

# Run migrations
php artisan migrate

# Start server
php artisan serve
```

Backend akan jalan di `http://localhost:8000`

---

## 🧪 Testing dengan Postman

### Import Collection

1. Buka Postman
2. File → Import
3. Pilih file `PetPerks_API_Collection.postman_collection.json`

### Setup Environment Variables

Di Postman, create environment dengan variables:

- `base_url`: `http://localhost:8000/api/v1`
- `firebase_token`: (akan diisi otomatis setelah login)

### Testing Flow

1. **Register User**
   - Endpoint: `POST /auth/register`
   - Body: email, password, display_name
   - Simpan response untuk verifikasi

2. **Login via Flutter App**
   - Jalankan Flutter app
   - Login dengan email/password yang sama
   - Ini akan generate Firebase ID token

3. **Get Firebase Token (Cara 1 - Via Debug)**
   ```dart
   // Tambah di auth_service.dart untuk debug
   print('Firebase Token: $idToken');
   ```

4. **Get Firebase Token (Cara 2 - Via API)**
   - Login di Flutter app
   - Copy token dari SharedPreferences
   - Atau gunakan Firebase SDK di Postman (advanced)

5. **Test Protected Endpoints**
   - Copy token ke Postman environment variable `firebase_token`
   - Test semua endpoint dengan Authorization header

### Quick Test Commands

```bash
# Health Check
curl http://localhost:8000/api/health

# Register
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","display_name":"Test User"}'

# Get Profile (dengan token)
curl http://localhost:8000/api/v1/profile \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN"
```

---

## 📱 Running the App

### Run di Android Emulator

```bash
flutter run
```

### Run di iOS Simulator

```bash
flutter run -d ios
```

### Run di Chrome (Web)

```bash
flutter run -d chrome
```

---

## 🔐 Authentication Flow

### 1. Register Flow

```
User Input (Email, Password, Name)
    ↓
Backend Register API (Creates Firebase user)
    ↓
Firebase Sign In (Get ID Token)
    ↓
Save Token to SharedPreferences
    ↓
Navigate to Main Layout
```

### 2. Login Flow

```
User Input (Email, Password)
    ↓
Firebase Sign In
    ↓
Get ID Token from Firebase
    ↓
Backend Login API (Verify token & sync user)
    ↓
Save Token to SharedPreferences
    ↓
Navigate to Main Layout
```

### 3. Logout Flow

```
User Clicks Logout
    ↓
Confirmation Dialog
    ↓
Backend Logout API (Optional cleanup)
    ↓
Firebase Sign Out
    ↓
Clear SharedPreferences
    ↓
Navigate to Login Page
```

---

## 📁 File Structure

```
PetPerks/
├── lib/
│   ├── auth/
│   │   ├── login_page.dart          ← Login UI
│   │   └── register_page.dart       ← Register UI
│   ├── services/
│   │   ├── auth_service.dart        ← Firebase Auth Logic
│   │   └── api_service.dart         ← HTTP API Calls
│   ├── main.dart                    ← Updated with Firebase init
│   └── profile/
│       └── profile_screen.dart      ← Added logout
│
PetPerks_API_Collection.postman_collection.json  ← Postman tests
```

---

## 🐛 Troubleshooting

### Problem: Firebase initialization error

**Solution:**
```bash
# Pastikan google-services.json ada
ls -la android/app/google-services.json

# Clean dan rebuild
flutter clean
flutter pub get
flutter run
```

### Problem: Backend connection failed

**Solution:**
1. Pastikan backend running: `php artisan serve`
2. Cek IP address yang benar
3. Untuk Android emulator, gunakan `10.0.2.2` bukan `localhost`
4. Untuk device fisik, pastikan di network yang sama

### Problem: Token expired

**Solution:**
Firebase tokens expire setelah 1 jam. App harus refresh token:
```dart
await authService.refreshToken();
```

### Problem: CORS error (Web)

**Solution:**
Update `config/cors.php` di Laravel:
```php
'paths' => ['api/*'],
'allowed_origins' => ['*'],
```

---

## 📞 API Endpoints Summary

### Public Endpoints (No Token Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | Login with Firebase token |
| POST | `/auth/forgot-password` | Send password reset email |
| GET | `/health` | API health check |

### Protected Endpoints (Require Token)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/auth/me` | Get current user |
| POST | `/auth/logout` | Logout user |
| GET | `/profile` | Get user profile |
| PUT | `/profile` | Update profile |
| PUT | `/profile/username` | Update username |
| PUT | `/profile/display-name` | Update display name |
| PUT | `/profile/password` | Update password |
| POST | `/profile/photo` | Upload photo |
| PUT | `/profile/photo-url` | Update photo URL |
| DELETE | `/profile` | Delete account |

---

## 💡 Tips

1. **Development:**
   - Gunakan `flutter run --debug` untuk hot reload
   - Tambahkan print statements untuk debug token
   - Check Firebase Console untuk melihat users yang terdaftar

2. **Testing:**
   - Test register dengan email unik setiap kali
   - Save Firebase token untuk reuse di Postman
   - Use Postman tests untuk automated testing

3. **Production:**
   - Ganti URL backend ke production URL
   - Enable HTTPS
   - Implement token refresh automatically
   - Add proper error handling

---

## ✨ Next Steps

Setelah setup selesai, Anda bisa:

1. ✅ Test login & register di Flutter app
2. ✅ Test semua API endpoints di Postman
3. ✅ Customize UI sesuai kebutuhan
4. ✅ Add profile photo upload dari Flutter
5. ✅ Implement forgot password UI
6. ✅ Add loading states
7. ✅ Add better error messages

---

## 📝 Notes

- Firebase token expires setiap 1 jam, pastikan implement auto-refresh
- Backend menggunakan soft delete untuk user accounts
- Profile photos disimpan di `storage/app/public/profile-photos`
- Semua password minimum 6 karakter
- Email harus valid dan unique

---

**Happy Coding! 🚀**

Jika ada pertanyaan atau masalah, silakan check:
- Firebase Console untuk auth issues
- Laravel logs di `storage/logs/laravel.log`
- Flutter console untuk runtime errors
