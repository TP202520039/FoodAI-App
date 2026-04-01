import 'package:flutter/material.dart';
import 'package:foodai/features/profile/domain/entities/user_goals.dart';

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({
    super.key,
    required this.caloriesConsumed,
    required this.proteinConsumed,
    required this.fatConsumed,
    required this.carbsConsumed,
    required this.goals,
    this.isLoadingGoals = false,
  });

  final int caloriesConsumed;
  final double proteinConsumed;
  final double fatConsumed;
  final double carbsConsumed;
  final UserGoals goals;
  final bool isLoadingGoals;

  static const Color _primaryColor = Color(0xFF08273A);
  static const Color _proteinColor = Color(0xFF7D8B4E);
  static const Color _fatColor = Color(0xFFDDC68F);
  static const Color _carbsColor = Color(0xFFAABB96);
  static const Color _cardColor = Colors.white;
  static const Color _softSurfaceColor = Color(0xFFF5F2E8);

  @override
  Widget build(BuildContext context) {
    final int remainingCalories = (goals.dailyCaloriesGoal - caloriesConsumed)
        .clamp(0, goals.dailyCaloriesGoal);
    final double caloriesProgress = _buildProgress(
      caloriesConsumed.toDouble(),
      goals.dailyCaloriesGoal.toDouble(),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDC68F), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Resumen del día',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _softSurfaceColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Meta ${goals.dailyCaloriesGoal} kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isLoadingGoals)
            const LinearProgressIndicator(
              minHeight: 3,
              color: _primaryColor,
              backgroundColor: _softSurfaceColor,
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: _primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$caloriesConsumed kcal',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                            ),
                            const Text(
                              'consumidas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$remainingCalories restantes',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _proteinColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(caloriesProgress * 100).round()}% de tu meta',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: caloriesProgress,
                minHeight: 8,
                color: _primaryColor,
                backgroundColor: _softSurfaceColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MacroSummaryItem(
                    label: 'Proteínas',
                    value: '${proteinConsumed.toStringAsFixed(1)} g',
                    progress: _buildProgress(
                      proteinConsumed,
                      goals.dailyProteinGoal.toDouble(),
                    ),
                    color: _proteinColor,
                    backgroundColor: _softSurfaceColor,
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroSummaryItem(
                    label: 'Grasas',
                    value: '${fatConsumed.toStringAsFixed(1)} g',
                    progress: _buildProgress(
                      fatConsumed,
                      goals.dailyFatGoal.toDouble(),
                    ),
                    color: _fatColor,
                    backgroundColor: _softSurfaceColor,
                    icon: Icons.water_drop,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroSummaryItem(
                    label: 'Carbs',
                    value: '${carbsConsumed.toStringAsFixed(1)} g',
                    progress: _buildProgress(
                      carbsConsumed,
                      goals.dailyCarbsGoal.toDouble(),
                    ),
                    color: _carbsColor,
                    backgroundColor: _softSurfaceColor,
                    icon: Icons.grain,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  double _buildProgress(double current, double goal) {
    if (goal <= 0) {
      return 0;
    }

    return (current / goal).clamp(0, 1).toDouble();
  }
}

class _MacroSummaryItem extends StatelessWidget {
  const _MacroSummaryItem({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: color,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
