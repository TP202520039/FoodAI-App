import 'package:foodai/features/home/domain/entities/food_detections.dart';
import 'package:foodai/features/home/infrastructure/mappers/food_item_mapper.dart';

class FoodDetectionsMapper {
  static FoodDetections fromJson(Map<String, dynamic> json) {
    return FoodDetections(
      category: json['category'] as String?,
      count: (json['count'] as num?)?.toInt(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((v) => FoodItemMapper.fromJson(v))
              .toList()
          : null,
    );
  }

  static Map<String, dynamic> toJson(FoodDetections foodDetections) {
    return {
      'category': foodDetections.category,
      'count': foodDetections.count,
      'items': foodDetections.items != null
          ? foodDetections.items!.map((v) => FoodItemMapper.toJson(v)).toList()
          : null,
    };
  }
}
