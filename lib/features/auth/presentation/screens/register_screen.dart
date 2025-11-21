import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/presentation/providers/register_provider.dart';
import 'package:foodai/shared/widget/widgets.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mostrar error si existe
    ref.listen(registerFormProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Mostrar mensaje de éxito y regresar al login
      if (next.isRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Registro exitoso! Ya puedes iniciar sesión'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/login');
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
                const Text(
                  "CREAR CUENTA",
                  style: TextStyle(
                    color: Color(0xFF583C1C),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Regístrate para comenzar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const _EmailInput(),
                const SizedBox(height: 13),
                const _PasswordInput(),
                const SizedBox(height: 13),
                const _ConfirmPasswordInput(),
                const SizedBox(height: 20),
                const _RegisterButton(),
                const SizedBox(height: 13),
                const _BackToLoginButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends ConsumerWidget {
  const _EmailInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);

    return CustomTextFormField(
      label: 'Correo Electrónico',
      keyboardType: TextInputType.emailAddress,
      onChanged: ref.read(registerFormProvider.notifier).onEmailChanged,
      errorMessage: registerForm.isFormPosted ? registerForm.emailError : null,
    );
  }
}

class _PasswordInput extends ConsumerWidget {
  const _PasswordInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);

    return CustomTextFormField(
      label: 'Contraseña',
      obscureText: true,
      onChanged: ref.read(registerFormProvider.notifier).onPasswordChanged,
      errorMessage:
          registerForm.isFormPosted ? registerForm.passwordError : null,
    );
  }
}

class _ConfirmPasswordInput extends ConsumerWidget {
  const _ConfirmPasswordInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);

    return CustomTextFormField(
      label: 'Confirmar Contraseña',
      obscureText: true,
      onChanged:
          ref.read(registerFormProvider.notifier).onConfirmPasswordChanged,
      errorMessage: registerForm.isFormPosted
          ? registerForm.confirmPasswordError
          : null,
    );
  }
}

class _RegisterButton extends ConsumerWidget {
  const _RegisterButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);

    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: registerForm.isPosting ? 'REGISTRANDO...' : 'CREAR CUENTA',
        buttonColor: const Color(0xFF7D8B4E),
        onPressed: registerForm.isPosting
            ? null
            : ref.read(registerFormProvider.notifier).onFormSubmit,
      ),
    );
  }
}

class _BackToLoginButton extends ConsumerWidget {
  const _BackToLoginButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => context.go('/login'),
        child: const Text(
          '¿Ya tienes cuenta? Inicia sesión',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
