import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'StudyFlow';
  
  static const List<String> defaultSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'History',
    'Literature',
    'Languages',
    'Economics',
    'Psychology',
  ];
  
  static const List<int> spacedRepetitionIntervals = [1, 3, 7, 14, 30];
  
  static const int defaultDailyGoalMinutes = 60;
  static const int defaultStudyMinutes = 25;
  static const int defaultBreakMinutes = 5;
  static const int maxDailyReminders = 5;
  
  static const Map<String, Color> subjectColors = {
    'Mathematics': Color(0xFF684F8E),
    'Physics': Color(0xFF00BFA5),
    'Chemistry': Color(0xFFFF6B9D),
    'Biology': Color(0xFF4CAF50),
    'Computer Science': Color(0xFF2196F3),
    'History': Color(0xFFFFA726),
    'Literature': Color(0xFF9C27B0),
    'Languages': Color(0xFFE91E63),
    'Economics': Color(0xFF795548),
    'Psychology': Color(0xFF009688),
  };
  
  static Color getSubjectColor(String subject) =>
      subjectColors[subject] ?? const Color(0xFF684F8E);
}
