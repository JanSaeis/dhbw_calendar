import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  final String icsUrl;
  final Function(String) onIcsUrlChanged;

  final Function(bool) onTimetableChanged;
  final bool useTimetableView;

  final bool oledMode;
  final Function(bool) onOledModeChanged;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
    required this.icsUrl,
    required this.onIcsUrlChanged,
    required this.useTimetableView,
    required this.onTimetableChanged,
    required this.oledMode,
    required this.onOledModeChanged
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      CalendarPage(
          key: ValueKey(widget.icsUrl),
          icsUrl: widget.icsUrl,
          useTimetableView: widget.useTimetableView,
      ),
      SettingsPage(
        onThemeChanged: widget.onThemeChanged,
        currentThemeMode: widget.currentThemeMode,
        currentIcsUrl: widget.icsUrl,
        onIcsUrlChanged: widget.onIcsUrlChanged,
        useTimetableView: widget.useTimetableView,
        onTimetableChanged: widget.onTimetableChanged,
        oledMode: widget.oledMode,
        onOledModeChanged: widget.onOledModeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),
          NavigationDestination(
              icon: Icon(Icons.settings),
              label: "Settings"),
        ],
      ),
    );
  }
}

