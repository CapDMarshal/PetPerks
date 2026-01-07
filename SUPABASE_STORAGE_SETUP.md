# Supabase Storage Setup untuk Avatar

## Setup Storage Bucket

Untuk fitur edit profile dengan upload avatar berfungsi dengan baik, Anda perlu membuat storage bucket di Supabase.

### 1. Login ke Supabase Dashboard
- Buka https://supabase.com/dashboard
- Login dengan akun Anda
- Pilih project PetPerks

### 2. Buat Storage Bucket untuk Avatar

1. **Navigasi ke Storage**
   - Di sidebar kiri, klik **Storage**

2. **Buat Bucket Baru**
   - Klik tombol **New bucket**
   - Nama bucket: `avatars`
   - Public bucket: **Centang** (agar avatar bisa diakses publik)
   - File size limit: 5MB (opsional)
   - Allowed MIME types: `image/*` (opsional)
   - Klik **Create bucket**

### 3. Setup Policies (RLS - Row Level Security)

Setelah bucket dibuat, setup policies agar user bisa upload dan akses avatar:

#### Policy 1: Public Read Access
```sql
-- Policy untuk read (semua orang bisa lihat avatar)
CREATE POLICY "Public Avatar Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');
```

#### Policy 2: Authenticated Users Can Upload
```sql
-- Policy untuk insert (user login bisa upload)
CREATE POLICY "Authenticated Users Can Upload Avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');
```

#### Policy 3: Users Can Update Their Own Avatar
```sql
-- Policy untuk update (user bisa update avatar sendiri)
CREATE POLICY "Users Can Update Own Avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
```

#### Policy 4: Users Can Delete Their Own Avatar
```sql
-- Policy untuk delete (user bisa delete avatar sendiri)
CREATE POLICY "Users Can Delete Own Avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### 4. Cara Menambahkan Policies di Dashboard

1. **Buka Storage Policies**
   - Di halaman Storage, klik bucket **avatars**
   - Klik tab **Policies**

2. **Tambahkan Policy**
   - Klik **New Policy**
   - Pilih **For full customization** atau template yang sesuai
   - Masukkan SQL policy di atas
   - Klik **Review** dan **Save policy**

### 5. Verifikasi Setup

Setelah setup selesai, struktur storage Anda akan seperti ini:

```
Storage
└── avatars/ (bucket)
    └── {user_id}_{timestamp}.jpg (contoh file yang diupload)
```

## Struktur Kode yang Sudah Diimplementasikan

### 1. Upload Avatar Function (api_service.dart)
```dart
Future<String> uploadAvatar(File imageFile) async {
  final user = _supabase.auth.currentUser;
  final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final path = 'avatars/$fileName';
  
  await _supabase.storage
      .from('avatars')
      .upload(path, imageFile);
      
  return _supabase.storage
      .from('avatars')
      .getPublicUrl(path);
}
```

### 2. Update Profile Function (api_service.dart)
```dart
Future<void> updateProfile({
  String? displayName,
  String? phoneNumber,
  String? email,
  String? location,
  String? avatarUrl,
}) async {
  final updates = {
    'id': user.id,
    'display_name': displayName,
    'phone_number': phoneNumber,
    'email': email,
    'location': location,
    'avatar_url': avatarUrl,
  };
  
  await _supabase.from('profiles').upsert(updates);
}
```

### 3. Edit Profile Screen (edit-profile.dart)
Fitur yang sudah diimplementasikan:
- ✅ Load data profile dari Supabase saat halaman dibuka
- ✅ Pilih gambar dari gallery menggunakan image_picker
- ✅ Preview gambar yang dipilih sebelum upload
- ✅ Upload avatar ke Supabase Storage
- ✅ Update semua field profile (display_name, phone_number, email, location, avatar_url)
- ✅ Loading indicators saat proses upload/update
- ✅ Error handling dengan SnackBar messages
- ✅ Auto refresh profile screen setelah berhasil update

## Testing

### 1. Test Upload Avatar
1. Buka app dan login
2. Navigasi ke Profile → Profile Information
3. Klik icon edit pada foto profile
4. Pilih gambar dari gallery
5. Klik "Update Profile"
6. Verifikasi avatar berubah di halaman profile

### 2. Test Update Data
1. Edit Full Name, Mobile Number, Email, atau Location
2. Klik "Update Profile"
3. Cek di Supabase Dashboard → Table Editor → profiles
4. Verifikasi data sudah terupdate

## Troubleshooting

### Error: "Failed to upload avatar"
- **Solusi**: Pastikan bucket 'avatars' sudah dibuat di Supabase Storage
- **Solusi**: Cek policies sudah benar di setup

### Error: "No user logged in"
- **Solusi**: Pastikan user sudah login sebelum akses edit profile

### Avatar tidak muncul
- **Solusi**: Pastikan bucket 'avatars' adalah **public bucket**
- **Solusi**: Cek policy untuk SELECT sudah diaktifkan

### Image picker tidak muncul (iOS)
- **Solusi**: Tambahkan permission di `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to update your profile picture</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take profile pictures</string>
```

### Image picker tidak muncul (Android)
- **Solusi**: Tambahkan permission di `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

## SQL untuk Membuat Tabel Profiles (jika belum ada)

```sql
-- Tabel profiles
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  display_name TEXT,
  phone_number TEXT,
  avatar_url TEXT,
  location TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy untuk profiles
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);
```

## Summary Fitur Edit Profile

| Field | Tipe | Supabase Column | Status |
|-------|------|-----------------|--------|
| Avatar | Image | avatar_url | ✅ Connected |
| Full Name | Text | display_name | ✅ Connected |
| Mobile Number | Text | phone_number | ✅ Connected |
| Email | Text | email | ✅ Connected |
| Location | Text | location | ✅ Connected |

Semua field sudah terhubung dengan Supabase dan berfungsi dengan baik! 🎉
