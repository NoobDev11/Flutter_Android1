import 'package:hive/hive.dart';
import '../models/habit.dart';

class HabitService {
  static const String _boxName = "habits";

  Future<Box<Habit>> _openBox() async {
    return await Hive.openBox<Habit>(_boxName);
  }

  Future<List<Habit>> getHabits() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> addHabit(Habit habit) async {
    final box = await _openBox();
    await box.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    final box = await _openBox();
    await box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  /// Toggle completion for [date] (normalized to yyyy-mm-dd).
  /// Returns the updated Habit (saved to Hive).
  Future<Habit> toggleCompletion(Habit habit, DateTime date) async {
    final box = await _openBox();

    // Normalize the date to year-month-day (no time).
    final normalized = DateTime(date.year, date.month, date.day);

    // Work on a copy of the completions
    final currentSet = habit.completions
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    final bool alreadyHad = currentSet.contains(normalized);
    bool added;
    if (alreadyHad) {
      currentSet.remove(normalized);
      added = false;
    } else {
      currentSet.add(normalized);
      added = true;
    }

    // Build a sorted list
    final updatedCompletions = currentSet.toList()..sort((a, b) => a.compareTo(b));

    // Prev/current streaks
    final int prevStreak = habit.currentStreak;
    final int currStreak = _calculateStreakFromList(updatedCompletions);

    // Copy existing medals/points
    final updatedMedals = List<String>.from(habit.earnedMedals);
    int updatedPoints = habit.totalPoints;

    // Only award when a completion was added (not on removal)
    if (added) {
      // Check milestone crossings and award if needed
      final rewards = _computeMilestoneRewards(prevStreak, currStreak, habit.customStreakTarget);
      for (final r in rewards) {
        final String medal = r['medal'] as String;
        final int pts = r['points'] as int;
        if (!updatedMedals.contains(medal)) {
          updatedMedals.add(medal);
          updatedPoints += pts;
        }
      }
    }

    final updatedHabit = Habit(
      id: habit.id,
      name: habit.name,
      emoji: habit.emoji,
      reminderHour: habit.reminderHour,
      reminderMinute: habit.reminderMinute,
      customStreakTarget: habit.customStreakTarget,
      createdAt: habit.createdAt,
      completions: updatedCompletions,
      totalPoints: updatedPoints,
      earnedMedals: updatedMedals,
    );

    await box.put(updatedHabit.id, updatedHabit);
    return updatedHabit;
  }

  // Helper: compute streak (consecutive days) ending at the most recent completion
  int _calculateStreakFromList(List<DateTime> completions) {
    if (completions.isEmpty) return 0;

    // Sort descending (latest first)
    final list = completions
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 1;
    DateTime prev = list[0];

    for (int i = 1; i < list.length; i++) {
      final curr = list[i];
      final diff = prev.difference(curr).inDays;
      if (diff == 1) {
        streak++;
        prev = curr;
      } else if (diff == 0) {
        // duplicate day (shouldn't happen after normalization), ignore
        prev = curr;
      } else {
        break;
      }
    }

    return streak;
  }

  // Milestones definition
  static const Map<int, Map<String, Object>> _milestones = {
    3: {'points': 5, 'medal': '🥉 Streak 3'},
    7: {'points': 10, 'medal': '🥉 Streak 7'},
    15: {'points': 15, 'medal': '🥈 Streak 15'},
    30: {'points': 20, 'medal': '🥈 Streak 30'},
    60: {'points': 30, 'medal': '🥇 Streak 60'},
    90: {'points': 50, 'medal': '🥇 Streak 90'},
    180: {'points': 75, 'medal': '💎 Streak 180'},
    365: {'points': 100, 'medal': '🏆 Streak 365'},
  };

  /// Determine which rewards should be given when streak changes from prev->curr
  List<Map<String, Object>> _computeMilestoneRewards(int prev, int curr, int customTarget) {
    final List<Map<String, Object>> rewards = [];

    final milestones = _milestones.keys.toList()..sort();
    for (final m in milestones) {
      if (prev < m && curr >= m) {
        rewards.add({
          'points': _milestones[m]!['points'] as int,
          'medal': _milestones[m]!['medal'] as String,
        });
      }
    }

    if (customTarget > 0 && prev < customTarget && curr >= customTarget) {
      rewards.add({'points': 50, 'medal': '🎯 Custom Target ($customTarget d)'});
    }

    return rewards;
  }
}
