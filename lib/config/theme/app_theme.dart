import 'package:flutter/material.dart';

const colorSeed = Color(0xFF08273A);

class AppTheme {
  // Gradiente linear vertical
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFDDC68F), // Color superior
      Color(0xFFAABB96), // Color inferior
    ],
  );

  ThemeData getTheme() => ThemeData(
        ///* General
        useMaterial3: true,
        colorSchemeSeed: colorSeed,

        ///* Texts
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
          titleMedium: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          titleSmall: TextStyle(fontSize: 20, color: Colors.black),
        ),

        ///* Scaffold Background Color - Transparente para usar gradiente
        scaffoldBackgroundColor: Colors.transparent,

        ///* Buttons
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            backgroundColor: WidgetStateProperty.all(colorSeed),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
        ),
      );
}