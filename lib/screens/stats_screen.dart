import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import '../models/habit.dart';
import '../providers/habit_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  /// Calculate current streak
  int _calculateCurrentStreak(List<DateTime> completions) {
    if (completions.isEmpty) return 0;

    final normalized = completions
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime currentDay = DateTime(today.year, today.month, today.day);

    for (int i = normalized.length - 1; i >= 0; i--) {
      if (normalized[i] == currentDay.subtract(Duration(days: streak))) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Calculate longest streak
  int _calculateLongestStreak(List<DateTime> completions) {
    if (completions.isEmpty) return 0;

    final normalized = completions
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    int longest = 1;
    int current = 1;

    for (int i = 1; i < normalized.length; i++) {
      if (normalized[i].difference(normalized[i - 1]).inDays == 1) {
        current++;
        longest = current > longest ? current : longest;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    if (habits.isEmpty) {
      return const Center(
        child: Text("No habits yet. Start building your streaks!"),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
      ),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          final currentStreak = _calculateCurrentStreak(habit.completions);
          final longestStreak = _calculateLongestStreak(habit.completions);
          final target = habit.customStreakTarget; // ✅ always safe

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: Text(
                habit.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              title: Text(
                habit.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total completions: ${habit.completions.length}"),
                  Text("Current streak: $currentStreak days"),
                  Text("Longest streak: $longestStreak days"),
                  Text("Streak target: $target days"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
