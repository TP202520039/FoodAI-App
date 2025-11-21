

import 'package:foodai/features/auth/domain/entities/foodai_user.dart';

class FoodaiUserMapper {
    static FoodAiUser fromJson(Map<String, dynamic> json) {
    return FoodAiUser(
      id: json['id'] as int,
      firebaseUid: json['firebaseUid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      provider: json['provider'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  static Map<String, dynamic> toJson(FoodAiUser userProfil) {
    return {
      'id': userProfil.id,
      'firebaseUid': userProfil.firebaseUid,
      'email': userProfil.email,
      'displayName': userProfil.displayName,
      'photoUrl': userProfil.photoUrl,
      'provider': userProfil.provider,
      'isActive': userProfil.isActive,
    };
  }
}