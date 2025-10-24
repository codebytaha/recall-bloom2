import 'dart:convert';
import 'package:recall_bloom/models/study_streak.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/utils/date_helpers.dart';

class StreakService {
  static const String _storageKey = 'study_streak';
  final LocalStorageService _storage;

  StreakService(this._storage);

  Future<StudyStreak?> getStreak(String userId) async {
    final streakData = _storage.getString(_storageKey);
    if (streakData == null) return null;
    
    final streak = StudyStreak.fromJson(jsonDecode(streakData));
    return streak.userId == userId ? streak : null;
  }

  Future<void> updateStreakOnStudyLog(String userId) async {
    final streak = await getStreak(userId);
    final today = DateHelpers.today;
    
    if (streak == null) {
      await _createNewStreak(userId, today);
      return;
    }

    if (DateHelpers.isSameDay(streak.lastStudyDate, today)) {
      return;
    }

    final daysSinceLastStudy = DateHelpers.daysBetween(streak.lastStudyDate, today);

    if (daysSinceLastStudy == 1) {
      final newStreak = streak.currentStreak + 1;
      final updatedStreak = streak.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > streak.longestStreak ? newStreak : streak.longestStreak,
        lastStudyDate: today,
        updatedAt: DateTime.now(),
      );
      await _saveStreak(updatedStreak);
    } else {
      final updatedStreak = streak.copyWith(
        currentStreak: 1,
        lastStudyDate: today,
        updatedAt: DateTime.now(),
      );
      await _saveStreak(updatedStreak);
    }
  }

  Future<void> _createNewStreak(String userId, DateTime today) async {
    final now = DateTime.now();
    final streak = StudyStreak(
      id: 'streak_$userId',
      userId: userId,
      currentStreak: 1,
      longestStreak: 1,
      lastStudyDate: today,
      createdAt: now,
      updatedAt: now,
    );
    await _saveStreak(streak);
  }

  Future<void> _saveStreak(StudyStreak streak) async {
    await _storage.saveData(_storageKey, jsonEncode(streak.toJson()));
  }

  Future<void> clearStreak(String userId) async {
    await _storage.remove(_storageKey);
  }

  Future<void> initializeSampleData(String userId) async {
    final streak = await getStreak(userId);
    if (streak != null) return;

    final now = DateTime.now();
    final sampleStreak = StudyStreak(
      id: 'streak_$userId',
      userId: userId,
      currentStreak: 3,
      longestStreak: 7,
      lastStudyDate: DateHelpers.today,
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now,
    );

    await _saveStreak(sampleStreak);
  }
}
