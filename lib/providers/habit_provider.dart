import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

final habitServiceProvider = Provider<HabitService>((ref) {
  return HabitService();
});

final habitsProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final service = ref.watch(habitServiceProvider);
  return HabitNotifier(service);
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  final HabitService _service;

  HabitNotifier(this._service) : super([]) {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    state = await _service.getHabits();
  }

  Future<void> addHabit(Habit habit) async {
    await _service.addHabit(habit);
    await _loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    await _service.updateHabit(habit);
    await _loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    await _service.deleteHabit(id);
    await _loadHabits();
  }

  Future<void> toggleCompletion(Habit habit, DateTime date) async {
    await _service.toggleCompletion(habit, date);
    await _loadHabits();
  }
}
