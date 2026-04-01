import 'package:foodai/features/profile/domain/entities/user_goals.dart';

class UserGoalsMapper {
  static UserGoals fromJson(Map<String, dynamic> json) {
    return UserGoals(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firebaseUid: json['firebaseUid'] as String? ?? '',
      dailyCaloriesGoal: (json['dailyCaloriesGoal'] as num?)?.toInt() ?? 2000,
      dailyProteinGoal: (json['dailyProteinGoal'] as num?)?.toInt() ?? 100,
      dailyFatGoal: (json['dailyFatGoal'] as num?)?.toInt() ?? 65,
      dailyCarbsGoal: (json['dailyCarbsGoal'] as num?)?.toInt() ?? 250,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toJson(UserGoals userGoals) {
    return <String, dynamic>{
      'dailyCaloriesGoal': userGoals.dailyCaloriesGoal,
      'dailyProteinGoal': userGoals.dailyProteinGoal,
      'dailyFatGoal': userGoals.dailyFatGoal,
      'dailyCarbsGoal': userGoals.dailyCarbsGoal,
    };
  }
}
