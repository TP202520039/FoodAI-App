import 'package:foodai/features/home/domain/entities/nutritional_info.dart';

class Component {
  int? id;
  String? foodName;
  int? quantityGrams;
  double? confidenceScore;
  NutritionalInfo? nutritionalInfo;
  bool? nutritionalDataFound;

  Component({
    this.id,
    this.foodName,
    this.quantityGrams,
    this.confidenceScore,
    this.nutritionalInfo,
    this.nutritionalDataFound,
  });
}
