import 'package:flutter/material.dart';

class GoalAssistantCard extends StatelessWidget {
  const GoalAssistantCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7D8B4E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿No sabes cuánto deberías comer?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF08273A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Responde 3 preguntas y calculamos una meta inicial acorde a tus datos.',
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7D8B4E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Calcular mi meta'),
            ),
          ),
        ],
      ),
    );
  }
}
