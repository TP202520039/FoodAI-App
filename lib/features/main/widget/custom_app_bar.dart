
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFF443723),
      child: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF443723),
        title: const Text('FoodAI'),
        centerTitle: true,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}