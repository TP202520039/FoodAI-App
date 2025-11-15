import 'package:foodai/features/home/domain/entities/nutritional_info.dart';

class NutritionalInfoMapper {
  static NutritionalInfo fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(
      calories: (json['calories'] as num?)?.toInt(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      iron: (json['iron'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toInt(),
      vitaminC: (json['vitaminC'] as num?)?.toDouble(),
      zinc: (json['zinc'] as num?)?.toDouble(),
      potassium: (json['potassium'] as num?)?.toInt(),
      folicAcid: (json['folicAcid'] as num?)?.toInt(),
    );
  }

  static Map<String, dynamic> toJson(NutritionalInfo nutritionalInfo) {
    return {
      'calories': nutritionalInfo.calories,
      'protein': nutritionalInfo.protein,
      'fat': nutritionalInfo.fat,
      'carbs': nutritionalInfo.carbs,
      'fiber': nutritionalInfo.fiber,
      'iron': nutritionalInfo.iron,
      'calcium': nutritionalInfo.calcium,
      'vitaminC': nutritionalInfo.vitaminC,
      'zinc': nutritionalInfo.zinc,
      'potassium': nutritionalInfo.potassium,
      'folicAcid': nutritionalInfo.folicAcid,
    };
  }
}
