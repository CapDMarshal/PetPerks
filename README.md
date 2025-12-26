# PetPerks 🐾

E-commerce mobile application untuk produk hewan peliharaan, dibuat dengan **Flutter** dan **Supabase**.

## 📱 Features

- ✅ **Authentication** - Email/password login & registration
- ✅ **Product Catalog** - Browse products dengan filtering by category
- ✅ **Shopping Cart** - Manage items untuk checkout
- ✅ **Wishlist** - Save produk favorit
- ✅ **Product Management** - CRUD operations (authenticated users)
- ✅ **Profile Management** - Update user information
- ✅ **Image Upload** - Upload gambar produk ke Supabase Storage
- ✅ **Row Level Security** - Secure data with Supabase RLS

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.9.2+
- **Backend**: Supabase (BaaS)
- **Database**: PostgreSQL via Supabase
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **State Management**: Provider

## 📋 Prerequisites

- Flutter SDK (^3.9.2)
- Dart SDK
- Android Studio / VS Code
- Supabase Account (free tier)

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone <repository-url>
cd PetPerks
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Supabase

#### A. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Wait for setup to complete (~2 minutes)

#### B. Get Credentials

1. In Supabase Dashboard, go to **Settings** → **API**
2. Copy:
   - **Project URL**: `https://[your-project].supabase.co`
   - **anon public** key: `eyJhbG...`

#### C. Configure Flutter App

Create/edit `lib/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

⚠️ **Important**: Add this file to `.gitignore` if sharing code publicly!

#### D. Setup Database

1. In Supabase Dashboard, open **SQL Editor**
2. Run the following SQL scripts in order:

**Create Tables:**

```sql
-- 1. Profiles
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE,
  display_name TEXT,
  phone_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Products
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10, 2) NOT NULL,
  old_price NUMERIC(10, 2),
  image_url TEXT,
  category TEXT,
  description TEXT,
  reviews_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Cart Items
CREATE TABLE cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products ON DELETE CASCADE NOT NULL,
  quantity INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- 4. Wishlist Items
CREATE TABLE wishlist_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- 5. Orders
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  total NUMERIC(10, 2) NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Order Items
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products ON DELETE CASCADE NOT NULL,
  quantity INTEGER NOT NULL,
  price NUMERIC(10, 2) NOT NULL
);

-- 7. Auto-create profile trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'display_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

**Setup Row Level Security (RLS):**

```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist_items ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Products policies
CREATE POLICY "Anyone can view products" ON products FOR SELECT USING (true);
CREATE POLICY "Authenticated can insert" ON products FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated can update" ON products FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Authenticated can delete" ON products FOR DELETE TO authenticated USING (true);

-- Cart policies
CREATE POLICY "Users can manage own cart" ON cart_items FOR ALL USING (auth.uid() = user_id);

-- Wishlist policies
CREATE POLICY "Users can manage own wishlist" ON wishlist_items FOR ALL USING (auth.uid() = user_id);
```

**Sample Data (Optional):**

```sql
INSERT INTO products (name, price, old_price, image_url, category, description) VALUES
('Dog Body Belt', 80, 95, 'assets/belt_product.jpg', 'Accessories', 'Durable and comfortable body belt for dogs.'),
('Dog Cloths', 80, 95, 'assets/cloths_product.jpg', 'Clothing', 'Stylish and warm clothes for your pet.'),
('Pet Bed For Dog', 80, 95, 'assets/bed_product.jpg', 'Bedding', 'Soft and cozy bed.'),
('Dog Chew Toys', 80, 95, 'assets/chew_toys_product.jpg', 'Toys', 'Safe and durable toys.');
```

#### E. Setup Storage Bucket

1. In Supabase Dashboard, go to **Storage**
2. Create new bucket: `product-images`
3. Set as **Public bucket**
4. Add storage policies:

```sql
-- Public read
CREATE POLICY "Public can view" ON storage.objects
  FOR SELECT USING (bucket_id = 'product-images');

-- Authenticated upload
CREATE POLICY "Authenticated can upload" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'product-images');
```

#### F. Setup Authentication

1. Go to **Authentication** → **Providers**
2. Enable **Email** provider
3. (Optional) Disable email confirmation untuk development

### 4. Run Application

#### Debug Mode

```bash
flutter run
```

#### Release APK

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## 📂 Project Structure

```
lib/
├── main.dart                      # Entry point & Supabase init
├── supabase_config.dart           # Supabase credentials (gitignored)
├── auth/
│   ├── login_page.dart
│   └── register_page.dart
├── services/
│   ├── auth_service.dart          # Authentication logic
│   └── api_service.dart           # Data fetching (DataService)
├── layout/
│   └── main_layout.dart           # Bottom navigation
├── dashboard/
│   └── home_page.dart
├── products/
│   ├── product_list_page.dart
│   ├── product_detail_page.dart
│   └── add_edit_product_page.dart
├── cart/
│   └── cart_screen.dart
├── wishlist/
│   └── wishlist_screen.dart
└── profile/
    └── profile_screen.dart
```

## 🔧 Configuration

### Environment Variables

Copy `lib/supabase_config.dart.template` to `lib/supabase_config.dart` and fill in your credentials.

### .gitignore

Make sure to add:
```
lib/supabase_config.dart
```

## 🐛 Troubleshooting

### Build Failed: google-services.json missing

**Error:**
```
File google-services.json is missing
```

**Fix:**
Remove Firebase plugin from `android/app/build.gradle.kts`:

```kotlin
// Remove these lines:
// id("com.google.gms.google-services")
```

### RLS Permission Denied

**Error:**
```
new row violates row-level security policy
```

**Fix:**
- Ensure user is logged in
- Verify RLS policies are created correctly
- Check policy logic matches your operation

### Supabase Connection Error

**Error:**
```
Supabase initialization error
```

**Fix:**
- Verify `supabaseUrl` and `supabaseAnonKey` are correct
- Check no extra spaces or newlines
- Ensure project is not paused in Supabase dashboard

## 📝 Development Notes

### Authentication Flow

1. User registers → Supabase Auth creates user → Database trigger creates profile
2. User logs in → JWT token stored automatically
3. All requests include JWT → RLS filters data by user

### Data Fetching

Use `DataService` from `lib/services/api_service.dart`:

```dart
final dataService = DataService();

// Get products
final products = await dataService.getProducts();

// Get user's cart
final cartItems = await dataService.getCartItems();

// Add to cart
await dataService.addToCart(productId, quantity: 2);
```

### RLS Security

- Cart & wishlist automatically filtered by logged-in user
- Products readable by all, writable by authenticated users
- No manual user_id filtering needed in code

## 📖 Documentation

For detailed documentation, see:
- **Laporan Lengkap**: `PetPerks_Laporan.docx`
- **SQL Scripts**: `rls_fix.sql`, `seed_data.sql`

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is for educational purposes.

## 🙋 Support

For issues or questions:
- Check troubleshooting section above
- Review Supabase documentation: https://supabase.com/docs
- Check Flutter docs: https://docs.flutter.dev

---

**Happy coding! 🚀**
