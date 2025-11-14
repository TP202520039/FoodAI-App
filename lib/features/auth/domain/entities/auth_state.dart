import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodai/features/auth/domain/entities/foodai_user.dart';

/// Estado de autenticación de la aplicación
class AuthState {
  final User? user;
  final FoodAiUser? foodAiUser;
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.foodAiUser,
    this.status = AuthStatus.checking,
    this.errorMessage,
  });

  // Estado inicial (verificando autenticación)
  const AuthState.checking() : this(status: AuthStatus.checking);

  // Usuario autenticado
  const AuthState.authenticated(User user, {FoodAiUser? foodAiUser}) 
      : this(user: user, foodAiUser: foodAiUser, status: AuthStatus.authenticated);

  // Usuario no autenticado
  const AuthState.unauthenticated([String? errorMessage]) 
      : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  // Copiado con modificaciones
  AuthState copyWith({
    User? user,
    FoodAiUser? foodAiUser,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      foodAiUser: foodAiUser ?? this.foodAiUser,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isChecking => status == AuthStatus.checking;
}

/// Estados posibles de autenticación
enum AuthStatus {
  checking,       // Verificando estado de autenticación
  authenticated,  // Usuario autenticado
  unauthenticated // Usuario no autenticado
}
