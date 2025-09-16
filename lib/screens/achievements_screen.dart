import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    int totalPoints = 0;
    int totalMedals = 0;
    int highestStreak = 0;
    String mostRecentMedal = "None";

    List<Widget> habitAchievements = [];

    for (var habit in habits) {
      // ✅ Use persisted medals/points instead of recalculating
      final points = habit.totalPoints;
      final medals = habit.earnedMedals;

      totalPoints += points;
      totalMedals += medals.length;

      if (habit.streak > highestStreak) {
        highestStreak = habit.streak;
      }
      if (medals.isNotEmpty) {
        mostRecentMedal = medals.last;
      }

      habitAchievements.add(
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Text(habit.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(habit.name),
            subtitle: Text("Streak: ${habit.streak} days"),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Points: $points"),
                Text("Medals: ${medals.length}"),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Overall Summary",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Total Points: $totalPoints"),
                  Text("Total Medals: $totalMedals"),
                  Text("Highest Streak: $highestStreak days"),
                  Text("Most Recent Medal: $mostRecentMedal"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Habit Achievements",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...habitAchievements,
        ],
      ),
    );
  }
}
