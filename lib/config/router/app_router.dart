import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/domain/entities/auth_state.dart';
import 'package:foodai/features/auth/presentation/providers/auth_provider.dart';
import 'package:foodai/features/auth/presentation/screens/login_screen.dart';
import 'package:foodai/features/home/domain/entities/food_item.dart';
import 'package:foodai/features/main/screens/main_screen.dart';
import 'package:foodai/features/home/presentation/screens/screens.dart';
import 'package:foodai/features/profile/presentation/screens/screens.dart';
import 'package:foodai/features/camera/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

// Notifier para actualizar GoRouter cuando cambia el estado de auth
final goRouterNotifierProvider = Provider<GoRouterNotifier>((ref) {
  return GoRouterNotifier(ref);
});

class GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  GoRouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authStateProvider,
      (previous, next) {
        if (previous?.status != next.status) {
          notifyListeners();
        }
      },
    );
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(goRouterNotifierProvider);
  
  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isChecking = authState.isChecking;

      // Si está verificando el estado, no redirigir
      if (isChecking) return null;

      // Si no está logueado y no va a login → redirigir a login
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // Si está logueado y va a login → redirigir a home
      if (isLoggedIn && isGoingToLogin) {
        return '/home';
      }

      // No redirigir
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'food-item-detail',
                builder: (context, state) {
                  final foodItem = state.extra as FoodItem;
                  return FoodItemDetailScreen(foodItem: foodItem);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/camera',
            builder: (context, state) => const CameraScreen(),
          ),
        ]
      ),
    ],
  );
});