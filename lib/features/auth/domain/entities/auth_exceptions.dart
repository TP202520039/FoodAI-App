// Excepciones personalizadas para autenticación

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class UserNotFoundException extends AuthException {
  UserNotFoundException() 
      : super('No se encontró ningún usuario con ese correo electrónico', code: 'user-not-found');
}

class WrongPasswordException extends AuthException {
  WrongPasswordException() 
      : super('La contraseña es incorrecta', code: 'wrong-password');
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException() 
      : super('Este correo electrónico ya está en uso', code: 'email-already-in-use');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException() 
      : super('La contraseña es muy débil', code: 'weak-password');
}

class InvalidEmailException extends AuthException {
  InvalidEmailException() 
      : super('El correo electrónico no es válido', code: 'invalid-email');
}

class GoogleSignInCancelledException extends AuthException {
  GoogleSignInCancelledException() 
      : super('Inicio de sesión con Google cancelado', code: 'google-sign-in-cancelled');
}

class NetworkException extends AuthException {
  NetworkException() 
      : super('Error de conexión. Por favor, verifica tu internet', code: 'network-error');
}

class UnknownAuthException extends AuthException {
  UnknownAuthException([String? message]) 
      : super(message ?? 'Ocurrió un error desconocido', code: 'unknown');
}
