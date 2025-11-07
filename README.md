<!--
	Struktur laporan ini disusun ulang agar menyerupai format laporan akademik (seperti referensi PDF yang Anda kirim):
	Cover → Abstrak → Daftar Isi → Bab 1 s.d. 7 → Daftar Pustaka → Lampiran.
-->

# PetPerks — Laporan Pengembangan Aplikasi Flutter


Nama Aplikasi: PetPerks  
Tanggal: 7 November 2025  
Penulis: (isi nama Anda)  
Mata Kuliah/Proyek: (opsional, isi sesuai kebutuhan)

—

## Abstrak

Laporan ini mendokumentasikan proses pengembangan aplikasi Flutter “PetPerks” mulai dari inisialisasi proyek, perancangan arsitektur, implementasi fitur utama (Home, Wishlist, Cart, Category, Profile), hingga pengujian dan hasil. Pendekatan arsitektur menggunakan komponen `MainLayout` dengan `IndexedStack` untuk mempertahankan state lintas tab, serta navigasi berbasis `Navigator`. Hasil akhir adalah aplikasi prototipe fungsional yang siap dijalankan di beberapa platform (Android, iOS, Web, Desktop) dengan struktur kode modular dan mudah dikembangkan.

—

## Daftar Isi

1. [Pendahuluan](#bab-1-pendahuluan)  
2. [Analisis dan Kebutuhan Sistem](#bab-2-analisis-dan-kebutuhan-sistem)  
3. [Perancangan Sistem](#bab-3-perancangan-sistem)  
4. [Implementasi](#bab-4-implementasi)  
5. [Pengujian dan Hasil](#bab-5-pengujian-dan-hasil)  
6. [Pembahasan](#bab-6-pembahasan)  
7. [Screenshot Aplikasi](#bab-7-screenshot-aplikasi)  
8. [Kesimpulan dan Saran](#bab-8-kesimpulan-dan-saran)  
9. [Daftar Pustaka](#daftar-pustaka)  
10. [Lampiran](#lampiran)

—

## Bab 1. Pendahuluan

### 1.1 Latar Belakang
Pengembangan aplikasi e-commerce/produk hewan peliharaan membutuhkan antarmuka yang intuitif, alur navigasi yang efisien, serta struktur kode yang terorganisir. Flutter dipilih karena produktivitas tinggi dan dukungan multi-platform.

### 1.2 Tujuan
- Menyusun aplikasi prototipe “PetPerks”.
- Menerapkan navigasi tab yang mempertahankan state.
- Menyediakan komponen UI reusable dan mudah dikembangkan.

### 1.3 Ruang Lingkup
- Fokus pada UI/UX, navigasi, dan alur dasar e-commerce (browse → wishlist/cart → checkout).  
- Integrasi backend dan pembayaran nyata berada di luar cakupan.

—

## Bab 2. Analisis dan Kebutuhan Sistem

### 2.1 Prasyarat Perangkat Lunak
- Flutter SDK terpasang (`flutter doctor` hijau)  
- VS Code/Android Studio, Android SDK/iOS toolchain  
- Perangkat fisik/emulator/simulator

### 2.2 Dependensi Utama (pubspec.yaml)
- `carousel_slider: ^5.0.0` (banner)  
- `flutter_feather_icons: ^2.0.0` (opsional ikon)  
- (Opsional) `provider: ^6.0.0` untuk state global

### 2.3 Kebutuhan Non-Fungsional
- Performa UI halus di device menengah  
- Struktur kode modular, mudah diuji dan dikembangkan  
- Fallback aman untuk aset yang tidak tersedia (`errorBuilder`)

—

## Bab 3. Perancangan Sistem

### 3.1 Arsitektur Aplikasi (ringkas)
`MainLayout` (Stateful) + `BottomNavigationBar` + `IndexedStack` guna menjaga state setiap tab (Home, Wishlist, Cart, Category, Profile). Masing-masing screen mengelola state lokalnya.


### 3.2 Struktur Folder (lib/)
```
lib/
├── main.dart
├── layout/ (MainLayout, state opsional)
├── dashboard/ (Home, listing)
├── wishlist/
├── cart/
├── category/
├── products/
└── profile/
```


### 3.3 Alur Navigasi Inti
```
BottomNav.onTap(index)
 → setState(() => _selectedIndex = index)
	 → IndexedStack menampilkan screen pada index
		 → State screen lain tetap tersimpan
```

—

## Bab 4. Implementasi

### 4.1 Inisialisasi Proyek
```powershell
flutter create PetPerks
cd PetPerks
flutter pub get
```

### 4.2 Entry Point & Tema (`lib/main.dart`)
```dart
void main() => runApp(const PetPerksApp());

class PetPerksApp extends StatelessWidget {
	const PetPerksApp({super.key});
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'PetPerks',
			theme: ThemeData(primarySwatch: Colors.blue),
			home: const MainLayout(),
			debugShowCheckedModeBanner: false,
		);
	}
}
```


### 4.3 Layout & Navigasi (`lib/layout/main_layout.dart`)
```dart
class _MainLayoutState extends State<MainLayout> {
	int _selectedIndex = 0;
	final _screens = [
		const HomePageContent(),
		const WishlistScreen(),
		const CartScreen(),
		const CategoryScreen(),
		const ProfileScreen(),
	];
	Widget build(BuildContext c) => Scaffold(
		body: IndexedStack(index: _selectedIndex, children: _screens),
		bottomNavigationBar: BottomNavigationBar(
			currentIndex: _selectedIndex,
			onTap: (i) => setState(() => _selectedIndex = i),
			type: BottomNavigationBarType.fixed,
			items: const [
				BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
				BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
				BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
				BottomNavigationBarItem(icon: Icon(Icons.document_scanner_outlined), label: 'Docs'),
				BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
			],
		),
	);
}
```


### 4.4 Home & Banner (`lib/dashboard/home_page.dart`)
```dart
Widget _buildBanner() => CarouselSlider(
	options: CarouselOptions(autoPlay: true, aspectRatio: 2.0, viewportFraction: 1.0),
	items: [ _buildBannerItem('assets/images/banner/pic1.png', 'We Give Preference To Your Pets') ],
);

// Contoh navigasi
Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListPage()));
```


### 4.5 Wishlist (`lib/wishlist/wishlist_screen.dart`)
```dart
class ProductCard extends StatelessWidget {
	final Product product; // name, imageUrl, price, oldPrice
	@override
	Widget build(BuildContext context) {
		return Card(
			child: Column(children: [
				Expanded(child: Image.asset(product.imageUrl, fit: BoxFit.contain)),
				Text(product.name),
				Row(children: [Text('\$${product.price}'), Text('\$${product.oldPrice}', style: const TextStyle(decoration: TextDecoration.lineThrough))]),
				IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () => _navigateToCartScreen(context)),
			]),
		);
	}
}
```


### 4.6 Cart & Checkout (`lib/cart/cart_screen.dart`)
```dart
class _CartItemCardState extends State<CartItemCard> {
	int _quantity = 1;
	void _incrementQuantity() => setState(() => _quantity++);
	void _decrementQuantity() { if (_quantity > 1) setState(() => _quantity--); }
}
```


### 4.7 State Global (Opsional) (`lib/layout/navigation_state.dart`)
```dart
class NavigationState extends ChangeNotifier {
	int _cartItemCount = 14; List<String> _wishlist = [];
	int get cartItemCount => _cartItemCount; int get wishlistItemCount => _wishlist.length;
	void updateCartCount(int c) { _cartItemCount = c; notifyListeners(); }
	void addToWishlist(String id) { if (!_wishlist.contains(id)) { _wishlist.add(id); notifyListeners(); } }
}
```
Aktivasi (opsional): bungkus `MainLayout` dengan `ChangeNotifierProvider` (paket `provider`).

—

## Bab 5. Pengujian dan Hasil

### 5.1 Menjalankan Aplikasi
```powershell
flutter pub get
flutter devices
flutter run
```
Variasi platform:
```powershell
flutter run -d windows
flutter run -d chrome
flutter run -d emulator
```


### 5.2 Hasil Uji (contoh)
Metodologi singkat:
- Perangkat uji: Windows 11, Flutter SDK sesuai `pubspec` (Dart ^3.9.2), emulator Android & target Windows desktop.
- Data dummy, tanpa backend. Fokus pada alur UI dan navigasi.

Skenario uji utama dan hasil ringkas:
- Navigasi bawah (Home ⇄ Wishlist ⇄ Cart ⇄ Category ⇄ Profile)
	- Expected: Perpindahan tab lancar, posisi scroll tiap tab tetap (IndexedStack).
	- Result: PASS — State tab terjaga, tidak terjadi rebuild berlebih.
- Home (Banner & Grid)
	- Expected: Banner autoplay, item grid tampil, tombol CTA menuju list produk/detail.
	- Result: PASS — Banner berjalan dan fallback `errorBuilder` bekerja jika aset tidak ada.
- Wishlist (Grid + Hapus item + Arahkan ke Cart/Detail)
	- Expected: Dapat menghapus item, dapat menuju detail/cart.
	- Result: PASS — Interaksi berjalan, snackbar konfirmasi tampil.
- Cart (Kuantitas + Subtotal + Checkout)
	- Expected: Tombol +/- mengubah kuantitas, subtotal tampil, lanjut ke checkout.
	- Result: PASS — Kuantitas berubah, tombol lanjut aktif.
- Drawer & AppBar actions
	- Expected: Drawer terbuka, tombol notifikasi/search navigasi sesuai.
	- Result: PASS — Navigasi sesuai, fallback ikon aman saat aset tidak tersedia.

Catatan performa:
- Waktu render awal stabil pada perangkat uji; tidak ditemukan jank pada perpindahan tab.
- Penggunaan `IndexedStack` menjaga UX namun menahan widget di memori (trade-off yang diterima pada skala prototipe).

—

## Bab 6. Pembahasan

### 6.1 Keputusan Desain
- `IndexedStack` dipilih untuk menjaga state tiap tab (trade-off: memory lebih besar vs UX lebih baik).
- Navigasi imperatif sederhana (`Navigator`) agar fokus prototipe cepat.

### 6.2 Analisis Arsitektur & Trade-off
- IndexedStack vs Navigator push/pop per tab: IndexedStack menjaga state scroll & form, menghemat waktu interaksi; konsekuensinya konsumsi memori tiap tab aktif.
- Komposisi screen modular memudahkan maintenance, namun memerlukan disiplin pemisahan widget dan pengelolaan state agar tidak terjadi prop-drilling berlebih.

### 6.3 Kinerja
- Tidak terlihat jank pada animasi ringan dan perpindahan tab di perangkat uji.
- Asset yang tidak tersedia ditangani `errorBuilder` sehingga menghindari crash dan menjaga stabilitas rendering.

### 6.4 Risiko dan Mitigasi
- Path aset yang tidak konsisten → mitigasi dengan fallback `errorBuilder` dan daftar aset yang jelas di `pubspec.yaml`.
- Skala data meningkat → pertimbangkan pagination/lazy loading dan memoization pada builder.
- Manajemen state lintas fitur → aktifkan `provider`/state management terpusat bila kebutuhan data lintas halaman meningkat.

### 6.5 Peluang Pengembangan Lanjutan
- Integrasi backend (produk, auth, orders), caching lokal, dan sinkronisasi keranjang/wishlist.
- Theming dinamis (dark mode global) dan global state untuk badge cart/wishlist.
- Test otomatis (widget/integration) untuk alur kritikal checkout dan navigasi.

### 6.6 Perbandingan Alternatif Navigasi
- Navigator 2.0/Router/GoRouter: Memudahkan deep-linking, URL sync (web), dan guard rute. Lebih kompleks dibanding Navigator 1.0, cocok saat kebutuhan routing makin kaya.
- BottomNavigationBar + Navigator stack per tab: Tiap tab punya stack sendiri; kembali (back) hanya di dalam tab aktif. Cocok untuk aplikasi dengan alur dalam per tab.
- TabBar/TabBarView: Cocok untuk jumlah tab sedikit dan swipe gesture, namun kurang fleksibel untuk alur kompleks dibanding bottom nav + IndexedStack.

### 6.7 Keamanan & Privasi (Rencana)
- Sanitasi input dan validasi form sebelum transaksi/checkout.
- Penyimpanan token/credential aman (Secure Storage) jika autentikasi ditambahkan.
- Minimalkan data pribadi di log; terapkan kebijakan privasi bila integrasi backend aktif.

### 6.8 Aksesibilitas & Internasionalisasi
- Kontras warna dan ukuran font mengikuti guideline Material untuk keterbacaan.
- Label semantik (Semantics) pada ikon penting seperti cart/wishlist untuk screen reader.
- Rencana i18n: menggunakan `flutter_localizations` dan ARB untuk multi-bahasa.

### 6.9 Skalabilitas & Modularisasi
- Pemecahan fitur per domain (`dashboard/`, `wishlist/`, `cart/`, dst.) memudahkan kepemilikan modul dan pengujian parsial.
- Abstraksi lapisan data (repository/service) direkomendasikan saat menambah backend agar UI tidak bergantung langsung pada sumber data.
- Pertimbangkan DI (get_it) untuk menyuntikkan dependency dan memudahkan mocking saat tes.

### 6.10 Observabilitas & Reliabilitas
- Logging terstruktur (logger) untuk event penting: navigasi, aksi cart, dan error UI.
- Error boundary sederhana di layer UI: tampilkan snackbar/toast atau halaman error bila terjadi kegagalan data.
- Monitoring crash (mis. Sentry/Firebase Crashlytics) saat rilis produksi.

—

## Bab 7. Screenshot Aplikasi

Bagian ini menampilkan placeholder screenshot untuk halaman-halaman utama aplikasi. Silakan masukkan file gambar aktual Anda ke dalam folder `docs/screenshots/` (atau lokasi lain yang Anda tentukan) dan ganti placeholder di bawah ini.

### 7.1 Dashboard
Screenshot tampilan Dashboard:

```
(Sisipkan gambar: docs/screenshots/dashboard.png)
```

Deskripsi singkat: Halaman ini menampilkan banner promosi, kategori, produk rekomendasi, testimonial, dan berbagai section konten lain yang menjadi entry point interaksi pengguna.

### 7.2 Category
Screenshot tampilan Category:

```
(Sisipkan gambar: docs/screenshots/category.png)
```

Deskripsi singkat: Halaman kategori menampilkan daftar kategori atau produk terfilter, mempermudah pengguna menelusuri item berdasarkan klasifikasi tertentu.

### 7.3 Wishlist
```
(Sisipkan gambar: docs/screenshots/wishlist.png)
```
Menampilkan item yang disimpan pengguna untuk dilihat atau dibeli nanti; mendukung penghapusan item dan akses cepat ke detail produk.

### 7.4 Cart
```
(Sisipkan gambar: docs/screenshots/cart.png)
```
Menampilkan ringkasan produk yang akan dibeli, kuantitas yang dapat disesuaikan, subtotal, dan tombol lanjut ke checkout.

### 7.5 Product Detail
```
(Sisipkan gambar: docs/screenshots/product-detail.png)
```
Berisi gambar produk, harga lama & baru, rating, pilihan ukuran/warna, kuantitas, dan tombol tambah ke keranjang.

### 7.6 Profile
```
(Sisipkan gambar: docs/screenshots/profile.png)
```
Halaman profil berisi informasi akun, akses ke order, wallet, kupon, pengaturan notifikasi, dan opsi personalisasi lainnya.

---

## Bab 8. Kesimpulan dan Saran

Prototipe PetPerks berhasil diwujudkan dengan arsitektur modular dan navigasi yang menjaga state. Ke depan, disarankan integrasi API backend, autentikasi pengguna, manajemen state global yang konsisten, dan cakupan pengujian otomatis lebih luas.

—

## Daftar Pustaka

- Flutter Documentation: https://docs.flutter.dev/
- carousel_slider: https://pub.dev/packages/carousel_slider
- provider (opsional): https://pub.dev/packages/provider

—

## Lampiran

### A. Konfigurasi `pubspec.yaml` (ringkasan)
```yaml
environment:
	sdk: ^3.9.2
dependencies:
	flutter:
		sdk: flutter
	carousel_slider: ^5.0.0
	flutter_feather_icons: ^2.0.0
flutter:
	uses-material-design: true
	assets:
		- assets/
```

### B. Troubleshooting Umum
Jika `flutter run` gagal (Exit Code: 1):
```powershell
flutter pub get
flutter clean
flutter pub get
flutter doctor -v
flutter run
```
Periksa juga path asset di kode; widget telah dilengkapi `errorBuilder` sebagai fallback.


—

Dokumen ini disusun ulang agar mengikuti struktur laporan formal. Jika Anda ingin saya memasukkan logo kampus/instansi dan data penulis ke halaman sampul, kirimkan detailnya—saya akan lengkapi.
