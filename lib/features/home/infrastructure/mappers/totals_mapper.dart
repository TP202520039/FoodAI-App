import 'package:foodai/features/home/domain/entities/totals.dart';

class TotalsMapper {
  static Totals fromJson(Map<String, dynamic> json) {
    return Totals(
      totalCalories: (json['totalCalories'] as num?)?.toInt(),
      totalProtein: (json['totalProtein'] as num?)?.toDouble(),
      totalFat: (json['totalFat'] as num?)?.toDouble(),
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> toJson(Totals totals) {
    return {
      'totalCalories': totals.totalCalories,
      'totalProtein': totals.totalProtein,
      'totalFat': totals.totalFat,
      'totalCarbs': totals.totalCarbs,
    };
  }
}
