import 'package:flutter/material.dart';
import '../services/url_utils.dart';

class SettingsPage extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  final String currentIcsUrl;
  final Function(String) onIcsUrlChanged;

  final bool useTimetableView;
  final Function(bool) onTimetableChanged;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.currentIcsUrl,
    required this.onIcsUrlChanged,
    required this.useTimetableView,
    required this.onTimetableChanged,
  });

  /*
  Appearance
  - Theme mode dropdown
  - Timetable view toggle

Calendar
  - ICS URL
  - Add calendar
  - Refresh calendar

About
  - Version
  - Licenses
   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // -------------------------
          // Appearance Section
          // -------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "Appearance",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          ListTile(
            title: const Text("Theme"),
            subtitle: Text(currentThemeMode.name),
            trailing: DropdownButton<ThemeMode>(
              value: currentThemeMode,
              onChanged: (mode) {
                if (mode != null) onThemeChanged(mode);
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text("System"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text("Light"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text("Dark"),
                ),
              ],
            ),
          ),

          SwitchListTile(
            title: Text("Timetable View (BETA)"),
            subtitle: Text("Show events in an hour-by-hour grid"),
            value: useTimetableView,
            onChanged: (value) {
              onTimetableChanged(value);
            },
          ),

          const Divider(height: 32),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              "Calendar",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          ListTile(
            title: const Text("Calendar URL"),
            subtitle: Text(currentIcsUrl),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // open dialog to edit ICS URL
              _editIcsUrl(context);
            },
          ),

          ListTile(
            title: const Text("Refresh Calendar"),
            leading: const Icon(Icons.refresh),
            onTap: () {
              // You can trigger refresh from HomePage or CalendarPage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Refreshing Calendar...")),
              );
            },
          ),

          const Divider(height: 32),

          // -------------------------
          // About Section
          // -------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              "About",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          ListTile(title: const Text("Version"), subtitle: const Text("1.0.0")),

          ListTile(
            title: const Text("Licenses"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context),
          ),

          const Divider(height: 32),

          ListTile(title: const Text(""), subtitle: const Text("Made By Your ITA-25 Course ❤️")),
        ],
      ),
    );
  }

  void _editIcsUrl(BuildContext context) {
    final controller = TextEditingController(text: currentIcsUrl);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Calendar URL"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "ICS URL",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              onIcsUrlChanged(normalizeIcsUrl(controller.text.trim()));
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
