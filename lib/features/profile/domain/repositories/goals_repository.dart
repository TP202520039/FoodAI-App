import 'package:foodai/features/profile/domain/entities/user_goals.dart';

abstract class GoalsRepository {
  Future<UserGoals> getGoals();

  Future<UserGoals> updateGoals(UserGoals goals);
}
