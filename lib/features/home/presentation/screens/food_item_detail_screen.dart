import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/home/domain/entities/component.dart';
import 'package:foodai/features/home/domain/entities/food_item.dart';
import 'package:foodai/features/home/presentation/providers/food_detections_provider.dart';
import 'package:foodai/features/home/presentation/providers/food_item_update_provider.dart';
import 'package:go_router/go_router.dart';

class FoodItemDetailScreen extends ConsumerStatefulWidget {
  final FoodItem foodItem;

  const FoodItemDetailScreen({
    super.key,
    required this.foodItem,
  });

  @override
  ConsumerState<FoodItemDetailScreen> createState() =>
      _FoodItemDetailScreenState();
}

class _FoodItemDetailScreenState extends ConsumerState<FoodItemDetailScreen> {
  late TextEditingController _foodNameController;
  late String _selectedCategory;
  late List<Component> _components;
  final Set<int> _expandedComponents = {};

  @override
  void initState() {
    super.initState();
    _foodNameController =
        TextEditingController(text: widget.foodItem.foodName ?? '');
    _selectedCategory = widget.foodItem.category ?? 'DESAYUNO';
    _components = widget.foodItem.components
            ?.map((c) => Component(
                  id: c.id,
                  foodName: c.foodName,
                  quantityGrams: c.quantityGrams,
                  confidenceScore: c.confidenceScore,
                  nutritionalInfo: c.nutritionalInfo,
                  nutritionalDataFound: c.nutritionalDataFound,
                ))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Validate food name
    if (_foodNameController.text.trim().isEmpty) {
      _showErrorDialog('El nombre del plato no puede estar vacío');
      return;
    }

    // Validate quantity grams
    for (var component in _components) {
      if (component.quantityGrams == null || component.quantityGrams! <= 0) {
        _showErrorDialog(
            'La cantidad en gramos de "${component.foodName}" debe ser mayor a 0');
        return;
      }
    }

    final updatedFoodItem = FoodItem(
      id: widget.foodItem.id,
      foodName: _foodNameController.text.trim(),
      imageUrl: widget.foodItem.imageUrl,
      category: _selectedCategory,
      detectionDate: widget.foodItem.detectionDate,
      components: _components,
      totals: widget.foodItem.totals,
      createdAt: widget.foodItem.createdAt,
      updatedAt: widget.foodItem.updatedAt,
    );

    final result =
        await ref.read(foodItemUpdateProvider.notifier).updateFoodItem(updatedFoodItem);

    if (!mounted) return;

    if (result) {
      // Refresh food detections list
      ref.read(foodDetectionsProvider.notifier).refresh();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      _showErrorDialog('Error al guardar los cambios. Intenta nuevamente.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLoading = ref.watch(foodItemUpdateProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Detalle del plato',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!isLoading)
            IconButton(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              tooltip: 'Guardar cambios',
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Name (editable)
                TextField(
                  controller: _foodNameController,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Nombre del plato',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Category (dropdown)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: Color(0xFFFFFFFF),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'DESAYUNO', child: Text('Desayuno')),
                    DropdownMenuItem(value: 'ALMUERZO', child: Text('Almuerzo')),
                    DropdownMenuItem(value: 'CENA', child: Text('Cena')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Image
                if (widget.foodItem.imageUrl != null &&
                    widget.foodItem.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.foodItem.imageUrl!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    ),
                  )
                else
                  _buildImagePlaceholder(),
                const SizedBox(height: 24),
                
                // Totals Section
                _buildTotalsSection(colors),
                const SizedBox(height: 24),
                
                // Components Section
                _buildComponentsSection(colors),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
          
          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.restaurant,
        size: 80,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildTotalsSection(ColorScheme colors) {
    final totals = widget.foodItem.totals;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valores Totales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTotalItem(
                icon: Icons.local_fire_department,
                label: 'Calorías',
                value: '${(totals?.totalCalories ?? 0).toStringAsFixed(0)}kcal',
                color: Colors.orange[700]!,
              ),
              _buildTotalItem(
                icon: Icons.fitness_center,
                label: 'Proteínas',
                value: '${(totals?.totalProtein ?? 0).toStringAsFixed(1)}g',
                color: Colors.red[400]!,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTotalItem(
                icon: Icons.water_drop,
                label: 'Grasas',
                value: '${(totals?.totalFat ?? 0).toStringAsFixed(1)}g',
                color: Colors.yellow[700]!,
              ),
              _buildTotalItem(
                icon: Icons.grain,
                label: 'Carbohidratos',
                value: '${(totals?.totalCarbs ?? 0).toStringAsFixed(1)}g',
                color: Colors.green[600]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildComponentsSection(ColorScheme colors) {
    if (_components.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            'No hay componentes registrados',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalles por Alimento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _components.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final component = _components[index];
            final isExpanded = _expandedComponents.contains(index);
            
            return _buildComponentCard(
              component: component,
              index: index,
              isExpanded: isExpanded,
              colors: colors,
            );
          },
        ),
      ],
    );
  }

  Widget _buildComponentCard({
    required Component component,
    required int index,
    required bool isExpanded,
    required ColorScheme colors,
  }) {
    final quantityController = TextEditingController(
      text: component.quantityGrams?.toString() ?? '100',
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedComponents.remove(index);
                } else {
                  _expandedComponents.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.fastfood,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      component.foodName ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity (editable)
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Cantidad (gramos)',
                      border: const OutlineInputBorder(),
                      suffixText: 'g',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      final intValue = int.tryParse(value);
                      setState(() {
                        component.quantityGrams = intValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Confidence Score
                  if (component.confidenceScore != null)
                    _buildInfoRow(
                      'Confianza',
                      '${(component.confidenceScore! * 100).toStringAsFixed(0)}%',
                    ),
                  const SizedBox(height: 12),
                  
                  // Nutritional Info
                  if (component.nutritionalInfo != null) ...[
                    Text(
                      'Información Nutricional',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildNutritionalGrid(component.nutritionalInfo!),
                  ] else
                    Text(
                      'Sin información nutricional',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionalGrid(nutritionalInfo) {
    final items = [
      {'label': 'Calorías', 'value': '${nutritionalInfo.calories ?? 0}', 'unit': 'kcal'},
      {'label': 'Proteínas', 'value': '${nutritionalInfo.protein?.toStringAsFixed(1) ?? '0.0'}', 'unit': 'g'},
      {'label': 'Grasas', 'value': '${nutritionalInfo.fat?.toStringAsFixed(1) ?? '0.0'}', 'unit': 'g'},
      {'label': 'Carbohidratos', 'value': '${nutritionalInfo.carbs?.toStringAsFixed(1) ?? '0.0'}', 'unit': 'g'},
      {'label': 'Fibra', 'value': '${nutritionalInfo.fiber?.toStringAsFixed(1) ?? '0.0'}', 'unit': 'g'},
      {'label': 'Hierro', 'value': '${nutritionalInfo.iron?.toStringAsFixed(1) ?? '0.0'}', 'unit': 'mg'},
      {'label': 'Calcio', 'value': '${nutritionalInfo.calcium ?? 0}', 'unit': 'mg'},
      {'label': 'Vitamina C', 'value': '${nutritionalInfo.vitaminC?.toStringAsFixed(1) ?? '0.0'}', 'unit': 'mg'},
      {'label': 'Zinc', 'value': '${nutritionalInfo.zinc?.toStringAsFixed(1) ?? '0.0'}', 'unit': 'mg'},
      {'label': 'Potasio', 'value': '${nutritionalInfo.potassium ?? 0}', 'unit': 'mg'},
      {'label': 'Ácido Fólico', 'value': '${nutritionalInfo.folicAcid ?? 0}', 'unit': 'µg'},
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildNutritionalItem(
                    items[i]['label']!,
                    items[i]['value']!,
                    items[i]['unit']!,
                  ),
                ),
                const SizedBox(width: 8),
                if (i + 1 < items.length)
                  Expanded(
                    child: _buildNutritionalItem(
                      items[i + 1]['label']!,
                      items[i + 1]['value']!,
                      items[i + 1]['unit']!,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNutritionalItem(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value $unit',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
