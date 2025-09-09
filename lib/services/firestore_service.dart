import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import '../models/murojaah_record.dart';

/// # Firestore Service
/// This class handles all interactions with the Cloud Firestore database.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ## Create User Profile
  /// Creates a new document in the 'users' collection when a user registers.
  Future<void> createUserProfile(User user) async {
    try {
      await _db.collection('users').doc(user.uid).set({
        'profile': {
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        },
        'settings': {
          'darkMode': false,
          'notifEnabled': true,
        }
      });
    } catch (e, s) {
      developer.log(
        'Error creating user profile',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  /// ## Get Murojaah Records
  /// Retrieves a stream of murojaah records for a given user, organized by date.
  ///
  /// - **`userId`**: The UID of the user whose records are to be fetched.
  /// - **Returns**: A `Stream` of a `Map` where keys are `DateTime` (normalized to UTC midnight)
  ///   and values are the corresponding `MurojaahRecord`. This structure is optimized
  ///   for use with the `table_calendar` package.
  Stream<Map<DateTime, MurojaahRecord>> getMurojaahRecords(String userId) {
    try {
      final collectionRef =
          _db.collection('users').doc(userId).collection('murojaahEntries');

      return collectionRef.snapshots().map((snapshot) {
        final recordsMap = <DateTime, MurojaahRecord>{};
        for (var doc in snapshot.docs) {
          try {
            final record = MurojaahRecord.fromFirestore(doc);
            // Normalize the date to UTC midnight to ensure consistent keys.
            final normalizedDate = DateTime.utc(record.date.year, record.date.month, record.date.day);
            recordsMap[normalizedDate] = record;
          } catch (e) {
            // Log error for individual document parsing but continue processing others.
            developer.log(
              'Error parsing murojaah record with doc ID: ${doc.id}',
              name: 'FirestoreService.getMurojaahRecords',
              error: e,
            );
          }
        }
        return recordsMap;
      });
    } catch (e, s) {
       developer.log(
        'Error fetching murojaah records stream',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
      // Return an empty stream in case of an error.
      return Stream.value({});
    }
  }

  /// ## Update Murojaah Record
  /// Creates or updates a murojaah record for a specific date.
  ///
  /// - **`userId`**: The UID of the user.
  /// - **`record`**: The `MurojaahRecord` object containing the data to be saved.
  ///
  /// It uses the date part of the record as a unique identifier for the document,
  /// ensuring that each day has only one record.
  Future<void> updateMurojaahRecord(String userId, MurojaahRecord record) async {
    try {
      // Use a consistent, predictable ID for the document (e.g., 'YYYY-MM-DD').
      final docId =
          '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
          
      await _db
          .collection('users')
          .doc(userId)
          .collection('murojaahEntries')
          .doc(docId)
          .set(record.toFirestore(), SetOptions(merge: true)); // Use merge to avoid overwriting fields
    } catch (e, s) {
      developer.log(
        'Error updating murojaah record',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
