class RevisionSchedule {
  final String id;
  final String studyLogId;
  final String userId;
  final String topic;
  final String subject;
  final DateTime nextRevisionDate;
  final int revisionCount;
  final int lastConfidenceRating;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  RevisionSchedule({
    required this.id,
    required this.studyLogId,
    required this.userId,
    required this.topic,
    required this.subject,
    required this.nextRevisionDate,
    required this.revisionCount,
    required this.lastConfidenceRating,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RevisionSchedule.fromJson(Map<String, dynamic> json) => RevisionSchedule(
    id: json['id'] as String,
    studyLogId: json['studyLogId'] as String,
    userId: json['userId'] as String,
    topic: json['topic'] as String,
    subject: json['subject'] as String,
    nextRevisionDate: DateTime.parse(json['nextRevisionDate'] as String),
    revisionCount: json['revisionCount'] as int,
    lastConfidenceRating: json['lastConfidenceRating'] as int,
    isCompleted: json['isCompleted'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'studyLogId': studyLogId,
    'userId': userId,
    'topic': topic,
    'subject': subject,
    'nextRevisionDate': nextRevisionDate.toIso8601String(),
    'revisionCount': revisionCount,
    'lastConfidenceRating': lastConfidenceRating,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  RevisionSchedule copyWith({
    String? id,
    String? studyLogId,
    String? userId,
    String? topic,
    String? subject,
    DateTime? nextRevisionDate,
    int? revisionCount,
    int? lastConfidenceRating,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RevisionSchedule(
    id: id ?? this.id,
    studyLogId: studyLogId ?? this.studyLogId,
    userId: userId ?? this.userId,
    topic: topic ?? this.topic,
    subject: subject ?? this.subject,
    nextRevisionDate: nextRevisionDate ?? this.nextRevisionDate,
    revisionCount: revisionCount ?? this.revisionCount,
    lastConfidenceRating: lastConfidenceRating ?? this.lastConfidenceRating,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
