import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ical_service.dart';
import '../services/subject_color_service.dart';

import '../widgets/calendar_widget.dart';
import '../widgets/event_list.dart';
import '../widgets/timetable_widget.dart';

class CalendarPage extends StatefulWidget {
  final String icsUrl;
  final bool useTimetableView;

  const CalendarPage({
    super.key,
    required this.icsUrl,
    required this.useTimetableView,
  });

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final ICalService _ical = ICalService();

  Map<DateTime, List<Map<String, dynamic>>> events = {};
  List<Map<String, dynamic>> selectedEvents = [];
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  bool isLoading = false;

  CalendarFormat _calendarFormat = CalendarFormat.month; // placeholder

  @override
  void initState() {
    super.initState();

    // Load events immediately
    loadCalendar();

    // Load saved format AFTER the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCalendarFormat();
    });
  }

  Future<void> loadCalendar() async {
    setState(() => isLoading = true);

    final ics = await _ical.fetchICal(widget.icsUrl);
    final parsed = await _ical.parseICal(ics);
    final map = _ical.buildEventMap(parsed);

    setState(() {
      events = map;

      // Ensure selectedDay is valid for the new calendar
      final key = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
      );
      selectedEvents = events[key] ?? [];
      isLoading = false;
    });
  }

  // save dropdown preference
  Future<void> saveCalendarFormat(CalendarFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('calendarFormat', format.index);
  }

  Future<void> loadCalendarFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('calendarFormat');

    if (index != null) {
      final format = CalendarFormat.values[index];

      if (mounted) {
        setState(() => _calendarFormat = format);
      }
    }
  }

  @override
  void didUpdateWidget(covariant CalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.icsUrl != widget.icsUrl) {
      setState(() {
        selectedDay = DateTime.now();
        focusedDay = DateTime.now();
      });
      //final prefs = await SharedPreferences.getInstance();
      //await prefs.remove('ical_cache_data_${oldWidget.icsUrl}');
      //await prefs.remove('ical_cache_time_${oldWidget.icsUrl}');
      loadCalendar();
    }
  }

  Color getSubjectColor(String subject) => SubjectColorService.getColor(subject);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DHBW Kalender")),
      body: Column(
        children: [
          // --- Top controls ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      selectedDay = now;
                      focusedDay = now;
                      selectedEvents =
                          events[DateTime(now.year, now.month, now.day)] ?? [];
                    });
                  },
                  child: const Text("Jump to Today"),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: DropdownButton<CalendarFormat>(
                    value: _calendarFormat,
                    items: const [
                      DropdownMenuItem(
                        value: CalendarFormat.month,
                        child: Text("Month"),
                      ),
                      DropdownMenuItem(
                        value: CalendarFormat.twoWeeks,
                        child: Text("2 Weeks"),
                      ),
                      DropdownMenuItem(
                        value: CalendarFormat.week,
                        child: Text("Week"),
                      ),
                    ],
                    onChanged: (format) {
                      if (format != null) {
                        setState(() => _calendarFormat = format);
                        saveCalendarFormat(format);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- Calendar ---
          CalendarWidget(
            key: ValueKey(widget.icsUrl),
            focusedDay: focusedDay,
            selectedDay: selectedDay,
            format: _calendarFormat,
            events: events,
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
                selectedEvents =
                    events[DateTime(
                      selected.year,
                      selected.month,
                      selected.day,
                    )] ??
                    [];
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
              saveCalendarFormat(format);
            },
            onPageChanged: (focused) {
              focusedDay = focused;
            },
          ),

          // --- Event list with pull-to-refresh ---
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadCalendar,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : widget.useTimetableView
                  ? TimetableWidget(
                events: selectedEvents,
                getColor: getSubjectColor,
              )
                  : EventList(
                events: selectedEvents,
                getColor: getSubjectColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
