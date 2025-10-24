import 'dart:convert';
import 'package:recall_bloom/models/study_log.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/utils/date_helpers.dart';

class StudyLogService {
  static const String _storageKey = 'study_logs';
  final LocalStorageService _storage;

  StudyLogService(this._storage);

  Future<List<StudyLog>> getAllLogs() async {
    final logsData = _storage.getString(_storageKey);
    if (logsData == null) return [];
    
    final List<dynamic> logsList = jsonDecode(logsData);
    return logsList.map((json) => StudyLog.fromJson(json)).toList();
  }

  Future<List<StudyLog>> getLogsByUserId(String userId) async {
    final logs = await getAllLogs();
    return logs.where((log) => log.userId == userId).toList();
  }

  Future<List<StudyLog>> getLogsByDateRange(String userId, DateTime start, DateTime end) async {
    final logs = await getLogsByUserId(userId);
    return logs.where((log) =>
      log.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
      log.createdAt.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  Future<List<StudyLog>> getTodaysLogs(String userId) async {
    final today = DateHelpers.today;
    return getLogsByDateRange(userId, today, today);
  }

  Future<void> addLog(StudyLog log) async {
    final logs = await getAllLogs();
    logs.add(log);
    await _saveLogs(logs);
  }

  Future<void> createLog({
    required String userId,
    required String topic,
    required String subject,
    required int timeSpentMinutes,
    required int understandingRating,
  }) async {
    final now = DateTime.now();
    final log = StudyLog(
      id: 'log_${now.millisecondsSinceEpoch}',
      userId: userId,
      topic: topic,
      subject: subject,
      timeSpentMinutes: timeSpentMinutes,
      understandingRating: understandingRating,
      createdAt: now,
      updatedAt: now,
    );
    await addLog(log);
  }

  Future<void> updateLog(StudyLog log) async {
    final logs = await getAllLogs();
    final index = logs.indexWhere((l) => l.id == log.id);
    if (index != -1) {
      logs[index] = log.copyWith(updatedAt: DateTime.now());
      await _saveLogs(logs);
    }
  }

  Future<void> deleteLog(String logId) async {
    final logs = await getAllLogs();
    logs.removeWhere((log) => log.id == logId);
    await _saveLogs(logs);
  }

  Future<int> getTotalStudyMinutes(String userId) async {
    final logs = await getLogsByUserId(userId);
    return logs.fold<int>(0, (sum, log) => sum + log.timeSpentMinutes);
  }

  Future<double> getAverageUnderstanding(String userId) async {
    final logs = await getLogsByUserId(userId);
    if (logs.isEmpty) return 0.0;
    final sum = logs.fold<int>(0, (sum, log) => sum + log.understandingRating);
    return sum / logs.length;
  }

  Future<Map<String, int>> getStudyCountBySubject(String userId) async {
    final logs = await getLogsByUserId(userId);
    final Map<String, int> counts = {};
    for (var log in logs) {
      counts[log.subject] = (counts[log.subject] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _saveLogs(List<StudyLog> logs) async {
    final logsJson = logs.map((log) => log.toJson()).toList();
    await _storage.saveData(_storageKey, jsonEncode(logsJson));
  }

  Future<void> initializeSampleData(String userId) async {
    final logs = await getAllLogs();
    if (logs.isNotEmpty) return;

    final now = DateTime.now();
    final sampleLogs = [
      StudyLog(
        id: 'log_1',
        userId: userId,
        topic: 'Calculus - Derivatives',
        subject: 'Mathematics',
        timeSpentMinutes: 45,
        understandingRating: 4,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      StudyLog(
        id: 'log_2',
        userId: userId,
        topic: 'Quantum Mechanics Basics',
        subject: 'Physics',
        timeSpentMinutes: 60,
        understandingRating: 3,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      StudyLog(
        id: 'log_3',
        userId: userId,
        topic: 'Object-Oriented Programming',
        subject: 'Computer Science',
        timeSpentMinutes: 90,
        understandingRating: 5,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await _saveLogs(sampleLogs);
  }
}
