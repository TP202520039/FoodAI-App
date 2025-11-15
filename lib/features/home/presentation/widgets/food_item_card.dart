import 'package:flutter/material.dart';
import 'package:foodai/features/home/domain/entities/food_item.dart';
import 'package:go_router/go_router.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;

  const FoodItemCard({
    super.key,
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        context.push('/home/food-item-detail', extra: foodItem);
      },
      child: Container(
        width: 360,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F2E8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image on the left
            _buildImage(),
            const SizedBox(width: 12),
            // Content on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Calories
                  _buildTitleAndCalories(colors),
                  const SizedBox(height: 4),
                  // Category
                  _buildCategory(colors),
                  const SizedBox(height: 8),
                  // Macros (Protein, Fat, Carbs)
                  _buildMacros(colors),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: (foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty)
          ? Image.network(
              foodItem.imageUrl!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: Icon(
        Icons.restaurant,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildTitleAndCalories(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            foodItem.foodName ?? 'Sin nombre',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 18,
              color: Colors.orange[700],
            ),
            const SizedBox(width: 2),
            Text(
              '${(foodItem.totals?.totalCalories ?? 0).toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategory(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        foodItem.category ?? 'SIN CATEGORÍA',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getCategoryColor(),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (foodItem.category?.toUpperCase() ?? '') {
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

  Widget _buildMacros(ColorScheme colors) {
    return Row(
      children: [
        _buildMacroItem(
          icon: Icons.fitness_center,
          label: 'P',
          value: (foodItem.totals?.totalProtein ?? 0).toStringAsFixed(1),
          color: Colors.red[400]!,
        ),
        const SizedBox(width: 12),
        _buildMacroItem(
          icon: Icons.water_drop,
          label: 'G',
          value: (foodItem.totals?.totalFat ?? 0).toStringAsFixed(1),
          color: Colors.yellow[700]!,
        ),
        const SizedBox(width: 12),
        _buildMacroItem(
          icon: Icons.grain,
          label: 'C',
          value: (foodItem.totals?.totalCarbs ?? 0).toStringAsFixed(1),
          color: Colors.green[600]!,
        ),
      ],
    );
  }

  Widget _buildMacroItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
