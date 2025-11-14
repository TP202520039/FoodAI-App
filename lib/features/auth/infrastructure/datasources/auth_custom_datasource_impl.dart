import 'package:foodai/config/const/environments.dart';
import 'package:foodai/features/auth/domain/datasources/auth_custom_datasource.dart';
import 'package:foodai/features/auth/domain/entities/foodai_user.dart';
import 'package:dio/dio.dart';
import 'package:foodai/features/auth/infrastructure/mappers/foodai_user_mapper.dart';
import 'package:foodai/shared/infrastructure/services/key_value_storage_service.dart';

class AuthCustomDataSourceImpl extends AuthCustomDataSource {
  late final Dio dio;
  final KeyValueStorageService storageService;

  AuthCustomDataSourceImpl({required this.storageService}) {
    // Inicializar Dio de forma lazy

    dio = Dio(BaseOptions(
      baseUrl: Environment.apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    ));
  }

  @override
  Future<FoodAiUser> sync(String token) async {
    try {
      final response = await dio.post(
        '/auth/sync',
        data: {'idToken': token}
      );
      return FoodaiUserMapper.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Token inválido o expirado');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Endpoint de sincronización no encontrado');
      }
      throw Exception('Error al sincronizar usuario: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado en sincronización: $e');
    }
  }
  
}