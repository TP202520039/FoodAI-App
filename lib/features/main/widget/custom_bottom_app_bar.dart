import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomAppBar extends ConsumerWidget {
  const CustomBottomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
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