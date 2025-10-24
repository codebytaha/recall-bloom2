class User {
  final String id;
  final String name;
  final String email;
  final int dailyGoalMinutes;
  final List<String> subjects;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.dailyGoalMinutes,
    required this.subjects,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    dailyGoalMinutes: json['dailyGoalMinutes'] as int,
    subjects: List<String>.from(json['subjects'] as List),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'dailyGoalMinutes': dailyGoalMinutes,
    'subjects': subjects,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? dailyGoalMinutes,
    List<String>? subjects,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    subjects: subjects ?? this.subjects,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
