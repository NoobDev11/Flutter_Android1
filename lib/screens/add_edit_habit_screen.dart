import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final Habit? habit;
  const AddEditHabitScreen({super.key, this.habit});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emojiController;
  late TextEditingController _targetController;
  int? reminderHour;
  int? reminderMinute;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? "");
    _emojiController = TextEditingController(text: widget.habit?.emoji ?? "🔥");
    _targetController = TextEditingController(
        text: widget.habit?.customStreakTarget.toString() ?? "7");
    reminderHour = widget.habit?.reminderHour;
    reminderMinute = widget.habit?.reminderMinute;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final newHabit = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      name: _nameController.text,
      emoji: _emojiController.text,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      customStreakTarget: int.tryParse(_targetController.text) ?? 7,
      createdAt: widget.habit?.createdAt ?? DateTime.now(),
      completions: widget.habit?.completions ?? [],
    );

    if (widget.habit == null) {
      ref.read(habitsProvider.notifier).addHabit(newHabit);
    } else {
      ref.read(habitsProvider.notifier).updateHabit(newHabit);
    }

    Navigator.pop(context);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: reminderHour ?? 8,
        minute: reminderMinute ?? 0,
      ),
    );
    if (picked != null) {
      setState(() {
        reminderHour = picked.hour;
        reminderMinute = picked.minute;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? "Add Habit" : "Edit Habit"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveHabit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emojiController,
                decoration: const InputDecoration(labelText: "Emoji"),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Habit Name"),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter a name" : null,
              ),
              TextFormField(
                controller: _targetController,
                decoration: const InputDecoration(labelText: "Streak Target (days)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(reminderHour == null
                    ? "No Reminder"
                    : "Reminder: ${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}"),
                trailing: TextButton(
                  onPressed: _pickReminderTime,
                  child: const Text("Pick Time"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
