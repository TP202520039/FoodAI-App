# Sistema de Autenticación con Firebase - FoodAI

## 📁 Estructura Implementada

```
lib/features/auth/
├── domain/
│   ├── datasources/
│   │   └── auth_datasource.dart          # Interface del datasource
│   ├── entities/
│   │   ├── auth_exceptions.dart          # ✨ Excepciones personalizadas
│   │   ├── auth_state.dart               # ✨ Estado de autenticación
│   │   └── login_form_state.dart         # ✨ Estado del formulario
│   ├── repositories/
│   │   └── auth_repository.dart          # Interface del repositorio
│   └── domain.dart                       # Exports
├── infrastructure/
│   ├── datasources/
│   │   └── auth_datasource_impl.dart     # ✅ Implementación mejorada
│   └── repositories/
│       └── auth_repository_impl.dart     # ✅ Implementación actualizada
└── presentation/
    ├── providers/
    │   └── auth_provider.dart            # ✨ Todos los providers
    └── screens/
        └── login_screen.dart             # ✅ Conectado a providers
```

## 🎯 Providers Creados

### 1. authRepositoryProvider
Proveedor singleton del repositorio de autenticación.

### 2. authStateProvider (StateNotifier)
Maneja el estado global de autenticación:
- Usuario actual
- Estado de autenticación (checking/authenticated/unauthenticated)
- Mensajes de error
- Escucha cambios de Firebase Auth automáticamente

### 3. loginFormProvider (StateNotifier)
Maneja el formulario de login:
- Validación de email y contraseña
- Estado de loading
- Errores del formulario
- Submit de login con email/password
- Login con Google

## 🔐 Métodos de Autenticación

### Login con Email y Contraseña
```dart
await ref.read(loginFormProvider.notifier).onFormSubmit();
```

### Login con Google
```dart
await ref.read(loginFormProvider.notifier).signInWithGoogle();
```

### Cerrar Sesión
```dart
await ref.read(authStateProvider.notifier).signOut();
```

## 🛡️ Protección de Rutas

El `goRouterProvider` ahora incluye lógica de redirección:

- **Usuario no autenticado** → Redirige a `/login`
- **Usuario autenticado en login** → Redirige a `/home`
- **Durante verificación** → No redirige (evita flickering)

## ✨ Características Implementadas

### 1. Excepciones Personalizadas
- `UserNotFoundException`
- `WrongPasswordException`
- `InvalidEmailException`
- `GoogleSignInCancelledException`
- `NetworkException`
- `UnknownAuthException`

### 2. Validaciones de Formulario
- Email: formato válido y requerido
- Password: mínimo 6 caracteres y requerido
- Muestra errores solo después del primer submit

### 3. UX Mejorada
- Mensajes de error específicos por tipo de error
- SnackBar para mostrar errores
- Botones deshabilitados durante loading
- Texto dinámico en botones ("INICIANDO SESIÓN...")
- Diálogo de confirmación para cerrar sesión

### 4. ProfileScreen Actualizado
- Muestra foto de perfil del usuario (si tiene)
- Muestra nombre y email del usuario
- Botón funcional de cerrar sesión con confirmación

## 🔄 Flujo de Autenticación

1. **Inicio de App**:
   - `authStateProvider` escucha `authStateChanges` de Firebase
   - Si hay usuario guardado → AuthState.authenticated
   - Si no hay usuario → AuthState.unauthenticated

2. **Login**:
   - Usuario llena formulario
   - `loginFormProvider` valida campos
   - Llama a `authNotifier.signInWithEmailPassword()`
   - Firebase Auth actualiza → `authStateChanges` emite evento
   - `authStateProvider` actualiza estado
   - `goRouter` detecta cambio y redirige a `/home`

3. **Logout**:
   - Usuario presiona "Cerrar Sesión"
   - Confirma en diálogo
   - Llama a `authNotifier.signOut()`
   - Firebase Auth cierra sesión
   - `authStateProvider` actualiza a unauthenticated
   - `goRouter` redirige a `/login`

## 🚀 Mejoras Implementadas en AuthDatasourceImpl

1. **Retorna User en lugar de UserCredential**
   - Más simple y directo para el caso de uso

2. **Manejo de errores mejorado**
   - Excepciones específicas por código de error
   - Mensajes user-friendly en español

3. **Getters agregados**
   - `authStateChanges`: Stream para escuchar cambios
   - `currentUser`: Usuario actual

4. **SignOut optimizado**
   - Removido `disconnect()` de Google Sign In
   - Permite cambio de cuenta sin desconectar totalmente

## 📝 Uso en la Aplicación

### En cualquier widget, acceder al usuario:
```dart
final authState = ref.watch(authStateProvider);
final user = authState.user;

if (authState.isAuthenticated) {
  // Usuario logueado
  Text(user!.displayName ?? 'Usuario');
}
```

### Verificar estado de carga:
```dart
final authState = ref.watch(authStateProvider);
if (authState.isChecking) {
  return CircularProgressIndicator();
}
```

## ⚠️ Notas Importantes

1. **Flutter Clean**: Si hay errores de compilación, ejecutar:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Firebase Setup**: Asegurarse de tener configurado:
   - `google-services.json` (Android)
   - GoogleService-Info.plist (iOS)
   - Firebase Auth habilitado en consola
   - Google Sign In habilitado en Firebase

3. **Rutas**: Todas las rutas protegidas están bajo `ShellRoute` con `MainScreen`

## 🎨 Personalización

Para agregar más métodos de autenticación (Apple, Facebook, etc.):

1. Agregar método en `AuthDatasource`
2. Implementar en `AuthDatasourceImpl`
3. Agregar en `AuthRepository` y su implementación
4. Agregar método en `AuthNotifier`
5. Crear botón en `LoginScreen`

---

✅ **Sistema completo de autenticación implementado y listo para usar**
