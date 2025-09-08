# 📱 Murojaah MVP Blueprint

## Overview

Murojaah adalah aplikasi mobile sederhana untuk melacak murojaah (hafalan/ulangan bacaan Quran) harian. Aplikasi dibangun dengan Flutter dan Firebase sebagai backend. Fokus MVP adalah tracking, progress dashboard, motivasi singkat, dan reminder notifikasi lokal.

**Bahasa Aplikasi:** Seluruh konten dan interaksi di dalam aplikasi akan menggunakan **Bahasa Indonesia**.

## Sprint 1: Setup & Core Features (Completed)

-   **Objective:** Menyiapkan struktur proyek, mengintegrasikan Firebase Authentication (email/password), membuat struktur database di Firestore, dan membangun UI dasar dengan tema gelap/terang.
-   **Status:** ✅ **Selesai**. Aplikasi memiliki alur autentikasi yang berfungsi penuh, terhubung ke Firebase, dan memiliki struktur dasar yang solid.

---

## Sprint 2: Dashboard & Interactivity

### 🎯 Objective:
Mengimplementasikan fitur inti pada `HomeScreen`, termasuk dashboard kalender interaktif dan fungsionalitas checklist harian yang terhubung dengan Firestore.

### 1. Model Data Murojaah
-   Buat file `lib/models/murojaah_record.dart`.
-   Definisikan kelas `MurojaahRecord` yang merepresentasikan data murojaah harian (`date`, `completed`, `note`, `timestamp`).
-   Sertakan method `fromJson` dan `toJson` untuk konversi data dari dan ke Firestore.

### 2. Update Firestore Service
-   Tambahkan method baru di `FirestoreService` untuk:
    -   **`getMurojaahRecords(String userId)`**: Mengambil semua data murojaah seorang pengguna dalam bentuk `Stream<Map<DateTime, MurojaahRecord>>` untuk ditampilkan di kalender.
    -   **`updateMurojaahRecord(String userId, MurojaahRecord record)`**: Membuat atau memperbarui data murojaah untuk tanggal tertentu. Ini akan digunakan oleh checklist harian.

### 3. Implementasi Calendar View
-   Gunakan package `table_calendar` di `HomeScreen`.
-   Hubungkan kalender dengan data dari `FirestoreService`.
-   **Event Loader**: Tandai hari-hari di kalender yang memiliki data murojaah (`completed: true`) dengan penanda visual (misalnya, titik hijau).
-   **Styling**: Sesuaikan tampilan kalender agar cocok dengan tema aplikasi (warna header, marker, dll.).
-   Fokus pada bulan ini, dengan kemampuan navigasi ke bulan sebelumnya/berikutnya.

### 4. Daily Checklist & Note Feature
-   Di bawah kalender pada `HomeScreen`, buat sebuah widget untuk hari yang dipilih.
-   Widget ini akan menampilkan:
    -   Sebuah `Checkbox` dengan label "Sudah murojaah hari ini".
    -   Sebuah `TextField` untuk memasukkan catatan harian (maksimal 200 karakter).
    -   Sebuah tombol "Simpan".
-   **State Management**: Gunakan `StatefulWidget` atau `Provider` untuk mengelola state dari checklist (apakah sudah dicentang, isi catatan, dll.) secara real-time.
-   Saat tombol "Simpan" ditekan, panggil method `updateMurojaahRecord` dari `FirestoreService` untuk menyimpan data ke Firestore.

### 5. Error Handling & User Feedback
-   Tampilkan `CircularProgressIndicator` saat data kalender sedang dimuat.
-   Tampilkan pesan yang jelas jika terjadi error saat mengambil atau menyimpan data.
-   Gunakan `SnackBar` untuk memberikan feedback setelah data berhasil disimpan.

### ✅ Success Criteria Sprint 2
-   `HomeScreen` menampilkan kalender interaktif.
-   Hari-hari di mana pengguna sudah murojaah ditandai dengan jelas di kalender.
-   Pengguna dapat memilih tanggal di kalender untuk melihat/mengedit checklist harian.
-   Pengguna dapat mencentang checkbox, menulis catatan, dan menyimpannya ke Firestore.
-   Perubahan data di Firestore langsung terefleksikan di UI kalender.
-   Aplikasi menangani kondisi loading dan error dengan baik.
