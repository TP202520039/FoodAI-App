import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/home/infrastructure/datasources/food_detections_datasource_impl.dart';
import 'package:foodai/features/home/presentation/widgets/date_carousel_widget.dart';
import 'package:foodai/shared/infrastructure/services/key_value_storage_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const DateCarouselWidget(),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  'Contenido del día seleccionado',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
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
