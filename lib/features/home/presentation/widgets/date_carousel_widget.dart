import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodai/features/home/presentation/providers/selected_date_provider.dart';

class DateCarouselWidget extends ConsumerStatefulWidget {
  const DateCarouselWidget({super.key});

  @override
  ConsumerState<DateCarouselWidget> createState() => _DateCarouselWidgetState();
}

class _DateCarouselWidgetState extends ConsumerState<DateCarouselWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Mostrar el calendario popup
  Future<void> _showCalendarPicker() async {
    final selectedDate = ref.read(selectedDateProvider);
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7D8B4E), // Color principal
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      ref.read(selectedDateProvider.notifier).state = pickedDate;
    }
  }

  /// Generar lista de fechas (3 días antes, hoy, 3 días después)
  List<DateTime> _generateDates(DateTime centerDate) {
    List<DateTime> dates = [];
    for (int i = -3; i <= 3; i++) {
      dates.add(centerDate.add(Duration(days: i)));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dates = _generateDates(selectedDate);

    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          
          return DateCard(
            date: date,
            isSelected: isSelected,
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = date;
            },
            onLongPress: _showCalendarPicker,
          );
        },
      ),
    );
  }
}

class DateCard extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DateCard({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  /// Determinar si la fecha es hoy
  bool get isToday => DateUtils.isSameDay(date, DateTime.now());

  /// Formatear el día de la semana en español
  String get dayOfWeek {
    if (isToday) return 'HOY';
    
    final weekDays = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return weekDays[date.weekday - 1];
  }

  /// Formatear el mes en español
  String get monthName {
    final months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7D8B4E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF7D8B4E) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayOfWeek,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF7D8B4E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              monthName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
