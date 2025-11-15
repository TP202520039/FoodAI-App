import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/home/domain/entities/food_item.dart';
import 'package:foodai/features/home/presentation/providers/food_detections_provider.dart';

// State notifier for updating food items
final foodItemUpdateProvider =
    StateNotifierProvider<FoodItemUpdateNotifier, bool>((ref) {
  final repository = ref.watch(foodDetectionsRepositoryProvider);
  return FoodItemUpdateNotifier(repository: repository);
});

class FoodItemUpdateNotifier extends StateNotifier<bool> {
  final dynamic repository;

  FoodItemUpdateNotifier({required this.repository}) : super(false);

  Future<bool> updateFoodItem(FoodItem foodItem) async {
    state = true; // Set loading state
    
    try {
      await repository.updateFoodItemComponents(foodItem);
      state = false;
      return true;
    } catch (e) {
      state = false;
      return false;
    }
  }
}
