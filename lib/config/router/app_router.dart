import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/presentation/screens/login_screen.dart';
import 'package:foodai/features/main/screens/main_screen.dart';
import 'package:foodai/features/home/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider((ref) {
  
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      ShellRoute(
        builder:(context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
        ]
      ),
    ]);

});