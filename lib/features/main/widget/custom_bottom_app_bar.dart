import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/main/providers/providers.dart';
import 'package:go_router/go_router.dart';

class CustomBottomAppBar extends ConsumerWidget {
  const CustomBottomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final currentIndex = ref.watch(bottomNavIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(bottomNavIndexProvider.notifier).state = index;
        if (index == 0) context.go('/home');
        if (index == 1) context.go('/camera');
        if (index == 2) context.go('/profile');
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera),
          label: 'Cámara',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      backgroundColor: const Color(0xFFF5F2E8),
      selectedItemColor: const Color(0xFF7D8B4E),
      unselectedItemColor: const Color(0xFF7D8B4E),
    );
  }
}