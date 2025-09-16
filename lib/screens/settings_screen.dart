import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              subtitle: const Text("Toggle between light and dark themes"),
              value: themeMode == ThemeMode.dark, // ✅ bool conversion
              onChanged: (isDark) {
                ref.read(themeProvider.notifier).state =
                isDark ? ThemeMode.dark : ThemeMode.light; // ✅ direct state update
              },
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("App Info"),
              subtitle: const Text("Minimal Habit Tracker 1.03.04092025"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Minimal Habit Tracker",
                  applicationVersion: "1.03.04092025 (beta)",
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
