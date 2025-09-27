import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import 'package:myapp/models/progress_summary.dart';
import '../models/murojaah_record.dart';

/// # Firestore Service
/// This class handles all interactions with the Cloud Firestore database.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Profile --- //

  /// ## Create User Profile
  /// Creates a new document in the 'users' collection when a user registers.
  Future<void> createUserProfile(User user) async {
    try {
      final userDocRef = _db.collection('users').doc(user.uid);
      await _db.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDocRef);
        if (!userSnapshot.exists) {
          transaction.set(userDocRef, {
            'profile': {
              'email': user.email,
              'createdAt': FieldValue.serverTimestamp(),
            },
            'settings': {
              'darkMode': false,
              'notifEnabled': true,
            }
          });
        }
      });
    } catch (e, s) {
      developer.log('Error creating user profile', name: 'FirestoreService', error: e, stackTrace: s);
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

  // --- Murojaah Records --- //

  /// ## Get Murojaah Records
  /// Retrieves a stream of murojaah records for a given user.
  Stream<Map<DateTime, MurojaahRecord>> getMurojaahRecords(String userId) {
    try {
      final collectionRef = _db.collection('users').doc(userId).collection('murojaahEntries');
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
      final docId = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
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
  /// Calculates the user's current streak and weekly completion rate based on the new logic.
  Future<ProgressSummary> getProgressSummary(String userId) async {
    try {
      final snapshot = await _db.collection('users').doc(userId).collection('murojaahEntries').get();

      final records = snapshot.docs.map((doc) {
        try {
          return MurojaahRecord.fromFirestore(doc);
        } catch (e) {
          return null;
        }
      }).whereType<MurojaahRecord>().toSet();
      
      // Use the `isCompleted` getter from the model to determine completion.
      final completedDates = records
          .where((r) => r.isCompleted)
          .map((r) => DateTime.utc(r.date.year, r.date.month, r.date.day))
          .toSet();

      if (completedDates.isEmpty) {
        return ProgressSummary(currentStreak: 0, weeklyCompletionRate: 0.0);
      }

      int currentStreak = 0;
      DateTime todayUtc = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime dateToCheck = completedDates.contains(todayUtc) ? todayUtc : todayUtc.subtract(const Duration(days: 1));

      while (completedDates.contains(dateToCheck)) {
        currentStreak++;
        dateToCheck = dateToCheck.subtract(const Duration(days: 1));
      }

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
      return ProgressSummary(currentStreak: 0, weeklyCompletionRate: 0.0);
    }
  }

  // --- Custom Habits --- //

  /// ## Get Custom Habits
  /// Retrieves a stream of the user's custom habits.
  Stream<List<String>> getCustomHabits(String userId) {
    try {
      final docRef = _db.collection('users').doc(userId).collection('habits').doc('userHabits');
      return docRef.snapshots().map((snapshot) {
        if (snapshot.exists && snapshot.data()!.containsKey('habitList')) {
          final data = snapshot.data()!['habitList'];
          // Ensure data is treated as a list of strings
          return List<String>.from(data as List);
        }
        return [];
      });
    } catch (e, s) {
      developer.log('Error fetching custom habits', name: 'FirestoreService', error: e, stackTrace: s);
      return Stream.value([]);
    }
  }

  /// ## Add Custom Habit
  /// Adds a new habit to the user's list of custom habits.
  Future<void> addCustomHabit(String userId, String habit) async {
    if (habit.trim().isEmpty) return;
    try {
      await _db.collection('users').doc(userId).collection('habits').doc('userHabits').set({
        'habitList': FieldValue.arrayUnion([habit.trim()])
      }, SetOptions(merge: true));
    } catch (e, s) {
      developer.log('Error adding custom habit', name: 'FirestoreService', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ## Delete Custom Habit
  /// Removes a habit from the user's list of custom habits.
  Future<void> deleteCustomHabit(String userId, String habit) async {
    try {
      await _db.collection('users').doc(userId).collection('habits').doc('userHabits').update({
        'habitList': FieldValue.arrayRemove([habit])
      });
    } catch (e, s) {
      developer.log('Error deleting custom habit', name: 'FirestoreService', error: e, stackTrace: s);
      rethrow;
    }
  }
}
