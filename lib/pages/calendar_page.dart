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
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  final ICalService _ical = ICalService();

  Map<DateTime, List<Map<String, dynamic>>> events = {};
  List<Map<String, dynamic>> selectedEvents = [];
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  bool isLoading = false;

  CalendarFormat _calendarFormat = CalendarFormat.month;

  late final AnimationController _calendarController;
  late final Animation<double> _calendarAnimation;
  bool isCalendarExpanded = true;

  @override
  void initState() {
    super.initState();

    _calendarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 210),
    );

    _calendarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _calendarController, curve: Curves.easeIn),
    );

    // Start expanded
    _calendarController.value = 1.0;

    loadCalendar();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCalendarFormat();
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> loadCalendar() async {
    setState(() => isLoading = true);

    final ics = await _ical.fetchICal(widget.icsUrl);
    final parsed = await _ical.parseICal(ics);
    final map = _ical.buildEventMap(parsed);

    setState(() {
      events = map;

      final key = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
      );
      selectedEvents = events[key] ?? [];
      isLoading = false;
    });
  }

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
      loadCalendar();
    }
  }

  Color getSubjectColor(String subject) =>
      SubjectColorService.getColor(subject);

  void toggleCalendarExpanded() {
    isCalendarExpanded = !isCalendarExpanded;
    if (isCalendarExpanded) {
      _calendarController.forward();
    } else {
      _calendarController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Top controls ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      toggleCalendarExpanded();
                      final now = DateTime.now();
                      setState(() {
                        selectedDay = now;
                        focusedDay = now;
                        selectedEvents =
                            events[DateTime(now.year, now.month, now.day)] ??
                            [];
                      });
                    },
                    child: const Text("Today"),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButton<CalendarFormat>(
                      value: _calendarFormat,
                      underline: SizedBox(),
                      borderRadius: BorderRadius.circular(12),
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

            // --- Calendar with collapse animation ---
            ClipRect(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RepaintBoundary(
                    child: SizeTransition(
                      sizeFactor: _calendarAnimation,
                      axisAlignment: -1.0, // collapse upward
                      child: CalendarWidget(
                        key: ValueKey(widget.icsUrl),
                        focusedDay: focusedDay,
                        selectedDay: selectedDay,
                        format: _calendarFormat,
                        events: events,
                        getColor: getSubjectColor,
                        onDaySelected: (selected, focused) {
                          setState(() {
                            toggleCalendarExpanded();

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
                    ),
                  ),

                  // --- Bottom bar with arrow ---
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        toggleCalendarExpanded();
                      });
                    },
                    child: Container(
                      height: 32,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Icon(
                        isCalendarExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Event list ---
            Expanded(
              child: RefreshIndicator(
                key: UniqueKey(),
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
      ),
    );
  }
}
