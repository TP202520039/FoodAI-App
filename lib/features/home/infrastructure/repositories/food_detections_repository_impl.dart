
import 'package:foodai/features/home/domain/datasources/food_detections_datasource.dart';
import 'package:foodai/features/home/domain/entities/food_detections.dart';
import 'package:foodai/features/home/domain/entities/food_item.dart';
import 'package:foodai/features/home/domain/repositories/food_detections_repository.dart';

class FoodDetectionsRepositoryImpl extends FoodDetectionsRepository {
  final FoodDetectionsDataSource dataSource;

  FoodDetectionsRepositoryImpl({required this.dataSource});

  @override
  Future<List<FoodDetections>> getFoodDetectionsByDate(String date) async {
    return await dataSource.getFoodDetectionsByDate(date);
  }

  @override
  Future<FoodItem> updateFoodItemComponents(FoodItem updatedFoodItem) {
    return dataSource.updateFoodItemComponents(updatedFoodItem);
  }
}