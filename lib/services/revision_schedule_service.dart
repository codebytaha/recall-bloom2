import 'dart:convert';
import 'package:recall_bloom/models/revision_schedule.dart';
import 'package:recall_bloom/models/study_log.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/utils/date_helpers.dart';
import 'package:recall_bloom/utils/spaced_repetition.dart';

class RevisionScheduleService {
  static const String _storageKey = 'revision_schedules';
  final LocalStorageService _storage;

  RevisionScheduleService(this._storage);

  Future<List<RevisionSchedule>> getAllSchedules() async {
    final schedulesData = _storage.getString(_storageKey);
    if (schedulesData == null) return [];
    
    final List<dynamic> schedulesList = jsonDecode(schedulesData);
    return schedulesList.map((json) => RevisionSchedule.fromJson(json)).toList();
  }

  Future<List<RevisionSchedule>> getSchedulesByUserId(String userId) async {
    final schedules = await getAllSchedules();
    return schedules.where((schedule) => schedule.userId == userId).toList();
  }

  Future<List<RevisionSchedule>> getDueRevisions(String userId) async {
    final schedules = await getSchedulesByUserId(userId);
    return schedules.where((schedule) =>
      !schedule.isCompleted &&
      SpacedRepetition.isDueForRevision(schedule.nextRevisionDate)
    ).toList();
  }

  Future<List<RevisionSchedule>> getUpcomingRevisions(String userId) async {
    final schedules = await getSchedulesByUserId(userId);
    return schedules.where((schedule) => !schedule.isCompleted).toList()
      ..sort((a, b) => a.nextRevisionDate.compareTo(b.nextRevisionDate));
  }

  Future<void> createScheduleFromLog(StudyLog log) async {
    final now = DateTime.now();
    final nextRevisionDate = SpacedRepetition.calculateNextRevisionDate(
      lastRevisionDate: log.createdAt,
      revisionCount: 0,
      confidenceRating: log.understandingRating,
    );

    final schedule = RevisionSchedule(
      id: 'schedule_${now.millisecondsSinceEpoch}',
      studyLogId: log.id,
      userId: log.userId,
      topic: log.topic,
      subject: log.subject,
      nextRevisionDate: nextRevisionDate,
      revisionCount: 0,
      lastConfidenceRating: log.understandingRating,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await addSchedule(schedule);
  }

  Future<void> addSchedule(RevisionSchedule schedule) async {
    final schedules = await getAllSchedules();
    schedules.add(schedule);
    await _saveSchedules(schedules);
  }

  Future<void> updateSchedule(RevisionSchedule schedule) async {
    final schedules = await getAllSchedules();
    final index = schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      schedules[index] = schedule.copyWith(updatedAt: DateTime.now());
      await _saveSchedules(schedules);
    }
  }

  Future<void> completeRevision(String scheduleId, int confidenceRating) async {
    final schedules = await getAllSchedules();
    final index = schedules.indexWhere((s) => s.id == scheduleId);
    
    if (index != -1) {
      final schedule = schedules[index];
      final nextRevisionDate = SpacedRepetition.calculateNextRevisionDate(
        lastRevisionDate: DateTime.now(),
        revisionCount: schedule.revisionCount + 1,
        confidenceRating: confidenceRating,
      );

      schedules[index] = schedule.copyWith(
        nextRevisionDate: nextRevisionDate,
        revisionCount: schedule.revisionCount + 1,
        lastConfidenceRating: confidenceRating,
        updatedAt: DateTime.now(),
      );
      
      await _saveSchedules(schedules);
    }
  }

  Future<void> markAsCompleted(String scheduleId) async {
    final schedules = await getAllSchedules();
    final index = schedules.indexWhere((s) => s.id == scheduleId);
    
    if (index != -1) {
      schedules[index] = schedules[index].copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
      await _saveSchedules(schedules);
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    final schedules = await getAllSchedules();
    schedules.removeWhere((schedule) => schedule.id == scheduleId);
    await _saveSchedules(schedules);
  }

  Future<int> getTotalRevisionsCount(String userId) async {
    final schedules = await getSchedulesByUserId(userId);
    return schedules.fold<int>(0, (sum, s) => sum + s.revisionCount);
  }

  Future<void> _saveSchedules(List<RevisionSchedule> schedules) async {
    final schedulesJson = schedules.map((s) => s.toJson()).toList();
    await _storage.saveData(_storageKey, jsonEncode(schedulesJson));
  }

  Future<void> initializeSampleData(String userId) async {
    final schedules = await getAllSchedules();
    if (schedules.isNotEmpty) return;

    final now = DateTime.now();
    final sampleSchedules = [
      RevisionSchedule(
        id: 'schedule_1',
        studyLogId: 'log_1',
        userId: userId,
        topic: 'Calculus - Derivatives',
        subject: 'Mathematics',
        nextRevisionDate: DateHelpers.today,
        revisionCount: 1,
        lastConfidenceRating: 4,
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      RevisionSchedule(
        id: 'schedule_2',
        studyLogId: 'log_2',
        userId: userId,
        topic: 'Quantum Mechanics Basics',
        subject: 'Physics',
        nextRevisionDate: DateHelpers.today.add(const Duration(days: 1)),
        revisionCount: 0,
        lastConfidenceRating: 3,
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      RevisionSchedule(
        id: 'schedule_3',
        studyLogId: 'log_3',
        userId: userId,
        topic: 'Object-Oriented Programming',
        subject: 'Computer Science',
        nextRevisionDate: DateHelpers.today.add(const Duration(days: 3)),
        revisionCount: 0,
        lastConfidenceRating: 5,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await _saveSchedules(sampleSchedules);
  }
}
