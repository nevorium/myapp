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

## Sprint 4: Advanced Progress Tracking (Completed)

-   **Objective:** Meningkatkan `HomeScreen` dengan metrik progres yang lebih detail (streak, persentase mingguan, heat map).
-   **Status:** ✅ **Selesai**.

---

## Sprint 5: Prayer Time Notifications (Completed)

-   **Objective:** Mengganti sistem notifikasi harian menjadi notifikasi yang terikat dengan 5 waktu sholat.
-   **Status:** ✅ **Selesai**.

---

## Sprint 6: UI Refactor & Detailed Journaling (In Progress)

-   **Objective:** Merombak struktur UI dengan `BottomNavigationBar` untuk navigasi yang lebih baik, memperkaya fitur jurnal harian dengan checklist yang lebih detail (Murojaah, Tilawah, Ziyadah, Habit Kustom), dan meningkatkan visual kalender.

### 1. UI/UX Refactor & Navigation (Checklist)

-   [ ] **Bottom Navigation Bar:** Implementasikan `BottomNavigationBar` dengan dua tab utama: "Dashboard" (untuk kalender dan ringkasan) dan "Jurnal" (untuk input data harian).
-   [ ] **Main Screen:** Buat `MainScreen` sebagai *stateful widget* baru yang akan menjadi *host* untuk `BottomNavigationBar` dan mengelola halaman-halaman.
-   [ ] **Dashboard Screen:** Ganti nama `HomeScreen` menjadi `DashboardScreen` dan pindahkan semua konten terkait kalender dan ringkasan progres ke sini.
-   [ ] **Journal Screen:** Buat `JournalScreen` sebagai halaman baru untuk menampung semua input checklist harian.

### 2. Data Model Expansion (Checklist)

-   [ ] **Perbarui `MurojaahRecord`:** Modifikasi model `MurojaahRecord` di `lib/models/murojaah_record.dart` untuk menyimpan data yang lebih terstruktur dan detail. Hapus `completed` dan ganti dengan field-field baru:
    -   `murojaahJuz: String?` (menyimpan nilai seperti "1/4 juz", "1 juz", dll.)
    -   `tilawahSurah: String?` (menyimpan nama surah yang dipilih)
    -   `ziyadah: bool` (true jika menambah hafalan)
    -   `customHabits: Map<String, bool>` (menyimpan status checklist untuk habit kustom)
    -   `note: String?` (catatan teks tetap ada, tapi terpisah).
    -   Tambahkan *helper method* `isCompleted` yang mengembalikan `true` jika salah satu dari aktivitas di atas diisi.

### 3. Feature Implementation (Checklist)

-   [ ] **Calendar Theming:** Perbarui logika `TableCalendar` di `DashboardScreen` untuk memberi warna **abu-abu** pada tanggal yang terlewat (tidak ada data `MurojaahRecord`).
-   [ ] **Pisahkan Komentar & Checklist:** Di `JournalScreen`, buat kartu terpisah untuk "Catatan" (`TextField`) dan untuk "Aktivitas Harian".
-   [ ] **Checklist Murojaah:** Buat grup `RadioButton` atau `ChoiceChip` untuk memilih porsi murojaah: `{"1/4 juz", "1/2 juz", "1 juz", "2 juz", "3 juz"}`.
-   [ ] **Checklist Tilawah:** Buat `DropdownButton` yang diisi dengan daftar surah dari `lib/data/quran_surahs.dart`.
-   [ ] **Checklist Ziyadah:** Implementasikan `CheckboxListTile` sederhana untuk menandai penambahan hafalan.
-   [ ] **Checklist Habit Kustom:**
    -   Tampilkan daftar `CheckboxListTile` dinamis berdasarkan habit kustom yang disimpan pengguna.
    -   Buat tombol "Tambah Habit Baru" yang akan memunculkan `AlertDialog` untuk memasukkan nama habit baru.

### 4. Backend & State Management (Checklist)

-   [ ] **Perbarui `FirestoreService`:** Modifikasi `updateMurojaahRecord` dan `getMurojaahRecords` untuk menangani struktur data `MurojaahRecord` yang baru.
-   [ ] **Habit Kustom di Firestore:** Buat method baru di `FirestoreService` (`getCustomHabits`, `addCustomHabit`, `deleteCustomHabit`) untuk mengelola daftar habit kustom pengguna dalam koleksi terpisah (misalnya, `users/{userId}/custom_habits`).

---

### ✅ Success Criteria Sprint 6

-   Aplikasi memiliki `BottomNavigationBar` yang fungsional.
-   Pengguna dapat memasukkan data murojaah, tilawah, ziyadah, dan habit kustom secara terpisah di halaman "Jurnal".
-   Pengguna dapat menambah dan menghapus habit kustom mereka sendiri.
-   Kalender di "Dashboard" secara akurat menampilkan hari yang selesai (hijau), terlewat (abu-abu), dan hari ini.
-   Semua data tersimpan dengan benar di Firestore dengan struktur yang baru.
