import 'package:flutter/material.dart';
import 'package:recall_bloom/utils/constants.dart';

class SubjectChip extends StatelessWidget {
  final String subject;

  const SubjectChip({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.getSubjectColor(subject);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        subject,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
