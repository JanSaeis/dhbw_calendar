import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(MyApp());
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
  bool _oledMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadIcsUrl();
    _loadTimetable();
    _loadOledMode();
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

  Future<void> _loadOledMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('oledMode');
    if (saved != null) {
      setState(() => _oledMode = saved);
    }
  }

  Future<void> _saveOledMode(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('oledMode', val);
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

  void _updateOledMode(bool val) {
    setState(() => _oledMode = val);
    _saveOledMode(val);
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
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Only use colorSchemeSeed when OLED mode is OFF
        colorSchemeSeed: _oledMode ? null : Colors.amber,

        // Only use custom colorScheme when OLED mode is ON
        colorScheme: _oledMode
            ? ColorScheme.fromSeed(
                seedColor: Colors.amber,
                brightness: Brightness.dark,
                background: Colors.black,
                surface: Colors.black,
                surfaceTint: Colors.transparent,
              )
            : null,

        scaffoldBackgroundColor: _oledMode ? Colors.black : null,
        canvasColor: _oledMode ? Colors.black : null,
        cardColor: _oledMode ? Colors.black : null,
        dialogBackgroundColor: _oledMode ? Colors.black : null,

        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),

      home: HomePage(
        onThemeChanged: _updateTheme,
        currentThemeMode: _themeMode,
        icsUrl: _icsUrl,
        onIcsUrlChanged: _updateIcsUrl,
        useTimetableView: _useTimetableView,
        onTimetableChanged: _updateUseTimetableView,
        oledMode: _oledMode,
        onOledModeChanged: _updateOledMode,
      ),
    );
  }
}
