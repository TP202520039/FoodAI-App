

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/presentation/providers/auth_provider.dart';
import 'package:foodai/shared/widget/widgets.dart';

class LoginScreen extends ConsumerWidget {

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mostrar error si existe
    ref.listen(loginFormProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 45,
                      height: 46,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'FoodAI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "BIENVENIDO",
                  style: TextStyle(
                    color: const Color(0xFF583C1C),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Identifica tus comidas peruanas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _EmailInput(),
                const SizedBox(height: 13),
                _PasswordInput(),
                const SizedBox(height: 20),
                _LoginButton(),
                const SizedBox(height: 13),
                _RegisterButton(),
                const SizedBox(height: 13),
                _GoogleLoginButton(),
                const SizedBox(height: 20),
                Text (
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _EmailInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    
    return CustomTextFormField(
      label: 'Correo Electrónico',
      keyboardType: TextInputType.emailAddress,
      onChanged: ref.read(loginFormProvider.notifier).onEmailChanged,
      errorMessage: loginForm.isFormPosted ? loginForm.emailError : null,
    );
  }
}

class _PasswordInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    
    return CustomTextFormField(
      label: 'Contraseña',
      obscureText: true,
      onChanged: ref.read(loginFormProvider.notifier).onPasswordChanged,
      errorMessage: loginForm.isFormPosted ? loginForm.passwordError : null,
    );
  }
}

class _LoginButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);

    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: loginForm.isPosting ? 'INICIANDO SESIÓN...' : 'INICIAR SESIÓN',
        buttonColor: const Color(0xFF7D8B4E),
        onPressed: loginForm.isPosting
            ? null
            : ref.read(loginFormProvider.notifier).onFormSubmit,
      ),
    );
  }
}

class _RegisterButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: 'REGISTRARSE',
        buttonColor: const Color(0xFF7D8B4E),
      ),
    );
  }
}

class _GoogleLoginButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);

    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: 'Ingresar con Google',
        buttonColor: Colors.white,
        fontColor: Colors.black,
        imagePath: 'assets/images/logo_google.png',
        onPressed: loginForm.isPosting
            ? null
            : ref.read(loginFormProvider.notifier).signInWithGoogle,
      ),
    );
  }
}




