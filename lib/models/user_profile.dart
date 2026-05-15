class UserProfile {
  final String name;
  final String avatarUrl;
  final double? height;
  final double? weight;
  final int dailyGoalMl;
  final String location;

  const UserProfile({
    this.name = '请输入姓名',
    this.avatarUrl = '',
    this.height = 180.0,
    this.weight = 70.0,
    this.dailyGoalMl = 2000,
    this.location = '旧金山',
  });

  double? get bmi {
    if (height == null || weight == null || height! <= 0 || weight! <= 0) return null;
    return double.parse((weight! / ((height! / 100) * (height! / 100))).toStringAsFixed(1));
  }

  UserProfile copyWith({
    String? name,
    String? avatarUrl,
    double? height,
    double? weight,
    bool clearHeight = false,
    bool clearWeight = false,
    int? dailyGoalMl,
    String? location,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      height: clearHeight ? null : (height ?? this.height),
      weight: clearWeight ? null : (weight ?? this.weight),
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      location: location ?? this.location,
    );
  }
}
