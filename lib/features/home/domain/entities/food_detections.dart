import 'package:foodai/features/home/domain/entities/food_item.dart';

class FoodDetections {
  String? category;
  int? count;
  List<FoodItem>? items;

  FoodDetections({
    this.category,
    this.count,
    this.items,
  });
}
