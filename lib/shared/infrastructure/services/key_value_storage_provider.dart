import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:foodai/shared/infrastructure/services/key_value_storage_service_impl.dart';

final keyValueStorageServiceProvider = Provider<KeyValueStorageService>((ref) {
  return KeyValueStorageServiceImpl();
});