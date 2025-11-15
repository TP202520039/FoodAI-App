import 'package:foodai/features/home/domain/entities/food_detections.dart';

abstract class FoodDetectionsRepository {
  Future<List<FoodDetections>>  getFoodDetectionsByDate(String date); // date in 'YYYY-MM-DD' format
}