class StudyStreak {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastStudyDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyStreak({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastStudyDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyStreak.fromJson(Map<String, dynamic> json) => StudyStreak(
    id: json['id'] as String,
    userId: json['userId'] as String,
    currentStreak: json['currentStreak'] as int,
    longestStreak: json['longestStreak'] as int,
    lastStudyDate: DateTime.parse(json['lastStudyDate'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastStudyDate': lastStudyDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  StudyStreak copyWith({
    String? id,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StudyStreak(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
