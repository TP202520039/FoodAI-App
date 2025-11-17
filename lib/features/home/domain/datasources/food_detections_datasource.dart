import 'package:foodai/features/home/domain/domain.dart';

abstract class FoodDetectionsDataSource {
  Future<List<FoodDetections>> getFoodDetectionsByDate(String date); // date in 'YYYY-MM-DD' format
  Future<FoodItem> updateFoodItemComponents(FoodItem updatedFoodItem);
  Future<FoodItem> analyzeFoodImage(String imagePath, String category, String detectionDate);
}