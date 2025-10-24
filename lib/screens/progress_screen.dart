import 'package:flutter/material.dart';
import 'package:recall_bloom/models/study_log.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/services/user_service.dart';
import 'package:recall_bloom/services/study_log_service.dart';
import 'package:recall_bloom/services/revision_schedule_service.dart';
import 'package:recall_bloom/widgets/progress_chart.dart';
import 'package:recall_bloom/utils/date_helpers.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _totalStudyMinutes = 0;
  double _averageUnderstanding = 0.0;
  int _totalRevisions = 0;
  Map<String, int> _weeklyData = {};
  Map<String, int> _subjectData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final storage = await LocalStorageService.getInstance();
    final userService = UserService(storage);
    final studyLogService = StudyLogService(storage);
    final revisionService = RevisionScheduleService(storage);

    final user = await userService.getCurrentUser();
    if (user == null) return;

    final totalMinutes = await studyLogService.getTotalStudyMinutes(user.id);
    final avgUnderstanding = await studyLogService.getAverageUnderstanding(user.id);
    final totalRevisions = await revisionService.getTotalRevisionsCount(user.id);
    final subjectCounts = await studyLogService.getStudyCountBySubject(user.id);

    final weeklyData = await _getWeeklyData(studyLogService, user.id);

    setState(() {
      _totalStudyMinutes = totalMinutes;
      _averageUnderstanding = avgUnderstanding;
      _totalRevisions = totalRevisions;
      _weeklyData = weeklyData;
      _subjectData = subjectCounts;
      _isLoading = false;
    });
  }

  Future<Map<String, int>> _getWeeklyData(StudyLogService service, String userId) async {
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final logs = await service.getLogsByUserId(userId);

    final Map<String, int> data = {};
    for (var day in weekDays) {
      final dayLogs = logs.where((log) => DateHelpers.isSameDay(log.createdAt, day)).toList();
      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1];
      data[dayName] = dayLogs.length;
    }
    return data;
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
        title: const Text('Your Progress'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Study Time',
                      value: '${(_totalStudyMinutes / 60).toStringAsFixed(1)}h',
                      icon: Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: 'Avg Understanding',
                      value: _averageUnderstanding.toStringAsFixed(1),
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MetricCard(
                title: 'Total Revisions Completed',
                value: '$_totalRevisions',
                icon: Icons.repeat,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 32),
              Text(
                'Weekly Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                child: _weeklyData.isEmpty
                    ? const Center(child: Text('No data available'))
                    : ProgressChart(weeklyData: _weeklyData),
              ),
              const SizedBox(height: 32),
              Text(
                'Study by Subject',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_subjectData.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No subject data yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              else
                ..._subjectData.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SubjectProgressBar(
                    subject: entry.key,
                    count: entry.value,
                    maxCount: _subjectData.values.reduce((a, b) => a > b ? a : b),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
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

class _SubjectProgressBar extends StatelessWidget {
  final String subject;
  final int count;
  final int maxCount;

  const _SubjectProgressBar({
    required this.subject,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxCount > 0 ? count / maxCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count ${count == 1 ? "session" : "sessions"}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
