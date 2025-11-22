import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/domain/domain.dart';
import 'package:foodai/features/auth/presentation/providers/auth_provider.dart';

// ============================================================================
// PROVIDER DEL FORMULARIO DE REGISTRO
// ============================================================================

/// Provider del formulario de registro
final registerFormProvider =
    StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>(
        (ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterFormNotifier(authRepository);
});

/// Estado del formulario de registro
class RegisterFormState {
  final String email;
  final String password;
  final String confirmPassword;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool isValid;
  final bool isPosting;
  final bool isFormPosted;
  final bool isRegistered;
  final String? errorMessage;

  const RegisterFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isValid = false,
    this.isPosting = false,
    this.isFormPosted = false,
    this.isRegistered = false,
    this.errorMessage,
  });

  RegisterFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    Object? emailError = const _Undefined(),
    Object? passwordError = const _Undefined(),
    Object? confirmPasswordError = const _Undefined(),
    bool? isValid,
    bool? isPosting,
    bool? isFormPosted,
    bool? isRegistered,
    Object? errorMessage = const _Undefined(),
  }) {
    return RegisterFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      emailError: emailError is _Undefined ? this.emailError : emailError as String?,
      passwordError: passwordError is _Undefined ? this.passwordError : passwordError as String?,
      confirmPasswordError: confirmPasswordError is _Undefined ? this.confirmPasswordError : confirmPasswordError as String?,
      isValid: isValid ?? this.isValid,
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isRegistered: isRegistered ?? this.isRegistered,
      errorMessage: errorMessage is _Undefined ? this.errorMessage : errorMessage as String?,
    );
  }
}

// Clase helper para diferenciar entre null explícito y valor no proporcionado
class _Undefined {
  const _Undefined();
}

/// Notificador del formulario de registro
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final AuthRepository _authRepository;

  RegisterFormNotifier(this._authRepository)
      : super(const RegisterFormState());

  /// Actualiza el email
  void onEmailChanged(String value) {
    final emailError = _validateEmail(value);
    state = state.copyWith(
      email: value,
      emailError: state.isFormPosted ? emailError : null,
      isValid: _isFormValid(
        emailError: emailError,
        passwordError: state.passwordError,
        confirmPasswordError: state.confirmPasswordError,
      ),
    );
  }

  /// Actualiza la contraseña
  void onPasswordChanged(String value) {
    final passwordError = _validatePassword(value);
    final confirmPasswordError =
        state.confirmPassword.isNotEmpty && value != state.confirmPassword
            ? 'Las contraseñas no coinciden'
            : null;

    state = state.copyWith(
      password: value,
      passwordError: state.isFormPosted ? passwordError : null,
      confirmPasswordError: state.isFormPosted ? confirmPasswordError : null,
      isValid: _isFormValid(
        emailError: state.emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      ),
    );
  }

  /// Actualiza la confirmación de contraseña
  void onConfirmPasswordChanged(String value) {
    final confirmPasswordError =
        value != state.password ? 'Las contraseñas no coinciden' : null;

    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordError: state.isFormPosted ? confirmPasswordError : null,
      isValid: _isFormValid(
        emailError: state.emailError,
        passwordError: state.passwordError,
        confirmPasswordError: confirmPasswordError,
      ),
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

  /// Valida la contraseña con requisitos de seguridad
  String? _validatePassword(String value) {
    if (value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Validar que tenga al menos una letra mayúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe incluir al menos una letra mayúscula';
    }

    // Validar que tenga al menos una letra minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe incluir al menos una letra minúscula';
    }

    // Validar que tenga al menos un número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe incluir al menos un número';
    }

    return null;
  }

  /// Verifica si el formulario es válido
  bool _isFormValid({
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
  }) {
    return emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  /// Envía el formulario de registro
  Future<void> onFormSubmit() async {
    state = state.copyWith(isFormPosted: true);

    // Validar campos
    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);
    final confirmPasswordError = state.password != state.confirmPassword
        ? 'Las contraseñas no coinciden'
        : null;

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      isValid: _isFormValid(
        emailError: emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      ),
    );

    if (!state.isValid) return;

    state = state.copyWith(isPosting: true, errorMessage: null);

    try {
      await _authRepository.registerWithEmailPassword(
        state.email,
        state.password,
      );

      // Cerrar sesión automáticamente después del registro
      await _authRepository.signOut();

      state = state.copyWith(
        isPosting: false,
        isRegistered: true,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: 'Error inesperado al crear la cuenta',
      );
    }
  }
}
