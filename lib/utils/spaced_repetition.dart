import 'package:recall_bloom/utils/constants.dart';
import 'package:recall_bloom/utils/date_helpers.dart';

class SpacedRepetition {
  static DateTime calculateNextRevisionDate({
    required DateTime lastRevisionDate,
    required int revisionCount,
    required int confidenceRating,
  }) {
    final intervals = AppConstants.spacedRepetitionIntervals;
    int intervalIndex = revisionCount.clamp(0, intervals.length - 1);
    int baseDays = intervals[intervalIndex];
    
    if (confidenceRating <= 2) {
      baseDays = 1;
    } else if (confidenceRating >= 4) {
      baseDays += 3;
    }
    
    return DateHelpers.addDays(lastRevisionDate, baseDays);
  }
  
  static bool isDueForRevision(DateTime revisionDate) =>
      revisionDate.isBefore(DateHelpers.today.add(const Duration(days: 1)));
  
  static int getDaysUntilRevision(DateTime revisionDate) =>
      DateHelpers.daysBetween(DateHelpers.today, revisionDate);
}
