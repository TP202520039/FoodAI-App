import 'package:foodai/features/home/domain/entities/component.dart';
import 'package:foodai/features/home/domain/entities/totals.dart';

class FoodItem {
  int? id;
  String? foodName;
  String? imageUrl;
  String? category;
  String? detectionDate;
  List<Component>? components;
  Totals? totals;
  String? createdAt;
  String? updatedAt;

  FoodItem({
    this.id,
    this.foodName,
    this.imageUrl,
    this.category,
    this.detectionDate,
    this.components,
    this.totals,
    this.createdAt,
    this.updatedAt,
  });
}
