import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/home/domain/entities/food_item.dart';
import 'package:foodai/features/home/presentation/providers/food_detections_provider.dart';

// Provider for available cameras
final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

// Provider for analyzing food images
final foodImageAnalysisProvider =
    StateNotifierProvider<FoodImageAnalysisNotifier, AsyncValue<FoodItem?>>((ref) {
  final repository = ref.watch(foodDetectionsRepositoryProvider);
  return FoodImageAnalysisNotifier(repository: repository);
});

class FoodImageAnalysisNotifier extends StateNotifier<AsyncValue<FoodItem?>> {
  final dynamic repository;

  FoodImageAnalysisNotifier({required this.repository})
      : super(const AsyncValue.data(null));

  Future<void> analyzeImage({
    required String imagePath,
    required String category,
    required String detectionDate,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await repository.analyzeFoodImage(
        imagePath,
        category,
        detectionDate,
      );
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
