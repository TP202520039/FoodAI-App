import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/profile/domain/entities/user_goals.dart';
import 'package:foodai/features/profile/presentation/providers/providers.dart';

enum GoalAssistantGender { male, female }

enum GoalAssistantActivity { sedentary, light, moderate, veryActive }

enum GoalAssistantObjective { loseWeight, maintainWeight, gainMuscle }

class GoalAssistantScreen extends ConsumerStatefulWidget {
  const GoalAssistantScreen({super.key});

  @override
  ConsumerState<GoalAssistantScreen> createState() =>
      _GoalAssistantScreenState();
}

class _GoalAssistantScreenState extends ConsumerState<GoalAssistantScreen> {
  static const Color _primaryColor = Color(0xFF08273A);
  static const Color _accentColor = Color(0xFF7D8B4E);
  static const Color _softColor = Color(0xFFF5F2E8);
  static const Color _borderColor = Color(0xFFDDC68F);
  static const Color _completedColor = Color(0xFFAABB96);

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  int _currentStep = 0;
  GoalAssistantGender? _gender;
  GoalAssistantActivity? _activity;
  GoalAssistantObjective? _objective;
  _GoalAssistantResult? _result;
  bool _isSaving = false;

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: _primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Calcular mi meta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: _AssistantProgressIndicator(currentStep: _currentStep),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPhysicalDataStep();
      case 1:
        return _buildActivityStep();
      case 2:
        return _buildObjectiveStep();
      case 3:
        return _buildResultStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhysicalDataStep() {
    return Column(
      key: const ValueKey('physical-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paso 1 - Datos físicos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Necesitamos unos datos básicos para estimar tu gasto calórico diario.',
          style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        const Text(
          'Género',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SelectionCard(
                label: 'Hombre',
                selected: _gender == GoalAssistantGender.male,
                onTap: () => setState(() => _gender = GoalAssistantGender.male),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SelectionCard(
                label: 'Mujer',
                selected: _gender == GoalAssistantGender.female,
                onTap: () =>
                    setState(() => _gender = GoalAssistantGender.female),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _LabeledNumberField(
          label: 'Edad',
          controller: _ageController,
          unit: 'años',
        ),
        const SizedBox(height: 14),
        _LabeledNumberField(
          label: 'Peso',
          controller: _weightController,
          unit: 'kg',
        ),
        const SizedBox(height: 14),
        _LabeledNumberField(
          label: 'Altura',
          controller: _heightController,
          unit: 'cm',
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _goToActivityStep,
            style: FilledButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Siguiente'),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityStep() {
    return Column(
      key: const ValueKey('activity-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paso 2 - Actividad',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Elige el nivel que mejor describe tu actividad física semanal.',
          style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        ...GoalAssistantActivity.values.map(
          (activity) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionTile(
              title: _activityTitle(activity),
              description: _activityDescription(activity),
              icon: _activityIcon(activity),
              selected: _activity == activity,
              onTap: () => setState(() => _activity = activity),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(color: _borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Atras'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _goToObjectiveStep,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildObjectiveStep() {
    return Column(
      key: const ValueKey('objective-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paso 3 - Objetivo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Selecciona el objetivo principal que quieres lograr con tu alimentación.',
          style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        ...GoalAssistantObjective.values.map(
          (objective) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionTile(
              title: _objectiveTitle(objective),
              description: _objectiveDescription(objective),
              icon: _objectiveIcon(objective),
              selected: _objective == objective,
              onTap: () => setState(() => _objective = objective),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(color: _borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Atras'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _calculateGoals,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Calcular'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultStep() {
    final _GoalAssistantResult result = _result!;
    final UserGoals currentGoals =
        ref.watch(goalsProvider).value ?? const UserGoals();

    return Column(
      key: const ValueKey('result-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu meta diaria',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Calculada según tus datos y lista para guardarse en tu perfil.',
          style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _softColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            children: [
              const Text(
                'CALORÍAS DIARIAS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${result.dailyCalories} kcal',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ResultMacroCard(
                label: 'Proteínas',
                value: '${result.dailyProtein} g',
                color: _accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ResultMacroCard(
                label: 'Grasas',
                value: '${result.dailyFat} g',
                color: _borderColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ResultMacroCard(
                label: 'Carbs',
                value: '${result.dailyCarbs} g',
                color: _completedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1E3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Podrás ajustar estos valores manualmente desde tu perfil cuando quieras.',
            style: TextStyle(fontSize: 12, height: 1.4, color: _accentColor),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(color: _borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Atras'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving
                    ? null
                    : () => _saveGoals(
                        currentGoals.copyWith(
                          dailyCaloriesGoal: result.dailyCalories,
                          dailyProteinGoal: result.dailyProtein,
                          dailyFatGoal: result.dailyFat,
                          dailyCarbsGoal: result.dailyCarbs,
                        ),
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar mis metas'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _goToActivityStep() {
    if (_gender == null) {
      _showError('Selecciona tu género.');
      return;
    }

    final int? age = int.tryParse(_ageController.text.trim());
    final double? weight = double.tryParse(_weightController.text.trim());
    final double? height = double.tryParse(_heightController.text.trim());

    if (age == null || age < 10 || age > 100) {
      _showError('Ingresa una edad válida entre 10 y 100 años.');
      return;
    }

    if (weight == null || weight < 20 || weight > 300) {
      _showError('Ingresa un peso válido entre 20 y 300 kg.');
      return;
    }

    if (height == null || height < 100 || height > 250) {
      _showError('Ingresa una altura válida entre 100 y 250 cm.');
      return;
    }

    setState(() => _currentStep = 1);
  }

  void _goToObjectiveStep() {
    if (_activity == null) {
      _showError('Selecciona tu nivel de actividad.');
      return;
    }

    setState(() => _currentStep = 2);
  }

  void _calculateGoals() {
    if (_objective == null || _activity == null || _gender == null) {
      _showError('Completa los pasos anteriores antes de calcular.');
      return;
    }

    final int age = int.parse(_ageController.text.trim());
    final double weight = double.parse(_weightController.text.trim());
    final double height = double.parse(_heightController.text.trim());

    final double bmr = _gender == GoalAssistantGender.male
        ? 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age)
        : 447.6 + (9.25 * weight) + (3.1 * height) - (4.33 * age);

    final double maintenanceCalories = bmr * _activityFactor(_activity!);
    final double targetCalories =
        maintenanceCalories + _objectiveAdjustment(_objective!);
    final int dailyCalories = targetCalories.round().clamp(500, 5000);
    final int dailyProtein = ((dailyCalories * 0.25) / 4).round().clamp(
      10,
      400,
    );
    final int dailyFat = ((dailyCalories * 0.30) / 9).round().clamp(10, 300);
    final int dailyCarbs = ((dailyCalories * 0.45) / 4).round().clamp(10, 600);

    setState(() {
      _result = _GoalAssistantResult(
        dailyCalories: dailyCalories,
        dailyProtein: dailyProtein,
        dailyFat: dailyFat,
        dailyCarbs: dailyCarbs,
      );
      _currentStep = 3;
    });
  }

  Future<void> _saveGoals(UserGoals goals) async {
    setState(() => _isSaving = true);

    try {
      await ref.read(goalsProvider.notifier).updateGoals(goals);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metas guardadas correctamente.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron guardar las metas: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  double _activityFactor(GoalAssistantActivity activity) {
    switch (activity) {
      case GoalAssistantActivity.sedentary:
        return 1.2;
      case GoalAssistantActivity.light:
        return 1.375;
      case GoalAssistantActivity.moderate:
        return 1.55;
      case GoalAssistantActivity.veryActive:
        return 1.725;
    }
  }

  int _objectiveAdjustment(GoalAssistantObjective objective) {
    switch (objective) {
      case GoalAssistantObjective.loseWeight:
        return -500;
      case GoalAssistantObjective.maintainWeight:
        return 0;
      case GoalAssistantObjective.gainMuscle:
        return 300;
    }
  }

  String _activityTitle(GoalAssistantActivity activity) {
    switch (activity) {
      case GoalAssistantActivity.sedentary:
        return 'Sedentario';
      case GoalAssistantActivity.light:
        return 'Ligero';
      case GoalAssistantActivity.moderate:
        return 'Moderado';
      case GoalAssistantActivity.veryActive:
        return 'Muy activo';
    }
  }

  String _activityDescription(GoalAssistantActivity activity) {
    switch (activity) {
      case GoalAssistantActivity.sedentary:
        return 'Poco o nada de ejercicio';
      case GoalAssistantActivity.light:
        return '1 a 3 días por semana';
      case GoalAssistantActivity.moderate:
        return '3 a 5 días por semana';
      case GoalAssistantActivity.veryActive:
        return '6 a 7 días por semana';
    }
  }

  IconData _activityIcon(GoalAssistantActivity activity) {
    switch (activity) {
      case GoalAssistantActivity.sedentary:
        return Icons.weekend_rounded;
      case GoalAssistantActivity.light:
        return Icons.directions_walk_rounded;
      case GoalAssistantActivity.moderate:
        return Icons.directions_run_rounded;
      case GoalAssistantActivity.veryActive:
        return Icons.fitness_center_rounded;
    }
  }

  String _objectiveTitle(GoalAssistantObjective objective) {
    switch (objective) {
      case GoalAssistantObjective.loseWeight:
        return 'Perder peso';
      case GoalAssistantObjective.maintainWeight:
        return 'Mantener peso';
      case GoalAssistantObjective.gainMuscle:
        return 'Ganar músculo';
    }
  }

  String _objectiveDescription(GoalAssistantObjective objective) {
    switch (objective) {
      case GoalAssistantObjective.loseWeight:
        return 'Déficit calórico aproximado de 500 kcal';
      case GoalAssistantObjective.maintainWeight:
        return 'Mantener tu consumo actual';
      case GoalAssistantObjective.gainMuscle:
        return 'Superávit calórico aproximado de 300 kcal';
    }
  }

  IconData _objectiveIcon(GoalAssistantObjective objective) {
    switch (objective) {
      case GoalAssistantObjective.loseWeight:
        return Icons.trending_down_rounded;
      case GoalAssistantObjective.maintainWeight:
        return Icons.balance_rounded;
      case GoalAssistantObjective.gainMuscle:
        return Icons.trending_up_rounded;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AssistantProgressIndicator extends StatelessWidget {
  const _AssistantProgressIndicator({required this.currentStep});

  final int currentStep;

  static const Color _primaryColor = Color(0xFF08273A);
  static const Color _activeColor = Color(0xFF7D8B4E);
  static const Color _pendingColor = Color(0xFFDDC68F);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final bool isCompleted = index < currentStep;
        final bool isActive = index == currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  color: index == 0
                      ? Colors.transparent
                      : isCompleted || isActive
                      ? _primaryColor
                      : _pendingColor,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? _primaryColor
                      : isActive
                      ? _activeColor
                      : _pendingColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  index == 3 ? '✓' : '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF1E3) : const Color(0xFFF5F2E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7D8B4E)
                  : const Color(0xFFDDC68F),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF08273A),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledNumberField extends StatelessWidget {
  const _LabeledNumberField({
    required this.label,
    required this.controller,
    required this.unit,
  });

  final String label;
  final TextEditingController controller;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF08273A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F2E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDC68F)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFFDDC68F))),
                ),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF08273A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF1E3) : const Color(0xFFF5F2E8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7D8B4E)
                  : const Color(0xFFDDC68F),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF08273A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF08273A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF7D8B4E)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF7D8B4E)
                        : const Color(0xFFDDC68F),
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultMacroCard extends StatelessWidget {
  const _ResultMacroCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _GoalAssistantResult {
  const _GoalAssistantResult({
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyFat,
    required this.dailyCarbs,
  });

  final int dailyCalories;
  final int dailyProtein;
  final int dailyFat;
  final int dailyCarbs;
}
