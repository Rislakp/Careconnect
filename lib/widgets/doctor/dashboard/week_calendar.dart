import 'package:flutter/material.dart';

class WeekCalendar extends StatelessWidget {
  final List<DateTime> weekDates;
  final int selectedIndex;
  final Function(int) onSelect;

  const WeekCalendar({
    super.key,
    required this.weekDates,
    required this.selectedIndex,
    required this.onSelect,
  });

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayShort(DateTime d) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[d.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final d = weekDates[index];
          final selected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              width: 75,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    selected ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? Colors.blue
                      : Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  Text(_weekdayShort(d)),
                  Text(
                    d.day.toString(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_sameDate(d, DateTime.now()))
                    const Text("Today",
                        style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
