ERD dan PRD - Aplikasi Murojaah MVP
1. ERD (Entity Relationship Diagram)
Entity: Users
FieldTypeDescriptionuser_idString (Primary Key)ID unik penggunaemailStringEmail penggunadisplay_nameStringNama tampilancreated_atDateTimeTanggal daftartimezoneStringZona waktu penggunanotification_settingsObjectPengaturan notifikasi
Entity: Murojaah_Records
FieldTypeDescriptionrecord_idString (Primary Key)ID unik catatanuser_idString (Foreign Key)Referensi ke UsersdateDateTanggal murojaah (YYYY-MM-DD)completedBooleanStatus selesai/belumnoteStringCatatan hariantimestampDateTimeWaktu input data
Entity: User_Settings
FieldTypeDescriptionsetting_idString (Primary Key)ID unik pengaturanuser_idString (Foreign Key)Referensi ke Usersprayer_timesArrayWaktu sholat untuk notifikasireminder_enabledBooleanAktif/tidaknya pengingatstreak_start_dateDateTanggal mulai streak
Relasi:

Users 1 to Many Murojaah_Records
Users 1 to 1 User_Settings


2. PRD (Product Requirements Document)
A. Product Overview
Nama Produk: Aplikasi Murojaah MVP
Visi: Membantu Muslim menjaga konsistensi murojaah Al-Quran dengan tracking sederhana dan motivasi harian
Target User: Muslim yang ingin rutin murojaah tapi butuh bantuan tracking dan motivasi
B. Core Features
Feature 1: Checklist Harian + Note
User Story: "Sebagai pengguna, saya ingin bisa check murojaah hari ini dan tulis catatan singkat"
Acceptance Criteria:

Bisa check/uncheck "Sudah murojaah hari ini"
Bisa tulis note maksimal 200 karakter
Data tersimpan otomatis ke Firebase
Tampilan simpel seperti to-do list

Mockup Flow:
[Hari ini: Sabtu, 5 Juli 2025]
☐ Sudah murojaah hari ini
┌─────────────────────────────┐
│ Catatan: Alhamdulillah bisa │
│ khatam Surah Al-Baqarah...  │
└─────────────────────────────┘
[Simpan]
Feature 2: Dashboard Progress
User Story: "Sebagai pengguna, saya ingin lihat progress murojaah dalam bentuk kalendar dan persentase"
Acceptance Criteria:

Tampilan kalendar bulanan dengan heat map
Hijau = sudah murojaah, abu-abu = belum, merah = hari yangterlewat sejak tanggal signup dan tidak murojaah
Persentase completion rate mingguan
Bisa navigasi bulan sebelumnya/berikutnya

Mockup Flow:
[Juli 2025 - 80% minggu ini]
S  M  T  W  T  F  S
   1  2  3  4  5  6
🟢 🟢 ⚫ 🟢 🟢 🟢 ⚫
7  8  9  10 11 12 13
Feature 3: Motivasi Widget
User Story: "Sebagai pengguna, saya ingin lihat motivasi dan streak counter"
Acceptance Criteria:

Tampilan progress hari ini
Streak counter (berapa hari berturut-turut)
Motivasi singkat berdasarkan progress
Update realtime

Mockup Flow:
┌─────────────────────────────┐
│ 🔥 Streak: 7 hari           │
│ 📊 Progress: 80% minggu ini  │
│ 💪 "Istiqomah itu kunci!"   │
└─────────────────────────────┘
Feature 4: Notifikasi Pengingat
User Story: "Sebagai pengguna, saya ingin diingatkan untuk murojaah di waktu sholat"
Acceptance Criteria:

Notifikasi push di 5 waktu sholat
Pengingat khusus jika belum check hari ini
Bisa setting on/off notifikasi
Notifikasi tidak mengganggu (gentle reminder)

C. Technical Requirements
Frontend:

React Native / Flutter untuk mobile
State management sederhana (useState/setState)
Offline-first approach dengan sync ke Firebase
UI/UX simpel dan intuitif

Backend:

Firebase Authentication untuk login
Firestore untuk database
Cloud Functions untuk business logic
Firebase Cloud Messaging untuk notifikasi

Database Structure (Firebase):
users/
├── {userId}/
    ├── profile/
    │   ├── email: string
    │   ├── displayName: string
    │   └── createdAt: timestamp
    ├── murojaah/
    │   ├── 2025-07-05/
    │   │   ├── completed: boolean
    │   │   ├── note: string
    │   │   └── timestamp: timestamp
    │   └── 2025-07-06/
    │       ├── completed: boolean
    │       ├── note: string
    │       └── timestamp: timestamp
    └── settings/
        ├── prayerTimes: array
        ├── reminderEnabled: boolean
        └── streakStartDate: date
D. Success Metrics
User Engagement:

Daily Active Users (DAU)
Completion rate harian > 70%
Retention rate 30 hari > 40%
Average streak length > 7 hari

Technical Metrics:

App load time < 2 detik
Crash rate < 1%
Offline functionality 100% untuk core features

E. Development Timeline
Sprint 1 (2 minggu):

Setup project structure
Firebase authentication
Basic UI components
Database schema implementation

Sprint 2 (2 minggu):

Checklist harian + note feature
Basic dashboard kalendar
Data sync Firebase

Sprint 3 (2 minggu):

Progress tracking & heat map
Motivasi widget
Perhitungan streak

Sprint 4 (1 minggu):

Push notifications
Testing & bug fixes
App store deployment

F. Risk & Mitigation
Technical Risks:

Firebase quota limit → Implementasi caching offline
Performance issue → Lazy loading dan pagination
Push notification reliability → Fallback ke local notification

Product Risks:

User adoption rendah → A/B testing UI/UX
Feature complexity → Stick to MVP, iterasi bertahap
Motivation drop → Gamification elements di future release
Heatmap logic error → Validasi signup_timestamp vs current date
Timezone inconsistency → Standardisasi ke UTC, convert di frontend


3. Analogi Sederhana (Biar Mudah Dipahami)
ERD itu seperti peta desa:

Entity = Rumah-rumah (Users, Murojaah_Records, dll)
Relationship = Jalan yang menghubungkan rumah
Fields = Isi rumah (nama, alamat, dll)

PRD itu seperti rencana membangun warung:

Product Overview = Visi warung (mau jual apa, target pembeli siapa)
Features = Menu-menu yang akan dijual
Technical Requirements = Alat masak, bahan, cara masak
Success Metrics = Target penjualan per hari
Timeline = Kapan warung buka, tahapan persiapan

Firebase Structure seperti lemari bertingkat:
Lemari Besar (Firebase)
├── Laci Users (data pengguna)
├── Laci Murojaah (catatan harian)
└── Laci Settings (pengaturan)