
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/shared/widget/custom_filled_button.dart';
import 'package:foodai/shared/widget/custom_text_form_field.dart';

class LoginScreen extends ConsumerWidget {

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                _GoogleLoginButton(),
                const SizedBox(height: 20),
                Text ("¿Olvidaste tu contraseña?", style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),)
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
    
    return CustomTextFormField(
      label: 'Correo Electrónico',
      keyboardType: TextInputType.text,
      // onChanged: ref.read(loginFormProvider.notifier).onUsernameChanged,
      // errorMessage:
      //     loginForm.isFormPosted ? loginForm.username.errorMessage : null,
    );
  }
}

class _PasswordInput extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return CustomTextFormField(
      label: 'Contraseña',
      keyboardType: TextInputType.text,
      obscureText: true,
      // onChanged: ref.read(loginFormProvider.notifier).onUsernameChanged,
      // errorMessage:
      //     loginForm.isFormPosted ? loginForm.username.errorMessage : null,
    );
  }
}

class _LoginButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final loginForm = ref.watch(loginFormProvider);

    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: 'INICIAR SESIÓN',
        buttonColor: const Color(0xFF7D8B4E),
        // onPressed: loginForm.isPosting
        //     ? null
        //     : ref.read(loginFormProvider.notifier).onFormSubmit,
      ),
    );
  }
}

class _GoogleLoginButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final loginForm = ref.watch(loginFormProvider);

    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: 'Ingresar con Google',
        buttonColor: Colors.white,
        fontColor: Colors.black,
        imagePath: 'assets/images/logo_google.png',
        // onPressed: loginForm.isPosting
        //     ? null
        //     : ref.read(loginFormProvider.notifier).onFormSubmit,
      ),
    );
  }
}


