/// Estado del formulario de login
class LoginFormState {
  final String email;
  final String password;
  final bool isValid;
  final bool isPosting;
  final bool isFormPosted;
  final String? errorMessage;
  final String? emailError;
  final String? passwordError;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isValid = false,
    this.isPosting = false,
    this.isFormPosted = false,
    this.errorMessage,
    this.emailError,
    this.passwordError,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isValid,
    bool? isPosting,
    bool? isFormPosted,
    String? errorMessage,
    String? emailError,
    String? passwordError,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      errorMessage: errorMessage,
      emailError: emailError,
      passwordError: passwordError,
    );
  }

  // Limpia los errores del formulario
  LoginFormState clearErrors() {
    return copyWith(
      errorMessage: null,
      emailError: null,
      passwordError: null,
    );
  }

  @override
  String toString() {
    return 'LoginFormState(email: $email, isValid: $isValid, isPosting: $isPosting)';
  }
}
