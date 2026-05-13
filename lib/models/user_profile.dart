class UserProfile {
  final String name;
  final String avatarUrl;
  final double bmi;
  final int dailyGoalMl;
  final String location;

  const UserProfile({
    this.name = 'Alex Henderson',
    this.avatarUrl = '',
    this.bmi = 22.4,
    this.dailyGoalMl = 2850,
    this.location = '旧金山',
  });

  UserProfile copyWith({
    String? name,
    String? avatarUrl,
    double? bmi,
    int? dailyGoalMl,
    String? location,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bmi: bmi ?? this.bmi,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      location: location ?? this.location,
    );
  }
}
