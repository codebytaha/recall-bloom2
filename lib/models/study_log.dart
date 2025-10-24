class StudyLog {
  final String id;
  final String userId;
  final String topic;
  final String subject;
  final int timeSpentMinutes;
  final int understandingRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyLog({
    required this.id,
    required this.userId,
    required this.topic,
    required this.subject,
    required this.timeSpentMinutes,
    required this.understandingRating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyLog.fromJson(Map<String, dynamic> json) => StudyLog(
    id: json['id'] as String,
    userId: json['userId'] as String,
    topic: json['topic'] as String,
    subject: json['subject'] as String,
    timeSpentMinutes: json['timeSpentMinutes'] as int,
    understandingRating: json['understandingRating'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'topic': topic,
    'subject': subject,
    'timeSpentMinutes': timeSpentMinutes,
    'understandingRating': understandingRating,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  StudyLog copyWith({
    String? id,
    String? userId,
    String? topic,
    String? subject,
    int? timeSpentMinutes,
    int? understandingRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StudyLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    topic: topic ?? this.topic,
    subject: subject ?? this.subject,
    timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
    understandingRating: understandingRating ?? this.understandingRating,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
