import 'package:foodai/features/profile/domain/datasources/goals_datasource.dart';
import 'package:foodai/features/profile/domain/entities/user_goals.dart';
import 'package:foodai/features/profile/domain/repositories/goals_repository.dart';

class GoalsRepositoryImpl extends GoalsRepository {
  GoalsRepositoryImpl({required this.dataSource});

  final GoalsDataSource dataSource;

  @override
  Future<UserGoals> getGoals() async {
    return dataSource.getGoals();
  }

  @override
  Future<UserGoals> updateGoals(UserGoals goals) async {
    return dataSource.updateGoals(goals);
  }
}
