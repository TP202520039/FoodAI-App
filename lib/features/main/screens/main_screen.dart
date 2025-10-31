

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/main/widget/custom_app_bar.dart';
import 'package:foodai/features/main/widget/custom_bottom_app_bar.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: const Center(
        child: Text('Welcome to the Main Screen!'),
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

}