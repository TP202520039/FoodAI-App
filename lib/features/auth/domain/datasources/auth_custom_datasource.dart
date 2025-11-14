
import 'package:foodai/features/auth/domain/entities/foodai_user.dart';

abstract class AuthCustomDataSource {
  Future<FoodAiUser> sync(String token);
}