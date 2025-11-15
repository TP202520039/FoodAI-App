import 'package:foodai/features/home/domain/entities/food_item.dart';
import 'package:foodai/features/home/infrastructure/mappers/component_mapper.dart';
import 'package:foodai/features/home/infrastructure/mappers/totals_mapper.dart';

class FoodItemMapper {
  static FoodItem fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: (json['id'] as num?)?.toInt(),
      foodName: json['foodName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      detectionDate: json['detectionDate'] as String?,
      components: json['components'] != null
          ? (json['components'] as List)
              .map((v) => ComponentMapper.fromJson(v))
              .toList()
          : null,
      totals: json['totals'] != null
          ? TotalsMapper.fromJson(json['totals'])
          : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  static Map<String, dynamic> toJson(FoodItem item) {
    return {
      'id': item.id,
      'foodName': item.foodName,
      'imageUrl': item.imageUrl,
      'category': item.category,
      'detectionDate': item.detectionDate,
      'components': item.components != null
          ? item.components!.map((v) => ComponentMapper.toJson(v)).toList()
          : null,
      'totals': item.totals != null ? TotalsMapper.toJson(item.totals!) : null,
      'createdAt': item.createdAt,
      'updatedAt': item.updatedAt,
    };
  }
}
