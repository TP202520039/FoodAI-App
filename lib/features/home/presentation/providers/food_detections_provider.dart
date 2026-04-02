import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/domain/entities/auth_state.dart';
import 'package:foodai/features/auth/presentation/providers/auth_provider.dart';
import 'package:foodai/features/home/domain/entities/food_detections.dart';
import 'package:foodai/features/home/infrastructure/datasources/food_detections_datasource_impl.dart';
import 'package:foodai/features/home/infrastructure/repositories/food_detections_repository_impl.dart';
import 'package:foodai/features/home/presentation/providers/selected_date_provider.dart';
import 'package:foodai/shared/infrastructure/services/key_value_service.dart';

// Repository provider
final foodDetectionsRepositoryProvider = Provider((ref) {
  final keyValueStorageService = ref.read(keyValueStorageServiceProvider);
  return FoodDetectionsRepositoryImpl(
    dataSource: FoodDetectionsDataSourceImpl(
      storageService: keyValueStorageService,
    ),
  );
});

// State provider for food detections
final foodDetectionsProvider =
    StateNotifierProvider<
      FoodDetectionsNotifier,
      AsyncValue<List<FoodDetections>>
    >((ref) {
      final repository = ref.watch(foodDetectionsRepositoryProvider);
      return FoodDetectionsNotifier(repository: repository, ref: ref);
    });

class FoodDetectionsNotifier
    extends StateNotifier<AsyncValue<List<FoodDetections>>> {
  final FoodDetectionsRepositoryImpl repository;
  final Ref ref;

  FoodDetectionsNotifier({required this.repository, required this.ref})
    : super(const AsyncValue.loading()) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      _handleAuthState(next);
    });

    // Listen to date changes and fetch data automatically
    ref.listen(selectedDateProvider, (previous, next) {
      if (ref.read(authStateProvider).isAuthenticated) {
        fetchFoodDetections(next);
      }
    });

    _handleAuthState(ref.read(authStateProvider));
  }

  Future<void> fetchFoodDetections(DateTime date) async {
    state = const AsyncValue.loading();

    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    state = await AsyncValue.guard(() async {
      return await repository.getFoodDetectionsByDate(dateString);
    });
  }

  void refresh() {
    final currentDate = ref.read(selectedDateProvider);
    fetchFoodDetections(currentDate);
  }

  void _handleAuthState(AuthState authState) {
    if (authState.isChecking) {
      state = const AsyncValue.loading();
      return;
    }

    if (!authState.isAuthenticated) {
      state = const AsyncValue.data(<FoodDetections>[]);
      return;
    }

    fetchFoodDetections(ref.read(selectedDateProvider));
  }
}
