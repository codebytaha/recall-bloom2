import 'package:flutter/material.dart';
import 'package:recall_bloom/models/revision_schedule.dart';
import 'package:recall_bloom/screens/revision_detail_screen.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/services/user_service.dart';
import 'package:recall_bloom/services/revision_schedule_service.dart';
import 'package:recall_bloom/widgets/topic_card.dart';
import 'package:recall_bloom/utils/date_helpers.dart';

class TodaysRevisionScreen extends StatefulWidget {
  const TodaysRevisionScreen({super.key});

  @override
  State<TodaysRevisionScreen> createState() => _TodaysRevisionScreenState();
}

class _TodaysRevisionScreenState extends State<TodaysRevisionScreen> {
  List<RevisionSchedule> _dueRevisions = [];
  List<RevisionSchedule> _upcomingRevisions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRevisions();
  }

  Future<void> _loadRevisions() async {
    final storage = await LocalStorageService.getInstance();
    final userService = UserService(storage);
    final revisionService = RevisionScheduleService(storage);

    final user = await userService.getCurrentUser();
    if (user == null) return;

    final dueRevisions = await revisionService.getDueRevisions(user.id);
    final upcomingRevisions = await revisionService.getUpcomingRevisions(user.id);

    upcomingRevisions.removeWhere((r) => dueRevisions.any((d) => d.id == r.id));

    setState(() {
      _dueRevisions = dueRevisions;
      _upcomingRevisions = upcomingRevisions.take(5).toList();
      _isLoading = false;
    });
  }

  void _navigateToRevisionDetail(RevisionSchedule schedule) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RevisionDetailScreen(schedule: schedule),
      ),
    );
    _loadRevisions();
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
        title: const Text('Today\'s Revisions'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRevisions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_dueRevisions.isEmpty && _upcomingRevisions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'All caught up!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No revisions due today. Keep studying to build your knowledge!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                if (_dueRevisions.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.alarm,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Due Now (${_dueRevisions.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._dueRevisions.map((revision) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TopicCard(
                      topic: revision.topic,
                      subject: revision.subject,
                      rating: revision.lastConfidenceRating,
                      subtitle: 'Revision ${revision.revisionCount + 1} • ${DateHelpers.formatRelative(revision.nextRevisionDate)}',
                      onTap: () => _navigateToRevisionDetail(revision),
                    ),
                  )),
                  const SizedBox(height: 32),
                ],
                if (_upcomingRevisions.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.schedule,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Upcoming',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._upcomingRevisions.map((revision) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TopicCard(
                      topic: revision.topic,
                      subject: revision.subject,
                      rating: revision.lastConfidenceRating,
                      subtitle: 'Revision ${revision.revisionCount + 1} • ${DateHelpers.formatRelative(revision.nextRevisionDate)}',
                      onTap: () => _navigateToRevisionDetail(revision),
                    ),
                  )),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
