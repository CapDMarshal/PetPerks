# Firebase Setup Instructions for PetPerks

## Langkah-langkah Setup Firebase

### 1. Buat Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add project" atau "Create a project"
3. Masukkan nama project: **PetPerks** (atau nama lain sesuai keinginan)
4. (Optional) Enable Google Analytics jika diperlukan
5. Klik "Create project"

### 2. Enable Email/Password Authentication

1. Di Firebase Console, pilih project yang baru dibuat
2. Klik **Authentication** di menu sidebar kiri
3. Klik tab **Sign-in method**
4. Klik **Email/Password**
5. Enable toggle untuk **Email/Password**
6. Klik **Save**

### 3. Register Android App

1. Di Firebase Console, klik icon **Android** (atau gear icon → Project settings → Add app)
2. Masukkan informasi berikut:
   - **Android package name**: `com.example.petperks`
   - **App nickname** (optional): PetPerks
   - **Debug signing certificate SHA-1** (optional untuk development)
3. Klik **Register app**
4. **Download google-services.json**
5. Letakkan file `google-services.json` di folder:
   ```
   PetPerks/android/app/google-services.json
   ```

### 4. Verify google-services.json Location

Pastikan struktur folder seperti ini:
```
PetPerks/
├── android/
│   ├── app/
│   │   ├── google-services.json  ← File ini HARUS ada di sini!
│   │   ├── build.gradle
│   │   └── src/
│   ├── build.gradle
│   └── settings.gradle
```

### 5. Download Firebase Service Account untuk Backend

1. Di Firebase Console, klik **gear icon** → **Project settings**
2. Pilih tab **Service accounts**
3. Klik **Generate new private key**
4. Klik **Generate key** pada dialog konfirmasi
5. File JSON akan terdownload
6. Rename file menjadi `firebase-credentials.json`
7. Letakkan di folder backend:
   ```
   petperks-be/storage/app/firebase-credentials.json
   ```

### 6. Update Backend .env File

Edit file `petperks-be/.env` dan update:

```env
FIREBASE_CREDENTIALS=storage/app/firebase-credentials.json
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_DATABASE_URL=https://your-project-id.firebaseio.com
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
```

**Cara mendapatkan Project ID:**
1. Firebase Console → Project settings → General
2. Copy **Project ID**
3. Paste di `.env` file

### 7. (Optional) Setup untuk iOS

Jika ingin run di iOS:

1. Di Firebase Console, klik icon **iOS**
2. Masukkan **iOS bundle ID** dari `ios/Runner/Info.plist`
3. Download `GoogleService-Info.plist`
4. Buka Xcode: `open ios/Runner.xcworkspace`
5. Drag & drop `GoogleService-Info.plist` ke Runner folder di Xcode
6. Pastikan "Copy items if needed" di-check
7. Klik Finish

### 8. Verify Setup

Jalankan command berikut untuk verify:

```bash
# Check google-services.json exists
ls -la android/app/google-services.json

# Check backend firebase credentials
ls -la ../petperks-be/storage/app/firebase-credentials.json
```

### 9. Test Firebase Connection

Jalankan Flutter app:

```bash
flutter clean
flutter pub get
flutter run
```

Jika setup benar, app akan jalan tanpa error Firebase.

### 10. Verify di Firebase Console

Setelah register/login pertama kali:

1. Buka Firebase Console
2. Klik **Authentication**
3. Tab **Users**
4. User baru akan muncul di list

---

## Troubleshooting

### Error: "google-services.json not found"

**Solution:**
```bash
# Pastikan file ada di lokasi yang benar
ls -la PetPerks/android/app/google-services.json

# Jika tidak ada, download lagi dari Firebase Console
```

### Error: "Firebase project not found"

**Solution:**
1. Pastikan package name di `android/app/build.gradle` sama dengan yang di Firebase
2. Check `applicationId "com.example.petperks"`

### Error: "Invalid Firebase credentials"

**Solution:**
1. Download ulang `firebase-credentials.json` dari Firebase Console
2. Pastikan file tidak corrupt
3. Check permissions: `chmod 644 storage/app/firebase-credentials.json`

### Error: "Token verification failed"

**Solution:**
1. Pastikan Project ID sama di Flutter dan Backend
2. Re-download service account key
3. Restart backend server: `php artisan serve`

---

## Security Notes

⚠️ **PENTING:**

1. **Jangan commit firebase files ke Git!**
   ```bash
   # Add to .gitignore
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ../petperks-be/storage/app/firebase-credentials.json
   ```

2. **Secure your API keys:**
   - Use Firebase App Check untuk production
   - Enable only necessary services
   - Set up Firebase Security Rules

3. **Backend credentials:**
   - Keep `firebase-credentials.json` private
   - Never expose in public repositories
   - Use environment variables untuk production

---

## Firebase Console URLs

- **Console:** https://console.firebase.google.com/
- **Auth Users:** https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication/users
- **Project Settings:** https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings/general

Replace `YOUR_PROJECT_ID` dengan Project ID Anda.

---

**Setup Complete! 🎉**

Setelah setup Firebase selesai, Anda bisa:
1. ✅ Test register user baru
2. ✅ Test login
3. ✅ Verify user di Firebase Console
4. ✅ Test API dengan Postman

Lihat file `SETUP_LOGIN_REGISTER.md` untuk instruksi lengkap testing.
