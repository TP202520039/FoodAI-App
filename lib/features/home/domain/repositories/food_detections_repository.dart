import 'package:foodai/features/home/domain/entities/food_detections.dart';
import 'package:foodai/features/home/domain/entities/food_item.dart';

abstract class FoodDetectionsRepository {
  Future<List<FoodDetections>>  getFoodDetectionsByDate(String date); // date in 'YYYY-MM-DD' format
    Future<FoodItem> updateFoodItemComponents(FoodItem updatedFoodItem);
}