import 'package:flutter/material.dart';

class GoalEditDialog extends StatefulWidget {
  const GoalEditDialog({
    super.key,
    required this.title,
    required this.unit,
    required this.initialValue,
    required this.min,
    required this.max,
  });

  final String title;
  final String unit;
  final int initialValue;
  final int min;
  final int max;

  @override
  State<GoalEditDialog> createState() => _GoalEditDialogState();
}

class _GoalEditDialogState extends State<GoalEditDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Editar ${widget.title.toLowerCase()}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF08273A),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresa un valor entre ${widget.min} y ${widget.max} ${widget.unit}.',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: (_) => _validate(),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F2E8),
              suffixText: widget.unit,
              errorText: _errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF7D8B4E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF7D8B4E),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFF7D8B4E)),
          ),
        ),
        FilledButton(
          onPressed: () {
            final int? value = _validate();
            if (value != null) {
              Navigator.of(context).pop(value);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF08273A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  int? _validate() {
    final int? value = int.tryParse(_controller.text.trim());

    setState(() {
      if (value == null) {
        _errorText = 'Ingresa un numero valido';
      } else if (value < widget.min || value > widget.max) {
        _errorText = 'Debe estar entre ${widget.min} y ${widget.max}';
      } else {
        _errorText = null;
      }
    });

    if (_errorText != null) {
      return null;
    }

    return value;
  }
}
