import 'package:flutter/material.dart';
import 'package:recall_bloom/models/revision_schedule.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/services/revision_schedule_service.dart';
import 'package:recall_bloom/widgets/rating_selector.dart';
import 'package:recall_bloom/widgets/subject_chip.dart';
import 'package:recall_bloom/utils/date_helpers.dart';

class RevisionDetailScreen extends StatefulWidget {
  final RevisionSchedule schedule;

  const RevisionDetailScreen({super.key, required this.schedule});

  @override
  State<RevisionDetailScreen> createState() => _RevisionDetailScreenState();
}

class _RevisionDetailScreenState extends State<RevisionDetailScreen> {
  int _confidenceRating = 3;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _confidenceRating = widget.schedule.lastConfidenceRating;
  }

  Future<void> _completeRevision() async {
    setState(() => _isSaving = true);

    final storage = await LocalStorageService.getInstance();
    final revisionService = RevisionScheduleService(storage);

    await revisionService.completeRevision(widget.schedule.id, _confidenceRating);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revision complete! Next review scheduled.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Topic'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubjectChip(subject: widget.schedule.subject),
                  const SizedBox(height: 16),
                  Text(
                    widget.schedule.topic,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _InfoRow(
              icon: Icons.repeat,
              label: 'Revision Number',
              value: '#${widget.schedule.revisionCount + 1}',
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Scheduled For',
              value: DateHelpers.formatDate(widget.schedule.nextRevisionDate),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.star,
              label: 'Last Rating',
              value: '${widget.schedule.lastConfidenceRating}/5',
            ),
            const SizedBox(height: 40),
            Text(
              'Review Tips',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _TipCard(
              icon: Icons.lightbulb_outline,
              text: 'Try to recall key concepts without looking at your notes first',
            ),
            const SizedBox(height: 12),
            _TipCard(
              icon: Icons.question_answer_outlined,
              text: 'Ask yourself questions about the topic and answer them',
            ),
            const SizedBox(height: 12),
            _TipCard(
              icon: Icons.note_outlined,
              text: 'Write a brief summary from memory to test your understanding',
            ),
            const SizedBox(height: 40),
            RatingSelector(
              rating: _confidenceRating,
              onRatingChanged: (rating) => setState(() => _confidenceRating = rating),
              label: 'How confident are you now?',
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _completeRevision,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Complete Revision',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.tertiary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
