# Drilling Activity Tracker

Aplikasi Flutter untuk mencatat aktivitas pengeboran (drilling) secara lokal di
perangkat. Pengguna dapat membuat catatan aktivitas yang berisi tanggal,
Hole ID, pembacaan sensor (accelerometer & gyroscope), foto yang dikompresi,
serta status penyelesaian. Data disimpan di database lokal SQLite dan
dipisahkan menjadi dua tab: **Offline** (draft) dan **Online** (submitted,
diperlakukan seolah-olah berasal dari API).

---

## Versi Flutter yang Digunakan

| Tooling | Versi |
|---------|-------|
| Flutter | 3.44.1 (channel stable) |
| Dart    | 3.12.1 |

Dependency utama (lihat `pubspec.yaml`):

- `sqflite` ^2.4.3 — database lokal SQLite
- `path` ^1.9.1 — join path file database
- `path_provider` ^2.1.5 — lokasi direktori dokumen aplikasi
- `provider` ^6.1.5 — state management (ChangeNotifier)
- `sensors_plus` ^7.0.0 — pembacaan accelerometer & gyroscope
- `image_picker` ^1.2.2 — ambil gambar dari kamera/galeri
- `flutter_image_compress` ^2.4.0 — kompresi gambar
- `intl` ^0.20.2 — format tanggal (`dd MMMM yyyy`)

---

## Arsitektur

Aplikasi menggunakan pola **MVVM (Model – View – ViewModel)** dengan struktur
folder **feature-first**, serta **Provider + ChangeNotifier** untuk manajemen
state.

- **Model** — kelas data (`DrillingActivity`) yang di-map dari/ke SQLite.
- **View** — widget UI (screen & widget) yang hanya menampilkan state dan
  meneruskan action pengguna ke ViewModel. View juga memegang resource UI seperti
  `TextEditingController` dan `GlobalKey<FormState>`.
- **ViewModel** — `ChangeNotifier` berisi state halaman; menangani action yang kemudian
  didelegasikan ke Repository dan Service.
- **Repository & Service** — data layer. `DrillingRepository` mengakses SQLite,
  `ImageService` menangani pick/compress/simpan gambar, dan
  `SensorService` membaca accelerometer/gyroscope.

Aliran data: **View → ViewModel → Repository / Service → DatabaseHelper (SQLite)
atau plugin perangkat**.

---

## Struktur Project

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_dimens.dart      # Nilai untuk spacing, radius, size
│   │   ├── app_routes.dart      # Nama named route ('/', '/drilling-form')
│   │   ├── app_strings.dart     # Semua teks UI (tidak ada string yang hardcoded)
│   │   └── db_constants.dart    # Nama db/tabel/kolom + nilai status
│   └── theme/
│       ├── app_theme.dart       # Material 3 theme (seed slate blue)
│       └── status_colors.dart   # Warna badge status (draft/submitted)
├── data/
│   ├── models/
│   │   └── drilling_activity.dart   # Model + toMap/fromMap/copyWith
│   ├── repositories/
│   │   └── drilling_repository.dart # CRUD SQLite
│   └── services/
│       ├── database_helper.dart     # Koneksi & skema database
│       ├── image_service.dart       # Pick, compress, simpan, hapus gambar
│       └── sensor_service.dart      # Baca accelerometer & gyroscope
├── ui/
│   ├── home/
│   │   ├── viewmodels/
│   │   │   └── home_viewmodel.dart  # State list draft & submitted
│   │   ├── widgets/
│   │   │   ├── activity_card.dart   # Card item drilling activity
│   │   │   ├── empty_state.dart     # Tampilan saat data kosong
│   │   │   └── status_badge.dart    # Badge status
│   │   └── home_screen.dart         # Provider HomeViewModel + TabBar
│   └── drilling_form/
│       ├── viewmodels/
│       │   └── drilling_form_viewmodel.dart  # State form + simpan/submit
│       ├── widgets/
│       │   ├── date_field.dart           # Date picker
│       │   ├── image_picker_field.dart   # Image picker
│       │   ├── sensor_reader_tile.dart   # Live preview & capture sensor x/y/z
│       │   └── status_dropdown.dart      # Dropdown status (complete / not complete)
│       └── drilling_form_screen.dart     # Halaman form drilling
└── main.dart                             # Entry point + Provider + routing
```

### Penjelasan Tiap Folder

- **`core/`** — kode yang tidak terikat ke satu halaman.
  - **`constants/`** — konstanta terpusat: teks UI, dimensi, nama route, dan
    konstanta database. Tidak ada string UI yang ditulis langsung di widget.
  - **`theme/`** — definisi tema Material 3 dan mapping warna status.
- **`data/`** — data layer (tidak tahu apa pun soal UI).
  - **`models/`** — representasi objek data dan serialisasinya.
  - **`repositories/`** — operasi CRUD; satu-satunya pintu ke database bagi
    ViewModel.
  - **`services/`** — `DatabaseHelper` (koneksi & skema SQLite), `ImageService`
    (pick/compress/simpan gambar), dan `SensorService` (baca sensor).
- **`ui/`** — presentation layer, dikelompokkan per fitur.
  - **`home/`** — halaman list aktivitas (tab Offline/Online). `HomeScreen`
    menyediakan `HomeViewModel` (scoped ke halaman ini, bukan global).
  - **`drilling_form/`** — halaman form untuk membuat/mengedit aktivitas; juga
    menyediakan `DrillingFormViewModel` secara scoped.
- **`main.dart`** — menyiapkan `MultiProvider` untuk dependensi yang dipakai
  bersama (`DrillingRepository`, `ImageService`, `SensorService`), tema, dan
  named route, lalu menjalankan aplikasi. ViewModel di-scope di tiap halaman.

---

## Model Data — DrillingActivity

| Field | Tipe | Keterangan |
|-------|------|------------|
| `id` | `int?` | Primary key (auto-increment) |
| `holeId` | `String` | ID lubang bor (alfanumerik) |
| `date` | `DateTime` | Tanggal aktivitas |
| `accelX/Y/Z` | `double?` | Pembacaan accelerometer |
| `gyroX/Y/Z` | `double?` | Pembacaan gyroscope |
| `imagePath` | `String?` | Path file foto lokal yang sudah dikompresi |
| `status` | `String` | Lifecycle: `draft` atau `submitted` |
| `completionStatus` | `String?` | Status penyelesaian: `Complete`/`Not Complete` |
| `createdAt` | `DateTime` | Waktu pembuatan record |

> Catatan: `status` (draft/submitted) memisahkan tab Offline/Online, sedangkan
> `completionStatus` adalah nilai dropdown pada form — keduanya disimpan di
> kolom terpisah.

---

## Alur Aplikasi Saat Dijalankan

1. **Buka aplikasi** → `HomeScreen` tampil dengan dua tab:
   - **Offline** — list aktivitas berstatus `draft` (dari SQLite lokal).
   - **Online** — list aktivitas berstatus `submitted`.
   - Jika kosong, ditampilkan *empty state*. List bisa di-*pull to refresh*.
2. **Tekan tombol + (FAB)** → membuka `DrillingFormScreen` (mode buat baru).
3. **Isi form:**
   - **Date** — pilih tanggal (ditampilkan dalam format `dd MMMM yyyy`).
   - **Hole ID** — wajib diisi (terdapat validasi).
   - **Accelerometer / Gyroscope** — tekan *Read* untuk memulai *live preview*
     (nilai x/y/z diperbarui real-time dalam bentuk 4 desimal), lalu *Capture* untuk
     menangkap nilai yang akan disimpan. Sensor yang tidak tersedia ditangani
     dengan SnackBar.
   - **Take a Picture** — pilih sumber **Camera/Gallery**; gambar dikompresi
     hingga di bawah 250 KB lalu disimpan ke direktori dokumen aplikasi. Ukuran
     file ditampilkan (sebelum → sesudah saat dikompresi).
   - **Status** — dropdown `Complete` / `Not Complete`.
4. **Simpan:**
   - **Save as Draft** (ikon di AppBar kanan atas) → simpan dengan
     status `draft`.
   - **Submit** (tombol di bawah) → simpan dengan status `submitted`.
   - Validasi: **Hole ID** dan **Date** wajib diisi sebelum menyimpan.
   - Setelah berhasil, halaman kembali ke Home, list di-refresh, dan muncul
     **SnackBar** feedback (sukses/gagal).
5. **Kelola item:** Tekan card untuk **mengedit**, atau gunakan menu pada
   card untuk **menghapus** (dengan dialog konfirmasi).

---

## Cara Menjalankan Project

Prasyarat: Flutter 3.44.1 (stable) sudah terpasang dan perangkat/emulator aktif.

```bash
# 1. Ambil dependency
flutter pub get

# 2. (Opsional) periksa perangkat yang tersedia
flutter devices

# 3. Jalankan aplikasi
flutter run

# 4. (Opsional) static analysis — harus bersih tanpa warning
flutter analyze
```

Build rilis (opsional):

```bash
flutter build apk      # Android
flutter build ios      # iOS (perlu macOS + Xcode)
```

---

## Catatan Tambahan

- **Kompresi gambar** menargetkan hasil mendekati 250 KB (kisaran ~225–275 KB).
  Gambar yang sudah di bawah 250 KB tidak dikompresi ulang (cukup disalin) agar
  tidak malah membesar. Untuk gambar besar, kualitas JPEG dicari dengan
  *binary search* (kualitas tertinggi yang masih muat), lalu resolusi diturunkan
  bila perlu. File disimpan di direktori dokumen aplikasi; file lama dibersihkan
  saat diganti/dihapus (hanya file milik aplikasi).
- **Sensor** menggunakan *live preview + capture*: menekan *Read* memeriksa
  ketersediaan sensor (mengambil satu sampel uji dengan *timeout* 2 detik), lalu
  *stream* nilai secara real-time ke UI; *Capture* membatalkan subscription
  sehingga nilai terakhir di-capture. `StreamSubscription` dibatalkan di
  `dispose()` ViewModel untuk mencegah memory leak. Sensor yang tidak tersedia ditangani dengan SnackBar.
- **Izin (permissions):** mengikuti dokumentasi resmi plugin.
  - *Android* — `image_picker` tidak memerlukan izin manifest karena memakai
    intent sistem + scoped storage; izin `CAMERA` sengaja tidak dideklarasikan
    agar pengambilan foto tidak crash.
  - *iOS* — `Info.plist` memuat `NSCameraUsageDescription`,
    `NSPhotoLibraryUsageDescription`, dan `NSMotionUsageDescription`.
- **Tidak ada string UI yang hardcoded**; semua label berada di
  `core/constants/app_strings.dart`.
- Proyek passed `flutter analyze` tanpa warning.
