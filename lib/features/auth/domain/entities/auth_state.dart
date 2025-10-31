import 'package:firebase_auth/firebase_auth.dart';

/// Estado de autenticación de la aplicación
class AuthState {
  final User? user;
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.status = AuthStatus.checking,
    this.errorMessage,
  });

  // Estado inicial (verificando autenticación)
  const AuthState.checking() : this(status: AuthStatus.checking);

  // Usuario autenticado
  const AuthState.authenticated(User user) 
      : this(user: user, status: AuthStatus.authenticated);

  // Usuario no autenticado
  const AuthState.unauthenticated([String? errorMessage]) 
      : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  // Copiado con modificaciones
  AuthState copyWith({
    User? user,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
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
