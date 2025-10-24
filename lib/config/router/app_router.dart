import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/presentation/screens/login_screen.dart';
import 'package:foodai/features/main/screens/main_screen.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider((ref) {
  
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/main', 
        builder: (context, state) => const MainScreen(),
      ),
    ]);

});