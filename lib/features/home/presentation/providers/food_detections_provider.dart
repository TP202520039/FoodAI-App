import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/home/domain/entities/food_detections.dart';
import 'package:foodai/features/home/infrastructure/datasources/food_detections_datasource_impl.dart';
import 'package:foodai/features/home/infrastructure/repositories/food_detections_repository_impl.dart';
import 'package:foodai/features/home/presentation/providers/selected_date_provider.dart';
import 'package:foodai/shared/infrastructure/services/key_value_storage_service_impl.dart';

// Repository provider
final foodDetectionsRepositoryProvider = Provider((ref) {
  final keyValueStorageService = KeyValueStorageServiceImpl();
  return FoodDetectionsRepositoryImpl(
    dataSource: FoodDetectionsDataSourceImpl(
      storageService: keyValueStorageService,
    ),
  );
});

// State provider for food detections
final foodDetectionsProvider = StateNotifierProvider<FoodDetectionsNotifier, AsyncValue<List<FoodDetections>>>((ref) {
  final repository = ref.watch(foodDetectionsRepositoryProvider);
  return FoodDetectionsNotifier(repository: repository, ref: ref);
});

class FoodDetectionsNotifier extends StateNotifier<AsyncValue<List<FoodDetections>>> {
  final FoodDetectionsRepositoryImpl repository;
  final Ref ref;

  FoodDetectionsNotifier({
    required this.repository,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    // Listen to date changes and fetch data automatically
    ref.listen(selectedDateProvider, (previous, next) {
      fetchFoodDetections(next);
    });
    // Initial fetch with current date
    fetchFoodDetections(ref.read(selectedDateProvider));
  }

  Future<void> fetchFoodDetections(DateTime date) async {
    state = const AsyncValue.loading();
    
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    state = await AsyncValue.guard(() async {
      return await repository.getFoodDetectionsByDate(dateString);
    });
  }

  void refresh() {
    final currentDate = ref.read(selectedDateProvider);
    fetchFoodDetections(currentDate);
  }
}
