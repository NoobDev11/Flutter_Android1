import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

/// ✅ Wrapper screen shown in bottom nav
/// Lets user pick a habit before opening Calendar
class CalendarScreenWrapper extends ConsumerWidget {
  const CalendarScreenWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    if (habits.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No habits available. Please add one first."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Select Habit Calendar")),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return ListTile(
            leading: Text(habit.emoji, style: const TextStyle(fontSize: 24)),
            title: Text(habit.name),
            subtitle: const Text("Tap to view calendar"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarScreen(habit: habit),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ✅ Actual calendar screen for a single habit
class CalendarScreen extends StatefulWidget {
  final Habit habit;

  const CalendarScreen({super.key, required this.habit});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    // Normalize completions to just YYYY-MM-DD
    final completedDays = widget.habit.completions
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    return Scaffold(
      appBar: AppBar(title: Text("${widget.habit.emoji} ${widget.habit.name}")),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, _) {
            final normalized = DateTime(day.year, day.month, day.day);
            if (completedDays.contains(normalized)) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  "${day.day}",
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }
            return null;
          },
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
