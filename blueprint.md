# 📱 Murojaah MVP Blueprint

## Overview

Murojaah adalah aplikasi mobile sederhana untuk melacak murojaah (hafalan/ulangan bacaan Quran) harian. Aplikasi dibangun dengan Flutter dan Firebase sebagai backend. Fokus MVP adalah tracking, progress dashboard, motivasi singkat, dan reminder notifikasi lokal.

**Bahasa Aplikasi:** Seluruh konten dan interaksi di dalam aplikasi akan menggunakan **Bahasa Indonesia**.

## Sprint 1: Setup & Core Features (Completed)

-   **Objective:** Menyiapkan struktur proyek, mengintegrasikan Firebase Authentication (email/password), membuat struktur database di Firestore, dan membangun UI dasar dengan tema gelap/terang.
-   **Status:** ✅ **Selesai**.

---

## Sprint 2: Dashboard & Interactivity (Completed)

-   **Objective:** Mengimplementasikan fitur inti pada `HomeScreen`, termasuk dashboard kalender interaktif dan fungsionalitas checklist harian.
-   **Status:** ✅ **Selesai**.

---

## Sprint 3: Motivation & Reminders (Completed)

-   **Objective:** Menambahkan fitur kutipan motivasi dan notifikasi pengingat harian yang dapat diatur pengguna.
-   **Status:** ✅ **Selesai**.

---

## Sprint 4: Advanced Progress Tracking (In Progress)

### 🎯 Objective:
Meningkatkan `HomeScreen` dengan metrik progres yang lebih detail sesuai PRD, termasuk *streak counter*, persentase mingguan, dan *heat map* pada kalender untuk memberikan feedback visual yang lebih kaya kepada pengguna.

### 1. Streak Counter & Weekly Progress Logic
-   **Firestore Service:** Tambahkan method baru di `FirestoreService` untuk:
    -   `getProgressSummary(String userId)`: Sebuah method yang mengambil data murojaah sebulan terakhir dan mengkalkulasikan:
        -   **Current Streak:** Jumlah hari beruntun murojaah (`completed: true`) hingga hari ini atau kemarin.
        -   **Weekly Completion Rate:** Persentase hari murojaah dalam 7 hari terakhir.
-   **Model:** Buat model data `ProgressSummary` untuk menampung hasil kalkulasi di atas.

### 2. UI - Progress Summary Widget
-   **Desain Widget:** Buat sebuah widget baru di `HomeScreen` (misalnya di atas kalender) untuk menampilkan:
    -   Icon api (🔥) diikuti dengan angka *streak* (contoh: "🔥 7 Hari Beruntun").
    -   Icon grafik (📊) diikuti dengan persentase mingguan (contoh: "📊 85% Minggu Ini").
-   **State Management:** Gunakan `FutureBuilder` untuk memanggil `getProgressSummary` dan menampilkan hasilnya atau *loading indicator*.

### 3. Calendar Heat Map Enhancement
-   **Logic:** Perbarui `eventLoader` atau `calendarBuilders` pada `TableCalendar` di `HomeScreen`.
-   **Visuals:**
    -   Gunakan **lingkaran hijau solid** untuk hari yang `completed: true`.
    -   Gunakan **lingkaran merah transparan** untuk hari yang terlewat (hari setelah user mendaftar tapi tidak ada data `completed: true`).
    -   Biarkan default untuk hari ini dan hari di masa depan.

### ✅ Success Criteria Sprint 4
-   `HomeScreen` menampilkan *streak* murojaah pengguna secara akurat.
-   `HomeScreen` menampilkan persentase penyelesaian murojaah dalam 7 hari terakhir.
-   Kalender di `HomeScreen` menampilkan *heat map* dengan warna hijau untuk hari selesai dan merah untuk hari terlewat.
-   Semua data progres diperbarui setiap kali pengguna membuka aplikasi.

---

## Sprint 5: Prayer Time Notifications (Planned)

### 🎯 Objective:
Mengganti sistem notifikasi harian menjadi notifikasi yang terikat dengan 5 waktu sholat, sesuai dengan permintaan PRD.

### 1. Prayer Time API Integration
-   Identifikasi dan pilih API publik untuk mendapatkan jadwal sholat berdasarkan lokasi (misalnya, `aladhan.com`).
-   Buat service baru (`PrayerTimeService`) untuk mengambil data jadwal sholat.

### 2. Update Notification Service
-   Modifikasi `NotificationService` untuk dapat menjadwalkan 5 notifikasi berbeda setiap hari sesuai jadwal dari `PrayerTimeService`.

### 3. UI/UX Update
-   Perbarui `SettingsScreen` agar pengguna dapat mengaktifkan/menonaktifkan notifikasi per waktu sholat (Subuh, Dzuhur, Ashar, Maghrib, Isya).
-   Tambahkan fitur deteksi lokasi untuk otomatisasi pengambilan jadwal sholat.
