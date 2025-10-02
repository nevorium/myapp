# Todo List: Konco Ngaji

## Fase 1: Core Functionality & UI Setup

### User Authentication
- [x] Implementasi Firebase Authentication (Email/Password)
- [x] Halaman Login
- [ ] Halaman Reset Password
- [x] Halaman Registrasi
- [x] Auth Wrapper (redirect user jika sudah/belum login)

### Halaman Utama & Navigasi
- [x] Struktur dasar Dashboard Screen
- [ ] Implementasi UI Dashboard (menampilkan ringkasan progres)
- [ ] Implementasi Bottom Navbar (Dashboard, Analysis, Leaderboard, AI)

### Pelacakan (Tracking)
- [ ] **Murojaah Tracking**:
    - [ ] UI untuk menambah/melihat data murojaah harian
    - [ ] Simpan data ke Firestore
- [ ] **Sholat Dhuha Tracking**:
    - [ ] UI sederhana (misal: tombol checklist) di Dashboard
    - [ ] Simpan data ke Firestore
- [ ] **Custom Habits Tracking**:
    - [ ] UI untuk menambah/mengelola kebiasaan kustom
    - [ ] Simpan data ke Firestore

### Layanan & API
- [ ] Setup Prayer Time Service (API Kemenag)
- [ ] Tampilkan jadwal sholat di UI
- [x] Setup Notification Service
- [ ] Implementasi notifikasi pengingat waktu sholat
- [ ] Implementasi pengingat kustom

## Fase 2: Fitur Lanjutan

### Analitik & Visualisasi
- [ ] **Heatmap Calendar**:
    - [ ] Buat widget kalender heatmap
    - [ ] Integrasikan dengan data murojaah dari Firestore
- [ ] **Halaman Analisis Detail**:
    - [ ] Desain UI untuk halaman analisis
    - [ ] Buat grafik (charts) untuk progres mingguan/bulanan

### Gamifikasi
- [ ] **Sistem XP & Level**:
    - [ ] Cloud Function untuk menambah XP setiap ada aktivitas baru
    - [ ] Tampilkan XP dan level di profil pengguna
- [ ] **Sistem Lencana (Badges)**:
    - [ ] Desain aset untuk badges
    - [ ] Logika untuk membuka lencana berdasarkan pencapaian
- [ ] **Papan Peringkat (Leaderboard)**:
    - [ ] UI untuk menampilkan leaderboard global
    - [ ] Query data dari Firestore untuk peringkat mingguan/bulanan

### Profil & Pengaturan
- [x] Halaman Pengaturan (UI dasar)
- [ ] **Manajemen Profil**:
    - [ ] UI untuk mengubah nama
    - [ ] Integrasi Cloudinary untuk upload foto profil
    - [ ] Cloud Function untuk resize gambar
- [ ] **Pengaturan Tema**:
    - [ ] Implementasi switch Dark/Light Mode

### Fitur Tambahan
- [ ] **Konsultasi AI**:
    - [ ] UI halaman chat
    - [ ] Integrasi dengan Gemini API
- [ ] **Catatan Harian (Journal)**:
    - [ ] UI untuk menambah/melihat catatan harian
    - [ ] Simpan data ke Firestore
    - [ ] Pendekatan Offline fisrt untuk save data ketika sedang offline dan sync data ketika online (ketika user baru buka aplikasi)
