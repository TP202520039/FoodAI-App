import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/auth/presentation/providers/auth_provider.dart';
import 'package:foodai/features/profile/domain/entities/user_goals.dart';
import 'package:foodai/features/profile/presentation/providers/providers.dart';
import 'package:foodai/features/profile/presentation/widgets/widgets.dart';
import 'package:foodai/shared/widget/widgets.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final goalsState = ref.watch(goalsProvider);
    final user = authState.user;
    final UserGoals goals = goalsState.valueOrNull ?? const UserGoals();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Perfil de Usuario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF08273A),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDDC68F)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF5F2E8),
                      radius: 42,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(
                              Icons.person,
                              size: 42,
                              color: Color(0xFF08273A),
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.displayName ?? 'Usuario',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF08273A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? 'correo@example.com',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _GoalsSection(goalsState: goalsState, goals: goals),
              const SizedBox(height: 24),
              _LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalsSection extends ConsumerWidget {
  const _GoalsSection({required this.goalsState, required this.goals});

  final AsyncValue<UserGoals> goalsState;
  final UserGoals goals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis metas diarias',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF08273A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDC68F), width: 0.8),
          ),
          child: Column(
            children: [
              GoalsListTile(
                icon: Icons.local_fire_department_rounded,
                title: 'Calorías',
                value: goals.dailyCaloriesGoal,
                unit: 'kcal',
                iconBackgroundColor: const Color(0xFFDDC68F),
                valueBackgroundColor: const Color(0xFFF5F2E8),
                onTap: () => _editGoal(
                  context: context,
                  ref: ref,
                  title: 'Calorías',
                  unit: 'kcal',
                  initialValue: goals.dailyCaloriesGoal,
                  min: 500,
                  max: 5000,
                  onSave: (value) => goals.copyWith(dailyCaloriesGoal: value),
                ),
              ),
              _GoalsDivider(),
              GoalsListTile(
                icon: Icons.fitness_center,
                title: 'Proteínas',
                value: goals.dailyProteinGoal,
                unit: 'g',
                iconBackgroundColor: const Color(0xFFAABB96),
                valueBackgroundColor: const Color(0xFFF5F2E8),
                onTap: () => _editGoal(
                  context: context,
                  ref: ref,
                  title: 'Proteínas',
                  unit: 'g',
                  initialValue: goals.dailyProteinGoal,
                  min: 10,
                  max: 400,
                  onSave: (value) => goals.copyWith(dailyProteinGoal: value),
                ),
              ),
              _GoalsDivider(),
              GoalsListTile(
                icon: Icons.water_drop,
                title: 'Grasas',
                value: goals.dailyFatGoal,
                unit: 'g',
                iconBackgroundColor: const Color(0xFFDDC68F),
                valueBackgroundColor: const Color(0xFFF5F2E8),
                onTap: () => _editGoal(
                  context: context,
                  ref: ref,
                  title: 'Grasas',
                  unit: 'g',
                  initialValue: goals.dailyFatGoal,
                  min: 10,
                  max: 300,
                  onSave: (value) => goals.copyWith(dailyFatGoal: value),
                ),
              ),
              _GoalsDivider(),
              GoalsListTile(
                icon: Icons.grain,
                title: 'Carbohidratos',
                value: goals.dailyCarbsGoal,
                unit: 'g',
                iconBackgroundColor: const Color(0xFFAABB96),
                valueBackgroundColor: const Color(0xFFF5F2E8),
                onTap: () => _editGoal(
                  context: context,
                  ref: ref,
                  title: 'Carbohidratos',
                  unit: 'g',
                  initialValue: goals.dailyCarbsGoal,
                  min: 10,
                  max: 600,
                  onSave: (value) => goals.copyWith(dailyCarbsGoal: value),
                ),
              ),
            ],
          ),
        ),
        if (goalsState.isLoading) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(color: Color(0xFF08273A)),
        ],
        if (goalsState.hasError) ...[
          const SizedBox(height: 10),
          Text(
            'No se pudieron cargar las metas: ${goalsState.error}',
            style: const TextStyle(fontSize: 12, color: Colors.redAccent),
          ),
        ],
        const SizedBox(height: 14),
        GoalAssistantCard(
          onPressed: () {
            context.push('/profile/goal-assistant');
          },
        ),
      ],
    );
  }

  Future<void> _editGoal({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String unit,
    required int initialValue,
    required int min,
    required int max,
    required UserGoals Function(int value) onSave,
  }) async {
    final int? newValue = await showDialog<int>(
      context: context,
      builder: (context) => GoalEditDialog(
        title: title,
        unit: unit,
        initialValue: initialValue,
        min: min,
        max: max,
      ),
    );

    if (newValue == null || !context.mounted) {
      return;
    }

    try {
      await ref.read(goalsProvider.notifier).updateGoals(onSave(newValue));

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title actualizado correctamente.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar $title: $error')),
      );
    }
  }
}

class _GoalsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 0.6, color: Color(0xFFE6DDC8));
  }
}

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: CustomFilledButton(
        text: 'Cerrar Sesión',
        buttonColor: const Color(0xFF7D8B4E),
        onPressed: () async {
          // Mostrar diálogo de confirmación
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cerrar Sesión'),
              content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            await ref.read(authStateProvider.notifier).signOut();
          }
        },
      ),
    );
  }
}
