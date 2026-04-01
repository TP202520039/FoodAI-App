import 'package:dio/dio.dart';
import 'package:foodai/config/const/environments.dart';
import 'package:foodai/features/profile/domain/datasources/goals_datasource.dart';
import 'package:foodai/features/profile/domain/entities/user_goals.dart';
import 'package:foodai/features/profile/infrastructure/mappers/user_goals_mapper.dart';
import 'package:foodai/shared/infrastructure/services/key_value_storage_service.dart';

class GoalsDataSourceImpl extends GoalsDataSource {
  GoalsDataSourceImpl({required this.storageService})
    : dio = Dio(
        BaseOptions(
          baseUrl: Environment.apiUrl,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  final Dio dio;
  final KeyValueStorageService storageService;

  @override
  Future<UserGoals> getGoals() async {
    try {
      final String? token = await storageService.getValue<String>('token');

      final Response<dynamic> response = await dio.get(
        '/user/goals',
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $token'},
        ),
      );

      return UserGoalsMapper.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_mapErrorMessage(e, 'obtener las metas'));
    }
  }

  @override
  Future<UserGoals> updateGoals(UserGoals goals) async {
    try {
      final String? token = await storageService.getValue<String>('token');

      final Response<dynamic> response = await dio.put(
        '/user/goals',
        data: UserGoalsMapper.toJson(goals),
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $token'},
        ),
      );

      return UserGoalsMapper.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_mapErrorMessage(e, 'actualizar las metas'));
    }
  }

  String _mapErrorMessage(DioException exception, String action) {
    final int? statusCode = exception.response?.statusCode;

    if (statusCode == 401) {
      return 'Sesion invalida o expirada al $action';
    }

    if (statusCode == 400) {
      final dynamic data = exception.response?.data;
      if (data is Map<String, dynamic> && data['message'] is String) {
        return data['message'] as String;
      }
      return 'Datos invalidos al $action';
    }

    if (statusCode == 404) {
      return 'Endpoint no encontrado al $action';
    }

    return 'Ocurrio un error al $action: ${exception.message}';
  }
}
