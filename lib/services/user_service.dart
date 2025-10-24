import 'dart:convert';
import 'package:recall_bloom/models/user.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/utils/constants.dart';

class UserService {
  static const String _storageKey = 'current_user';
  static const String _onboardingKey = 'has_completed_onboarding';
  final LocalStorageService _storage;

  UserService(this._storage);

  Future<User?> getCurrentUser() async {
    final userData = _storage.getString(_storageKey);
    if (userData == null) return null;
    return User.fromJson(jsonDecode(userData));
  }

  Future<void> saveUser(User user) async {
    await _storage.saveData(_storageKey, jsonEncode(user.toJson()));
  }

  Future<void> createUser({
    required String name,
    required String email,
    required int dailyGoalMinutes,
    required List<String> subjects,
  }) async {
    final now = DateTime.now();
    final user = User(
      id: 'user_${now.millisecondsSinceEpoch}',
      name: name,
      email: email,
      dailyGoalMinutes: dailyGoalMinutes,
      subjects: subjects,
      createdAt: now,
      updatedAt: now,
    );
    await saveUser(user);
    await _storage.saveData(_onboardingKey, true);
  }

  Future<void> updateUser(User user) async {
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    await saveUser(updatedUser);
  }

  Future<bool> hasCompletedOnboarding() async =>
      _storage.getBool(_onboardingKey) ?? false;

  Future<void> clearUser() async {
    await _storage.remove(_storageKey);
    await _storage.remove(_onboardingKey);
  }

  Future<void> initializeSampleUser() async {
    if (await hasCompletedOnboarding()) return;
    
    await createUser(
      name: 'Demo User',
      email: 'demo@studyflow.app',
      dailyGoalMinutes: AppConstants.defaultDailyGoalMinutes,
      subjects: AppConstants.defaultSubjects.take(5).toList(),
    );
  }
}
