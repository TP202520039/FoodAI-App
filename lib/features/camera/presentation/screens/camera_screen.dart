import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/camera/presentation/providers/camera_provider.dart';
import 'package:foodai/features/home/presentation/providers/selected_date_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _cameraController;
  String _selectedCategory = 'DESAYUNO';
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await ref.read(camerasProvider.future);
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      await _analyzeImage(image.path);
    } catch (e) {
      _showErrorDialog('Error al capturar la imagen: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        await _analyzeImage(image.path);
      }
    } catch (e) {
      _showErrorDialog('Error al seleccionar la imagen: $e');
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
    final selectedDate = ref.read(selectedDateProvider);
    final dateString =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    await ref.read(foodImageAnalysisProvider.notifier).analyzeImage(
          imagePath: imagePath,
          category: _selectedCategory,
          detectionDate: dateString,
        );

    if (!mounted) return;

    final analysisState = ref.read(foodImageAnalysisProvider);

    analysisState.when(
      data: (foodItem) {
        if (foodItem != null) {
          // Navigate to detail screen
          ref.read(foodImageAnalysisProvider.notifier).reset();
          context.push('/home/food-item-detail', extra: foodItem);
        }
      },
      loading: () {},
      error: (error, stack) {
        _showErrorDialog(
          'No se pudo analizar la imagen. Verifica tu conexión e intenta nuevamente.',
        );
      },
    );
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
    final analysisState = ref.watch(foodImageAnalysisProvider);
    final isAnalyzing = analysisState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Title
                const Text(
                  'REGISTRA TU COMIDA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Color(0xFF583C1C),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Category chips
                _buildCategoryChips(),
                const SizedBox(height: 24),
                
                // Camera preview (circular)
                Expanded(
                  child: Center(
                    child: _buildCameraPreview(),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Capture and gallery buttons
                SizedBox(
                  height: 80,
                  child: Stack(
                    children: [
                      // Capture button (centered in Column)
                      Center(
                        child: GestureDetector(
                          onTap: _captureImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF5F2E8),
                              border: Border.all(
                                color: const Color(0xFF7D8B4E),
                                width: 4,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF7D8B4E),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gallery button (to the right of center)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 220),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF5F2E8)
                            ),
                            child: IconButton(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library),
                              iconSize: 28,
                              color: Color(0xFF7D8B4E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // Loading overlay
          if (isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analizando tu comida...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCategoryChip('DESAYUNO', 'Desayuno'),
        const SizedBox(width: 12),
        _buildCategoryChip('ALMUERZO', 'Almuerzo'),
        const SizedBox(width: 12),
        _buildCategoryChip('CENA', 'Cena'),
      ],
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFFF5F2E8) : const Color(0xFF7D8B4E),
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
      selectedColor: const Color(0xFF7D8B4E),
      backgroundColor: const Color(0xFFF5F2E8),
      side: BorderSide(
        color: const Color(0xFF7D8B4E),
        width: isSelected ? 2.0 : 1.5,
      ),
      checkmarkColor: const Color(0xFFF5F2E8),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: 300,
        height: 300,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraController!.value.previewSize!.height,
            height: _cameraController!.value.previewSize!.width,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }
}