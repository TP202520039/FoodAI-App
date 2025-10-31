

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/main/widget/custom_app_bar.dart';
import 'package:foodai/features/main/widget/custom_bottom_app_bar.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: child,
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

}