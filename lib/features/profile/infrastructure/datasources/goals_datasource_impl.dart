import 'package:firebase_auth/firebase_auth.dart';
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
      final Response<dynamic> response = await _executeAuthenticatedRequest(
        (String token) => dio.get(
          '/user/goals',
          options: Options(
            headers: <String, String>{'Authorization': 'Bearer $token'},
          ),
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
      final Response<dynamic> response = await _executeAuthenticatedRequest(
        (String token) => dio.put(
          '/user/goals',
          data: UserGoalsMapper.toJson(goals),
          options: Options(
            headers: <String, String>{'Authorization': 'Bearer $token'},
          ),
        ),
      );

      return UserGoalsMapper.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_mapErrorMessage(e, 'actualizar las metas'));
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
      throw Exception('No hay una sesión activa');
    }

    final String? refreshedToken = await user.getIdToken(true);

    if (refreshedToken == null || refreshedToken.isEmpty) {
      throw Exception('No se pudo renovar la sesión');
    }

    await storageService.setKeyValue('token', refreshedToken);
    return refreshedToken;
  }

  String _mapErrorMessage(DioException exception, String action) {
    final int? statusCode = exception.response?.statusCode;

    if (statusCode == 401) {
      return 'Sesión inválida o expirada al $action';
    }

    if (statusCode == 400) {
      final dynamic data = exception.response?.data;
      if (data is Map<String, dynamic> && data['message'] is String) {
        return data['message'] as String;
      }
      return 'Datos inválidos al $action';
    }

    if (statusCode == 404) {
      return 'Endpoint no encontrado al $action';
    }

    return 'Ocurrió un error al $action: ${exception.message}';
  }
}
