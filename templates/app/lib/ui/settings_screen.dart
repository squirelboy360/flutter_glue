import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic> args;

  const SettingsScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FTheme(
      data: theme.brightness == Brightness.dark 
          ? FThemes.zinc.dark 
          : FThemes.zinc.light,
      child: FScaffold(
        contentPad: false,
        content: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  // Add your settings items here
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: theme.brightness == Brightness.dark,
                      onChanged: (value) {
                        // Implement theme switching
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle notifications tap
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
