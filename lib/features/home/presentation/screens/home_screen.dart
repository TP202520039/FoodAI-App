import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/home/domain/entities/food_detections.dart';
import 'package:foodai/features/home/domain/entities/food_item.dart';
import 'package:foodai/features/home/presentation/providers/food_detections_provider.dart';
import 'package:foodai/features/home/presentation/widgets/daily_summary_card.dart';
import 'package:foodai/features/home/presentation/widgets/category_carousel.dart';
import 'package:foodai/features/home/presentation/widgets/date_carousel_widget.dart';
import 'package:foodai/features/profile/domain/entities/user_goals.dart';
import 'package:foodai/features/profile/presentation/providers/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodDetectionsAsync = ref.watch(foodDetectionsProvider);
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const DateCarouselWidget(),
            Expanded(
              child: foodDetectionsAsync.when(
                data: (foodDetectionsList) {
                  final _DailyConsumptionSummary dailyTotals =
                      _calculateDailyTotals(foodDetectionsList);

                  final UserGoals goals = goalsAsync.value ?? const UserGoals();

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.read(foodDetectionsProvider.notifier).refresh();
                      await ref.read(goalsProvider.notifier).loadGoals();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      itemCount: foodDetectionsList.isEmpty
                          ? 2
                          : foodDetectionsList.length + 1,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: index == 0 ? 20 : 24),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return DailySummaryCard(
                            caloriesConsumed: dailyTotals.calories,
                            proteinConsumed: dailyTotals.protein,
                            fatConsumed: dailyTotals.fat,
                            carbsConsumed: dailyTotals.carbs,
                            goals: goals,
                            isLoadingGoals: goalsAsync.isLoading,
                          );
                        }

                        if (foodDetectionsList.isEmpty) {
                          return _EmptyMealsState();
                        }

                        return CategoryCarousel(
                          foodDetections: foodDetectionsList[index - 1],
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar datos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(foodDetectionsProvider.notifier).refresh();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMealsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay comidas registradas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toma una foto para empezar',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyConsumptionSummary {
  const _DailyConsumptionSummary({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final int calories;
  final double protein;
  final double fat;
  final double carbs;
}

_DailyConsumptionSummary _calculateDailyTotals(
  List<FoodDetections> foodDetectionsList,
) {
  int totalCalories = 0;
  double totalProtein = 0;
  double totalFat = 0;
  double totalCarbs = 0;

  for (final FoodDetections foodDetections in foodDetectionsList) {
    final List<FoodItem> items = foodDetections.items ?? <FoodItem>[];

    for (final FoodItem item in items) {
      totalCalories += item.totals?.totalCalories ?? 0;
      totalProtein += item.totals?.totalProtein ?? 0;
      totalFat += item.totals?.totalFat ?? 0;
      totalCarbs += item.totals?.totalCarbs ?? 0;
    }
  }

  return _DailyConsumptionSummary(
    calories: totalCalories,
    protein: totalProtein,
    fat: totalFat,
    carbs: totalCarbs,
  );
}
