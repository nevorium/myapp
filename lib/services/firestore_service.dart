import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import 'package:myapp/models/progress_summary.dart';

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
  
  /// ## Get User Creation Date
  /// Fetches the creation timestamp of the user's profile.
  Future<DateTime?> getUserCreationDate(String userId) async {
    try {
      final docSnapshot = await _db.collection('users').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('profile')) {
        final profile = docSnapshot.data()!['profile'] as Map<String, dynamic>;
        final timestamp = profile['createdAt'] as Timestamp?;
        return timestamp?.toDate();
      }
      return null;
    } catch (e, s) {
      developer.log('Error fetching user creation date', name: 'FirestoreService', error: e, stackTrace: s);
      return null;
    }
  }

  /// ## Get Murojaah Records
  /// Retrieves a stream of murojaah records for a given user.
  Stream<Map<DateTime, MurojaahRecord>> getMurojaahRecords(String userId) {
    try {
      final collectionRef =
          _db.collection('users').doc(userId).collection('murojaahEntries');

      return collectionRef.snapshots().map((snapshot) {
        final recordsMap = <DateTime, MurojaahRecord>{};
        for (var doc in snapshot.docs) {
          try {
            final record = MurojaahRecord.fromFirestore(doc);
            final normalizedDate = DateTime.utc(record.date.year, record.date.month, record.date.day);
            recordsMap[normalizedDate] = record;
          } catch (e) {
            developer.log('Error parsing murojaah record: ${doc.id}', name: 'FirestoreService', error: e);
          }
        }
        return recordsMap;
      });
    } catch (e, s) {
       developer.log('Error fetching murojaah records stream', name: 'FirestoreService', error: e, stackTrace: s);
      return Stream.value({});
    }
  }

  /// ## Update Murojaah Record
  /// Creates or updates a murojaah record for a specific date.
  Future<void> updateMurojaahRecord(String userId, MurojaahRecord record) async {
    try {
      final docId =
          '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
          
      await _db
          .collection('users')
          .doc(userId)
          .collection('murojaahEntries')
          .doc(docId)
          .set(record.toFirestore(), SetOptions(merge: true));
    } catch (e, s) {
      developer.log('Error updating murojaah record', name: 'FirestoreService', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ## Get Progress Summary
  /// Calculates the user's current streak and weekly completion rate.
  Future<ProgressSummary> getProgressSummary(String userId) async {
    try {
      final snapshot = await _db.collection('users').doc(userId).collection('murojaahEntries').get();
      
      final records = snapshot.docs.map((doc) {
        try {
          return MurojaahRecord.fromFirestore(doc);
        } catch (e) {
          return null;
        }
      }).where((record) => record != null && record.completed).cast<MurojaahRecord>().toSet();

      if (records.isEmpty) {
        return ProgressSummary(currentStreak: 0, weeklyCompletionRate: 0.0);
      }

      final completedDates = records.map((r) => DateTime.utc(r.date.year, r.date.month, r.date.day)).toSet();

      // --- Calculate Current Streak ---
      int currentStreak = 0;
      DateTime today = DateTime.now();
      DateTime todayUtc = DateTime.utc(today.year, today.month, today.day);

      // Check if today is completed, if not, start from yesterday
      DateTime dateToCheck = completedDates.contains(todayUtc) ? todayUtc : todayUtc.subtract(const Duration(days: 1));

      while (completedDates.contains(dateToCheck)) {
        currentStreak++;
        dateToCheck = dateToCheck.subtract(const Duration(days: 1));
      }

      // --- Calculate Weekly Completion Rate ---
      int completedInLast7Days = 0;
      for (int i = 0; i < 7; i++) {
        final date = todayUtc.subtract(Duration(days: i));
        if (completedDates.contains(date)) {
          completedInLast7Days++;
        }
      }
      double weeklyRate = (completedInLast7Days / 7.0) * 100;

      return ProgressSummary(
        currentStreak: currentStreak,
        weeklyCompletionRate: weeklyRate,
      );

    } catch (e, s) {
      developer.log('Error calculating progress summary', name: 'FirestoreService', error: e, stackTrace: s);
      // Return a default summary in case of error
      return ProgressSummary(currentStreak: 0, weeklyCompletionRate: 0.0);
    }
  }
}
