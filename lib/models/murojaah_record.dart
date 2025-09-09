import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MurojaahRecord extends Equatable {
  final DateTime date;
  final bool completed;
  final String? note;
  final Timestamp timestamp;

  const MurojaahRecord({
    required this.date,
    required this.completed,
    this.note,
    required this.timestamp,
  });

  // Factory constructor to create a MurojaahRecord from a Firestore document.
  factory MurojaahRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MurojaahRecord(
      date: (data['date'] as Timestamp).toDate(),
      completed: data['completed'] as bool,
      note: data['note'] as String?,
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  // A method to convert the MurojaahRecord instance to a map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'completed': completed,
      'note': note,
      'timestamp': timestamp,
    };
  }
  
  //copyWith method
  MurojaahRecord copyWith({
    DateTime? date,
    bool? completed,
    String? note,
    Timestamp? timestamp,
  }) {
    return MurojaahRecord(
      date: date ?? this.date,
      completed: completed ?? this.completed,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [date, completed, note, timestamp];
}
