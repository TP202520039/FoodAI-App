import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/home/infrastructure/repositories/food_detections_repository_impl.dart';
import 'package:foodai/features/home/presentation/providers/food_detections_provider.dart';

final foodItemDeleteProvider = StateNotifierProvider<FoodItemDeleteNotifier, bool>((ref) {
  final repository = ref.watch(foodDetectionsRepositoryProvider);
  return FoodItemDeleteNotifier(repository: repository);
});

class FoodItemDeleteNotifier extends StateNotifier<bool> {
  final FoodDetectionsRepositoryImpl repository;

  FoodItemDeleteNotifier({required this.repository}) : super(false);

  Future<bool> deleteFoodItem(int foodDetectionId) async {
    state = true; // Start loading
    
    try {
      await repository.deleteFoodDetection(foodDetectionId);
      state = false; // Stop loading
      return true;
    } catch (e) {
      state = false; // Stop loading
      return false;
    }
  }
}
