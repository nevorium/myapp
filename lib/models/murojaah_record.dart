import 'package:cloud_firestore/cloud_firestore.dart';

/// # Murojaah Record Model
/// Represents a single day's murojaah and religious activities.
/// This model is designed to be extensible to include various types of activities.
class MurojaahRecord {
  /// The specific date for which this record is logged.
  final DateTime date;

  /// The timestamp of when this record was last updated.
  final Timestamp timestamp;

  /// A section for tracking Quran reading/review (murojaah).
  /// Stores the portion of Juz reviewed, e.g., "1/4 juz", "1 juz".
  final String? murojaahJuz;

  /// A section for tracking Quran recitation (tilawah).
  /// Stores the name of the Surah recited, e.g., "Al-Baqarah".
  final String? tilawahSurah;

  /// A boolean flag to indicate if the user added new memorization (ziyadah).
  final bool ziyadah;

  /// A map to store the completion status of user-defined custom habits.
  /// The key is the habit name (e.g., "Sholat Dhuha") and the value is its status.
  final Map<String, bool> customHabits;

  /// An optional text note for any additional reflections or details for the day.
  final String? note;

  MurojaahRecord({
    required this.date,
    required this.timestamp,
    this.murojaahJuz,
    this.tilawahSurah,
    this.ziyadah = false,
    this.customHabits = const {},
    this.note,
  });

  /// ## isCompleted (Helper Getter)
  /// Determines if the record is considered "complete" for display purposes (e.g., heatmap).
  /// A day is marked complete if at least one of the primary activities is performed
  /// or if a note is added.
  bool get isCompleted {
    return murojaahJuz != null ||
           tilawahSurah != null ||
           ziyadah == true ||
           (customHabits.isNotEmpty && customHabits.containsValue(true)) ||
           (note != null && note!.trim().isNotEmpty);
  }

  /// ## Factory fromFirestore
  /// Creates a `MurojaahRecord` instance from a Firestore document snapshot.
  factory MurojaahRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MurojaahRecord(
      date: (data['date'] as Timestamp).toDate(),
      timestamp: data['timestamp'] as Timestamp,
      murojaahJuz: data['murojaahJuz'] as String?,
      tilawahSurah: data['tilawahSurah'] as String?,
      ziyadah: data['ziyadah'] as bool? ?? false,
      // Handle customHabits conversion carefully
      customHabits: Map<String, bool>.from(data['customHabits'] ?? {}),
      note: data['note'] as String?,
    );
  }

  /// ## toFirestore
  /// Converts a `MurojaahRecord` instance into a map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'timestamp': timestamp,
      'murojaahJuz': murojaahJuz,
      'tilawahSurah': tilawahSurah,
      'ziyadah': ziyadah,
      'customHabits': customHabits,
      'note': note,
    };
  }

  /// ## copyWith
  /// Creates a copy of this record but with given fields replaced with new values.
  /// This is useful for immutably updating the state.
  MurojaahRecord copyWith({
    DateTime? date,
    Timestamp? timestamp,
    String? murojaahJuz,
    String? tilawahSurah,
    bool? ziyadah,
    Map<String, bool>? customHabits,
    String? note,
  }) {
    return MurojaahRecord(
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      murojaahJuz: murojaahJuz ?? this.murojaahJuz,
      tilawahSurah: tilawahSurah ?? this.tilawahSurah,
      ziyadah: ziyadah ?? this.ziyadah,
      customHabits: customHabits ?? this.customHabits,
      note: note ?? this.note,
    );
  }
}
