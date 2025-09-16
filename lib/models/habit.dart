import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String emoji;

  @HiveField(3)
  final int? reminderHour;

  @HiveField(4)
  final int? reminderMinute;

  @HiveField(5)
  final int customStreakTarget; // defaulted in constructor

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final List<DateTime> completions;

  /// NEW: Persist total achievement points
  @HiveField(8)
  final int totalPoints;

  /// NEW: Persist earned medals
  @HiveField(9)
  final List<String> earnedMedals;

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    this.reminderHour,
    this.reminderMinute,
    this.customStreakTarget = 0,
    required this.createdAt,
    List<DateTime>? completions,
    this.totalPoints = 0,
    List<String>? earnedMedals,
  })  : completions = completions ?? [],
        earnedMedals = earnedMedals ?? [];

  // Normalize a DateTime to yyyy-mm-dd (strip time)
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Returns true if the habit was completed on [day].
  bool hasCompletion(DateTime day) {
    final n = _normalize(day);
    return completions.any((c) {
      final cn = _normalize(c);
      return cn.year == n.year && cn.month == n.month && cn.day == n.day;
    });
  }

  /// Current streak ending today (consecutive days up to today)
  int get currentStreak {
    if (completions.isEmpty) return 0;

    final normalizedSet =
    completions.map((d) => _normalize(d)).toSet(); // O(1) contains

    int streak = 0;
    DateTime day = _normalize(DateTime.now());

    while (normalizedSet.contains(day)) {
      streak += 1;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Alias: `.streak` used in some screens
  int get streak => currentStreak;

  /// Longest consecutive streak ever
  int get longestStreak {
    if (completions.isEmpty) return 0;

    final normalizedList = completions
        .map((d) => _normalize(d))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    int best = 1;
    int current = 1;

    for (int i = 1; i < normalizedList.length; i++) {
      final diff =
          normalizedList[i].difference(normalizedList[i - 1]).inDays;
      if (diff == 1) {
        current += 1;
        if (current > best) best = current;
      } else if (diff == 0) {
        // same day duplicate - ignore
      } else {
        current = 1;
      }
    }

    return best;
  }

  /// Alias used in some screens
  int get bestStreak => longestStreak;
}
