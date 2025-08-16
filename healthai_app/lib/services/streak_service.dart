import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakInfo {
  final int streakDays;
  final int entriesInStreak;
  final DateTime? streakStart;
  final bool hasTodayEntry;

  const StreakInfo({
    required this.streakDays,
    required this.entriesInStreak,
    required this.streakStart,
    required this.hasTodayEntry,
  });

  static const zero = StreakInfo(
    streakDays: 0,
    entriesInStreak: 0,
    streakStart: null,
    hasTodayEntry: false,
  );
}

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<StreakInfo> watchStreak({int lookbackDays = 60}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(StreakInfo.zero);

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: lookbackDays));

    return _firestore
        .collection('meals')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        // Use descending to align with existing composite index used elsewhere
        // in the app (e.g., getTodayMeals), avoiding index errors.
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.where((d) => (d.data()['isDeleted'] ?? false) == false);

          // Count entries per local day
          final Map<DateTime, int> entriesPerDay = {};
          for (final doc in docs) {
            final data = doc.data();
            // Use client 'timestamp' consistently for day grouping to avoid
            // server/local drift that can cause flicker.
            final ts = (data['timestamp'] as Timestamp?);
            if (ts == null) continue;
            final dt = ts.toDate().toLocal();
            final dayKey = DateTime(dt.year, dt.month, dt.day);
            entriesPerDay[dayKey] = (entriesPerDay[dayKey] ?? 0) + 1;
          }

          final localNow = DateTime.now();
          final today = DateTime(localNow.year, localNow.month, localNow.day);
          final hasToday = (entriesPerDay[today] ?? 0) > 0;
          if (!hasToday) {
            return const StreakInfo(
              streakDays: 0,
              entriesInStreak: 0,
              streakStart: null,
              hasTodayEntry: false,
            );
          }

          int streakDays = 0;
          int entriesInStreak = 0;
          DateTime cursor = today;
          DateTime streakStart = today;

          while (true) {
            final count = entriesPerDay[cursor] ?? 0;
            if (count <= 0) break;
            streakDays += 1;
            entriesInStreak += count;
            streakStart = cursor;
            cursor = cursor.subtract(const Duration(days: 1));
          }

          return StreakInfo(
            streakDays: streakDays,
            entriesInStreak: entriesInStreak,
            streakStart: streakStart,
            hasTodayEntry: true,
          );
        });
  }
}


