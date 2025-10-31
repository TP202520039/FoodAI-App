import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/domain/domain.dart';
import 'package:foodai/features/auth/domain/entities/auth_exceptions.dart';
import 'package:foodai/features/auth/domain/entities/auth_state.dart';
import 'package:foodai/features/auth/domain/entities/login_form_state.dart';
import 'package:foodai/features/auth/infrastructure/datasources/auth_datasource_impl.dart';
import 'package:foodai/features/auth/infrastructure/repositories/auth_repository_impl.dart';

// ============================================================================
// PROVIDER DEL REPOSITORIO
// ============================================================================

/// Provider del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthDatasourceImpl());
});

// ============================================================================
// PROVIDER DEL ESTADO DE AUTENTICACIÓN
// ============================================================================

/// Provider del estado de autenticación (notifier)
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

/// Notificador del estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthNotifier(this._authRepository) : super(const AuthState.checking()) {
    _init();
  }

  /// Inicializa el listener de cambios de autenticación
  void _init() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  /// Inicia sesión con email y contraseña
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.checking);
      final user = await _authRepository.signInWithEmailPassword(email, password);
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(e.message);
      rethrow;
    } catch (e) {
      state = AuthState.unauthenticated('Error inesperado: $e');
      rethrow;
    }
  }

  /// Inicia sesión con Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(status: AuthStatus.checking);
      final user = await _authRepository.signInWithGoogle();
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(e.message);
      rethrow;
    } catch (e) {
      state = AuthState.unauthenticated('Error inesperado: $e');
      rethrow;
    }
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.unauthenticated('Error al cerrar sesión: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// ============================================================================
// PROVIDER DEL FORMULARIO DE LOGIN
// ============================================================================

/// Provider del formulario de login
final loginFormProvider = StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  final authNotifier = ref.read(authStateProvider.notifier);
  return LoginFormNotifier(authNotifier);
});

/// Notificador del formulario de login
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final AuthNotifier _authNotifier;

  LoginFormNotifier(this._authNotifier) : super(const LoginFormState());

  /// Actualiza el email
  void onEmailChanged(String value) {
    final emailError = _validateEmail(value);
    state = state.copyWith(
      email: value,
      emailError: emailError,
      isValid: emailError == null && state.passwordError == null,
    );
  }

  /// Actualiza la contraseña
  void onPasswordChanged(String value) {
    final passwordError = _validatePassword(value);
    state = state.copyWith(
      password: value,
      passwordError: passwordError,
      isValid: state.emailError == null && passwordError == null,
    );
  }

  /// Valida el email
  String? _validateEmail(String value) {
    if (value.isEmpty) return 'El correo es requerido';
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'El correo no es válido';
    }
    
    return null;
  }

  /// Valida la contraseña
  String? _validatePassword(String value) {
    if (value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  /// Envía el formulario de login con email y contraseña
  Future<void> onFormSubmit() async {
    state = state.copyWith(isFormPosted: true);

    // Validar campos
    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      isValid: emailError == null && passwordError == null,
    );

    if (!state.isValid) return;

    state = state.copyWith(isPosting: true, errorMessage: null);

    try {
      await _authNotifier.signInWithEmailPassword(state.email, state.password);
      // El estado se actualiza automáticamente por el authStateProvider
    } on AuthException catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: 'Error inesperado al iniciar sesión',
      );
    }
  }

  /// Inicia sesión con Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isPosting: true, errorMessage: null);

    try {
      await _authNotifier.signInWithGoogle();
      // El estado se actualiza automáticamente por el authStateProvider
    } on GoogleSignInCancelledException {
      // Usuario canceló, no mostrar error
      state = state.copyWith(isPosting: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: 'Error inesperado con Google Sign-In',
      );
    }
  }
}
