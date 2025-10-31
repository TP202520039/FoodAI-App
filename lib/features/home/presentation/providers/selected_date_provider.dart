import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para la fecha seleccionada en el home
final selectedDateProvider = StateProvider<DateTime>((ref) {
  // Por defecto, la fecha de hoy
  return DateTime.now();
});
