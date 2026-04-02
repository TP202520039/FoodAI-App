import 'package:flutter/material.dart';

class GoalsListTile extends StatelessWidget {
  const GoalsListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.iconBackgroundColor,
    required this.valueBackgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int value;
  final String unit;
  final Color iconBackgroundColor;
  final Color valueBackgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF08273A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF08273A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Meta diaria',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: valueBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value $unit',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF08273A),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB4A17B),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
