import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateSelector({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: const Color(0xFF3fc97c),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Date',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != selectedDate) {
                  onDateChanged(picked);
                }
              },
              icon: const Icon(Icons.edit_calendar),
            ),
          ],
        ),
      ),
    );
  }
}
