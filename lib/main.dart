import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String _icsUrl = "https://dhbw.app/ical/STG-TINF25H-ITA.ics";
  bool _useTimetableView = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadIcsUrl();
    _loadTimetable();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('themeMode');
    if (index != null) {
      setState(() {
        _themeMode = ThemeMode.values[index];
      });
    }
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', mode.index);
  }

  Future<void> _loadIcsUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('icsUrl');
    if (saved != null) {
      setState(() => _icsUrl = saved);
    }
  }

  Future<void> _saveIcsUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('icsUrl', url);
  }

  Future<void> _saveTimetable(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('timetable', val);
  }

  Future<void> _loadTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('timetable');
    if (saved != null) {
      setState(() => _useTimetableView = saved);
    }
  }

  void _updateTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _saveTheme(mode);
  }

  void _updateIcsUrl(String url) {
    setState(() => _icsUrl = url);
    _saveIcsUrl(url);
  }

  void _updateUseTimetableView(bool val) {
    setState(() => _useTimetableView = val);
    _saveTimetable(val);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.dark,
      ),
      home: HomePage(
        onThemeChanged: _updateTheme,
        currentThemeMode: _themeMode,
        icsUrl: _icsUrl,
        onIcsUrlChanged: _updateIcsUrl,
        useTimetableView: _useTimetableView,
        onTimetableChanged: _updateUseTimetableView,
      ),
    );
  }
}

