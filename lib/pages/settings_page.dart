import 'package:flutter/material.dart';
import '../services/url_utils.dart';
import '../widgets/card_widget.dart';

class SettingsPage extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  final String currentIcsUrl;
  final Function(String) onIcsUrlChanged;

  final bool useTimetableView;
  final Function(bool) onTimetableChanged;

  final bool oledMode;
  final Function(bool) onOledModeChanged;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.currentIcsUrl,
    required this.onIcsUrlChanged,
    required this.useTimetableView,
    required this.onTimetableChanged,
    required this.oledMode,
    required this.onOledModeChanged,
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
          // THEME MODE
          SettingsCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Theme", style: TextStyle(fontSize: 16)),
                DropdownButton<ThemeMode>(
                  value: currentThemeMode,
                  borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ),

          // OLED MODE
          SettingsCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "OLED black mode",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Switch(value: oledMode, onChanged: onOledModeChanged),
              ],
            ),
          ),

          // TIMETABLE MODE
          SettingsCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Timetable View (BETA)",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Switch(value: useTimetableView, onChanged: onTimetableChanged),
              ],
            ),
          ),

          // ICS URL
          SettingsCard(
            onTap: () => _editIcsUrl(context),
            child: Row(
              children: [
                const Icon(Icons.link),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(currentIcsUrl, overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),

          SettingsCard(
            onTap: () {
              onThemeChanged(ThemeMode.system);
              onTimetableChanged(false);
              onOledModeChanged(false);
              onIcsUrlChanged("https://dhbw.app/ical/STG-TINF25H-ITA.ics");

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings reset to defaults")),
              );
            },
            child: Row(
              children: const [
                Icon(Icons.restore),
                SizedBox(width: 16),
                Text("Reset to defaults", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // VERSION
          SettingsCard(
            child: Row(
              children: const [
                Icon(Icons.info_outline),
                SizedBox(width: 16),
                Text("Version 1.0.0", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // LICENSES
          SettingsCard(
            onTap: () => showLicensePage(context: context),
            child: Row(
              children: const [
                Icon(Icons.description),
                SizedBox(width: 16),
                Expanded(
                  child: Text("Licenses", style: TextStyle(fontSize: 16)),
                ),
                Icon(Icons.chevron_right),
              ],
            ),
          ),

          // FOOTER
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "🚀 Made by Jan Saeisih, ITA‑25",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
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
          showCursor: true,
          autocorrect: false,
          enabled: true,
          controller: controller,
          decoration: const InputDecoration(labelText: "ICS URL"),
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
