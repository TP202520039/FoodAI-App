import 'package:firebase_auth/firebase_auth.dart';
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

  FoodDetectionsDataSourceImpl({required this.storageService, Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Environment.apiUrl,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

  @override
  Future<List<FoodDetections>> getFoodDetectionsByDate(String date) async {
    try {
      final Response<dynamic> response = await _executeAuthenticatedRequest(
        (String token) => dio.get(
          '/food-detections/group-by-category',
          queryParameters: {'date': date},
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
      );

      return (response.data as List)
          .map((e) => FoodDetectionsMapper.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error fetching food detections: ${e.message}');
    }
  }

  @override
  Future<FoodItem> updateFoodItemComponents(FoodItem updatedFoodItem) async {
    try {
      final components = updatedFoodItem.components
          ?.map(
            (component) => {
              'id': component.id,
              'quantityGrams': component.quantityGrams,
            },
          )
          .toList();

      final data = {
        'foodName': updatedFoodItem.foodName,
        'category': updatedFoodItem.category,
        'detectionDate': updatedFoodItem.detectionDate,
        'components': components,
      };

      final Response<dynamic> response = await _executeAuthenticatedRequest(
        (String token) => dio.put(
          '/food-detections/${updatedFoodItem.id}',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
      );

      return FoodItemMapper.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error fetching food detections: ${e.message}');
    }
  }

  @override
  Future<FoodItem> analyzeFoodImage(
    String imagePath,
    String category,
    String detectionDate,
  ) async {
    try {
      final imageMultipart = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );

      final formData = FormData.fromMap({
        'image': imageMultipart,
        'category': category,
        'detectionDate': detectionDate,
      });

      final Response<dynamic> response = await _executeAuthenticatedRequest(
        (String token) => dio.post(
          '/food-detections/analyze',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'multipart/form-data',
            },
          ),
        ),
      );

      return FoodItemMapper.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error analyzing food image: ${e.message}');
    }
  }

  @override
  Future<void> deleteFoodDetection(int foodDetectionId) async {
    try {
      await _executeAuthenticatedRequest(
        (String token) => dio.delete(
          '/food-detections/$foodDetectionId',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
      );
    } on DioException catch (e) {
      throw Exception('Error deleting food detection: ${e.message}');
    }
  }

  Future<Response<dynamic>> _executeAuthenticatedRequest(
    Future<Response<dynamic>> Function(String token) request,
  ) async {
    final String token = await _getStoredToken();

    try {
      return await request(token);
    } on DioException catch (e) {
      if (!_shouldRefreshToken(e)) {
        rethrow;
      }

      final String refreshedToken = await _refreshToken();
      return request(refreshedToken);
    }
  }

  Future<String> _getStoredToken() async {
    final String? token = await storageService.getValue<String>('token');

    if (token == null || token.isEmpty) {
      return _refreshToken();
    }

    return token;
  }

  bool _shouldRefreshToken(DioException exception) {
    final int? statusCode = exception.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

  Future<String> _refreshToken() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No active session');
    }

    final String? refreshedToken = await user.getIdToken(true);

    if (refreshedToken == null || refreshedToken.isEmpty) {
      throw Exception('Could not refresh session token');
    }

    await storageService.setKeyValue('token', refreshedToken);
    return refreshedToken;
  }
}
