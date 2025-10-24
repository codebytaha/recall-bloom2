import 'package:flutter/material.dart';
import 'package:recall_bloom/models/user.dart';
import 'package:recall_bloom/models/study_streak.dart';
import 'package:recall_bloom/models/study_log.dart';
import 'package:recall_bloom/models/revision_schedule.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/services/user_service.dart';
import 'package:recall_bloom/services/streak_service.dart';
import 'package:recall_bloom/services/study_log_service.dart';
import 'package:recall_bloom/services/revision_schedule_service.dart';
import 'package:recall_bloom/widgets/streak_card.dart';
import 'package:recall_bloom/widgets/topic_card.dart';
import 'package:recall_bloom/utils/date_helpers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? _user;
  StudyStreak? _streak;
  List<StudyLog> _recentLogs = [];
  List<RevisionSchedule> _dueRevisions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = await LocalStorageService.getInstance();
    final userService = UserService(storage);
    final streakService = StreakService(storage);
    final studyLogService = StudyLogService(storage);
    final revisionService = RevisionScheduleService(storage);

    final user = await userService.getCurrentUser();
    if (user == null) return;

    await studyLogService.initializeSampleData(user.id);
    await revisionService.initializeSampleData(user.id);
    await streakService.initializeSampleData(user.id);

    final streak = await streakService.getStreak(user.id);
    final logs = await studyLogService.getLogsByUserId(user.id);
    final revisions = await revisionService.getDueRevisions(user.id);

    logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _user = user;
      _streak = streak;
      _recentLogs = logs.take(5).toList();
      _dueRevisions = revisions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${_user?.name ?? "User"}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              DateHelpers.formatDate(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_streak != null) ...[
                StreakCard(
                  currentStreak: _streak!.currentStreak,
                  longestStreak: _streak!.longestStreak,
                ),
                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Topics Studied',
                      value: '${_recentLogs.length}',
                      icon: Icons.school,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Due Revisions',
                      value: '${_dueRevisions.length}',
                      icon: Icons.repeat,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_recentLogs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No study logs yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._recentLogs.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TopicCard(
                    topic: log.topic,
                    subject: log.subject,
                    rating: log.understandingRating,
                    subtitle: '${log.timeSpentMinutes} min • ${DateHelpers.formatRelative(log.createdAt)}',
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
