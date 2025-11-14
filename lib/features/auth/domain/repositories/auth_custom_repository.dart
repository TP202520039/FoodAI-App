
import 'package:foodai/features/auth/domain/entities/foodai_user.dart';

abstract class AuthCustomRepository {
  Future<FoodAiUser> sync(String token);
}