# StudyFlow MVP - Architecture Plan

## Overview
StudyFlow helps users build consistent study habits through daily logging and spaced repetition reminders. This MVP focuses on core functionality: study logging, smart revision scheduling, progress tracking, and basic focus timer.

## Core Features
1. **Study Logging** - Log topics with subject tags, time spent, and understanding ratings (1-5)
2. **Spaced Repetition Scheduler** - Rule-based revision reminders (Day 1→3→7→14→30)
3. **Revision Reminders** - Daily revision list with confidence re-rating
4. **Progress Dashboard** - Streaks, topics studied, recall scores, completion rates
5. **Focus Timer** - Basic Pomodoro-style timer (25min study / 5min break)

## Technical Architecture

### Data Models (lib/models/)
1. **User** - id, name, email, daily_goal_minutes, subjects[], created_at, updated_at
2. **StudyLog** - id, user_id, topic, subject, time_spent_minutes, understanding_rating, created_at, updated_at
3. **RevisionSchedule** - id, study_log_id, user_id, topic, subject, next_revision_date, revision_count, last_confidence_rating, is_completed, created_at, updated_at
4. **StudyStreak** - id, user_id, current_streak, longest_streak, last_study_date, created_at, updated_at

### Services (lib/services/)
1. **UserService** - Manage user profile, subjects, daily goals
2. **StudyLogService** - CRUD operations for study logs, calculate statistics
3. **RevisionScheduleService** - Schedule revisions, update intervals based on confidence, get due revisions
4. **StreakService** - Track daily streaks, update on study log creation
5. **LocalStorageService** - Handle shared_preferences for local data persistence
6. **NotificationService** - Local push notifications for revision reminders

### UI Structure (lib/screens/)
1. **OnboardingScreen** - Collect name, subjects, daily goal
2. **HomeScreen** - Bottom navigation hub (Dashboard, Today's Revision, Add Log, Progress, Timer)
3. **DashboardScreen** - Overview cards: streak, topics studied, due revisions, recent activity
4. **TodaysRevisionScreen** - List of topics due today with swipe actions to mark complete
5. **AddStudyLogScreen** - Form to log new study session
6. **ProgressScreen** - Charts and stats: weekly logs, average understanding, subject breakdown
7. **FocusTimerScreen** - Pomodoro timer with study/break cycles
8. **RevisionDetailScreen** - Review topic, rate confidence, mark complete

### Widgets (lib/widgets/)
1. **StreakCard** - Display current/longest streak with fire icon
2. **TopicCard** - Display topic with subject tag, understanding rating
3. **RatingSelector** - Interactive 1-5 star rating widget
4. **SubjectChip** - Colored chip for subject tags
5. **ProgressChart** - Simple bar chart for weekly activity
6. **TimerDisplay** - Circular countdown display

### Utilities (lib/utils/)
1. **date_helpers.dart** - Date formatting, comparison utilities
2. **spaced_repetition.dart** - Calculate next revision date based on confidence
3. **constants.dart** - App constants (colors, intervals, default subjects)

### Storage Strategy
- **Local Storage** using shared_preferences
- Store as JSON serialized data with collection-like structure
- Sample data preloaded for demonstration

### Spaced Repetition Logic
```
Base intervals: [1, 3, 7, 14, 30] days
Confidence adjustment:
- Rating 1-2 (weak): Reset to day 1
- Rating 3 (medium): Same interval
- Rating 4-5 (strong): +3 days to current interval
```

### Color Palette (Elegant & Modern)
- Primary: Deep Indigo (#684F8E)
- Secondary: Soft Coral (#FF6B9D)
- Accent: Vibrant Teal (#00BFA5)
- Background: Off-white (#FAFAFA) / Dark Navy (#121212)
- Success: Fresh Green (#4CAF50)
- Warning: Warm Amber (#FFA726)

## Implementation Steps

### Phase 1: Foundation & Data Layer
1. Create all data models with toJson/fromJson/copyWith methods
2. Implement LocalStorageService with generic CRUD operations
3. Build UserService with sample data
4. Build StudyLogService with sample data
5. Build RevisionScheduleService with spaced repetition logic
6. Build StreakService with date tracking logic
7. Create spaced_repetition utility for interval calculations
8. Create date_helpers utility

### Phase 2: Core Screens & Navigation
9. Create OnboardingScreen with subject selection
10. Create HomeScreen with bottom navigation (5 tabs)
11. Create DashboardScreen with overview cards
12. Create TodaysRevisionScreen with revision list
13. Implement navigation flow and state management

### Phase 3: Study Logging & Revision
14. Create AddStudyLogScreen with form validation
15. Build RatingSelector and SubjectChip widgets
16. Create TopicCard and StreakCard widgets
17. Create RevisionDetailScreen for reviewing topics
18. Wire up services to create logs and schedule revisions
19. Update streak on new study logs

### Phase 4: Progress & Timer
20. Create ProgressScreen with statistics
21. Build ProgressChart widget for weekly activity
22. Create FocusTimerScreen with countdown
23. Build TimerDisplay widget with circular progress
24. Implement timer state management

### Phase 5: Notifications & Polish
25. Implement NotificationService for local notifications
26. Schedule daily revision reminders at preferred time
27. Update theme colors for modern, elegant look
28. Add generous spacing and refined typography
29. Implement swipe actions and micro-interactions

### Phase 6: Testing & Debugging
30. Run compile_project to check for errors
31. Fix any dart analyzer errors
32. Test full user flow from onboarding to revision
33. Verify data persistence across app restarts

## File Structure
```
lib/
├── main.dart
├── theme.dart
├── models/
│   ├── user.dart
│   ├── study_log.dart
│   ├── revision_schedule.dart
│   └── study_streak.dart
├── services/
│   ├── local_storage_service.dart
│   ├── user_service.dart
│   ├── study_log_service.dart
│   ├── revision_schedule_service.dart
│   ├── streak_service.dart
│   └── notification_service.dart
├── screens/
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── todays_revision_screen.dart
│   ├── add_study_log_screen.dart
│   ├── progress_screen.dart
│   ├── focus_timer_screen.dart
│   └── revision_detail_screen.dart
├── widgets/
│   ├── streak_card.dart
│   ├── topic_card.dart
│   ├── rating_selector.dart
│   ├── subject_chip.dart
│   ├── progress_chart.dart
│   └── timer_display.dart
└── utils/
    ├── date_helpers.dart
    ├── spaced_repetition.dart
    └── constants.dart
```

## Dependencies
- shared_preferences: Local data storage
- fl_chart: Charts for progress visualization
- flutter_local_notifications: Local push notifications
- intl: Date formatting

## Success Criteria
- User can complete full onboarding flow
- Study logs are persisted and displayed correctly
- Revision reminders appear on correct dates
- Streak counter updates accurately
- Focus timer functions properly
- All screens are responsive and elegant
- No dart analyzer errors
