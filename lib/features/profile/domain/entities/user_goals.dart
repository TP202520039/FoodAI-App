class UserGoals {
  final int id;
  final String firebaseUid;
  final int dailyCaloriesGoal;
  final int dailyProteinGoal;
  final int dailyFatGoal;
  final int dailyCarbsGoal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserGoals({
    this.id = 0,
    this.firebaseUid = '',
    this.dailyCaloriesGoal = 2000,
    this.dailyProteinGoal = 100,
    this.dailyFatGoal = 65,
    this.dailyCarbsGoal = 250,
    this.createdAt,
    this.updatedAt,
  });

  UserGoals copyWith({
    int? id,
    String? firebaseUid,
    int? dailyCaloriesGoal,
    int? dailyProteinGoal,
    int? dailyFatGoal,
    int? dailyCarbsGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserGoals(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      dailyCaloriesGoal: dailyCaloriesGoal ?? this.dailyCaloriesGoal,
      dailyProteinGoal: dailyProteinGoal ?? this.dailyProteinGoal,
      dailyFatGoal: dailyFatGoal ?? this.dailyFatGoal,
      dailyCarbsGoal: dailyCarbsGoal ?? this.dailyCarbsGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
