import 'package:flutter/material.dart';
import 'package:foodai/features/home/domain/entities/food_detections.dart';
import 'package:foodai/features/home/presentation/widgets/food_item_card.dart';

class CategoryCarousel extends StatelessWidget {
  final FoodDetections foodDetections;

  const CategoryCarousel({
    super.key,
    required this.foodDetections,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEmpty = foodDetections.items == null || foodDetections.items!.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(),
                size: 24,
                color: _getCategoryColor(),
              ),
              const SizedBox(width: 8),
              Text(
                _getCategoryTitle(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${foodDetections.count ?? 0}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Content: Empty message or Horizontal Scrollable List
        if (isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No hay comidas registradas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: foodDetections.items!.length,
              itemBuilder: (context, index) {
                return FoodItemCard(
                  foodItem: foodDetections.items![index],
                );
              },
            ),
          ),
      ],
    );
  }

  String _getCategoryTitle() {
    switch (foodDetections.category?.toUpperCase() ?? '') {
      case 'DESAYUNO':
        return 'Desayuno';
      case 'ALMUERZO':
        return 'Almuerzo';
      case 'CENA':
        return 'Cena';
      default:
        return foodDetections.category ?? 'Sin categoría';
    }
  }

  IconData _getCategoryIcon() {
    switch (foodDetections.category?.toUpperCase() ?? '') {
      case 'DESAYUNO':
        return Icons.coffee;
      case 'ALMUERZO':
        return Icons.restaurant;
      case 'CENA':
        return Icons.dinner_dining;
      default:
        return Icons.fastfood;
    }
  }

  Color _getCategoryColor() {
    switch (foodDetections.category?.toUpperCase() ?? '') {
      case 'DESAYUNO':
        return Colors.amber[700]!;
      case 'ALMUERZO':
        return Colors.blue[700]!;
      case 'CENA':
        return Colors.purple[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
