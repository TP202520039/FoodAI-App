
import 'package:foodai/features/auth/domain/datasources/auth_custom_datasource.dart';
import 'package:foodai/features/auth/domain/entities/foodai_user.dart';
import 'package:foodai/features/auth/domain/repositories/auth_custom_repository.dart';

class AuthCustomRepositoryImpl extends AuthCustomRepository {
  final AuthCustomDataSource dataSource;

  AuthCustomRepositoryImpl({required this.dataSource});

  @override
  Future<FoodAiUser> sync(String token) async {
    return await dataSource.sync(token);
  }

}