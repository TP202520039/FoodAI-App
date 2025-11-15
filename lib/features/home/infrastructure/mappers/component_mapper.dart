import 'package:foodai/features/home/domain/entities/component.dart';
import 'package:foodai/features/home/infrastructure/mappers/nutritional_info_mapper.dart';

class ComponentMapper {
  static Component fromJson(Map<String, dynamic> json) {
    return Component(
      id: (json['id'] as num?)?.toInt(),
      foodName: json['foodName'] as String?,
      quantityGrams: (json['quantityGrams'] as num?)?.toInt(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      nutritionalInfo: json['nutritionalInfo'] != null
          ? NutritionalInfoMapper.fromJson(json['nutritionalInfo'])
          : null,
      nutritionalDataFound: json['nutritionalDataFound'] as bool?,
    );
  }

  static Map<String, dynamic> toJson(Component component) {
    return {
      'id': component.id,
      'foodName': component.foodName,
      'quantityGrams': component.quantityGrams,
      'confidenceScore': component.confidenceScore,
      'nutritionalInfo': component.nutritionalInfo != null
          ? NutritionalInfoMapper.toJson(component.nutritionalInfo!)
          : null,
      'nutritionalDataFound': component.nutritionalDataFound,
    };
  }
}
