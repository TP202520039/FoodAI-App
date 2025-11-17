
import 'package:dio/dio.dart';
import 'package:foodai/config/config.dart';
import 'package:foodai/features/home/domain/datasources/food_detections_datasource.dart';
import 'package:foodai/features/home/domain/entities/food_detections.dart';
import 'package:foodai/features/home/domain/entities/food_item.dart';
import 'package:foodai/features/home/infrastructure/infrastructure.dart';
import 'package:foodai/shared/infrastructure/services/key_value_storage_service.dart';

class FoodDetectionsDataSourceImpl extends FoodDetectionsDataSource {

  final Dio dio;
  final KeyValueStorageService storageService;

  FoodDetectionsDataSourceImpl({
    required this.storageService,
    Dio? dio,
  }) : dio = dio ??
            Dio(BaseOptions(
              baseUrl: Environment.apiUrl,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));


  @override
  Future<List<FoodDetections>> getFoodDetectionsByDate(String date) async {

      try {
        final token = await storageService.getValue<String>('token');

        final response = await dio.get(
          '/food-detections/group-by-category',
          queryParameters: {'date': date},
          options: Options(headers: {'Authorization': 'Bearer $token'}),);
        
        return (response.data as List)
            .map((e) => FoodDetectionsMapper.fromJson(e))
            .toList();

      } on DioException catch (e) {
      throw Exception(
          'Error fetching food detections: ${e.message}');
    }
    
  }

  @override
  Future<FoodItem> updateFoodItemComponents(FoodItem updatedFoodItem) async {
    try {
        final token = await storageService.getValue<String>('token');

        final components = updatedFoodItem.components
            ?.map((component) => {
                  'id': component.id,
                  'quantityGrams': component.quantityGrams
                })
            .toList();

        final data = {
          "foodName": updatedFoodItem.foodName,
          "category": updatedFoodItem.category,
          "detectionDate": updatedFoodItem.detectionDate,
          "components": components
        };

        final response = await dio.put(
          '/food-detections/${updatedFoodItem.id}',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}),);
        
        return FoodItemMapper.fromJson(response.data);

      } on DioException catch (e) {
      throw Exception(
          'Error fetching food detections: ${e.message}');
    }
  }
  
  @override
  Future<FoodItem> analyzeFoodImage(String imagePath, String category, String detectionDate) async {
        try {
        final token = await storageService.getValue<String>('token');

        // Convertir la imagen a MultipartFile
        final imageMultipart = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last
        );

        final formData = FormData.fromMap({
          'image': imageMultipart,
          'category': category,
          'detectionDate': detectionDate,
        });

        final response = await dio.post(
          '/food-detections/analyze',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'multipart/form-data',
            }
          ),
        );

        return FoodItemMapper.fromJson(response.data);
      } on DioException catch (e) {
      throw Exception(
          'Error analyzing food image: ${e.message}');
    }
  }

}
