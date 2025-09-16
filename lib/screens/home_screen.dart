import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/habit_provider.dart';
import 'add_edit_habit_screen.dart'; // ✅ correct relative import

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider); // ✅ use the current provider name

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Habits"),
      ),
      body: habits.isEmpty
          ? const Center(
        child: Text(
          "No habits yet. Tap + to add one!",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];

          // Normalize "today"
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final completedToday = habit.completions.any((d) =>
          d.year == today.year &&
              d.month == today.month &&
              d.day == today.day);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Text(habit.emoji, style: const TextStyle(fontSize: 28)),
              title: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Target: ${habit.customStreakTarget} days"),
              trailing: Checkbox(
                value: completedToday,
                onChanged: (_) {
                  ref.read(habitsProvider.notifier).toggleCompletion(habit, DateTime.now());
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditHabitScreen(habit: habit), // ✅ class exists
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditHabitScreen(), // ✅ class exists
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
