import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat format;
  final Map<DateTime, List<dynamic>> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final Color Function(String subject) getColor;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.format,
    required this.events,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.getColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          startingDayOfWeek: StartingDayOfWeek.monday,
          focusedDay: focusedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          calendarFormat: format,
          onFormatChanged: onFormatChanged,
          onPageChanged: onPageChanged,
          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
          onDaySelected: onDaySelected,
          eventLoader: (day) {
            final key = DateTime(day.year, day.month, day.day);
            return events[key] ?? [];
          },
          availableCalendarFormats: const {
            CalendarFormat.month: 'Toggle',
            CalendarFormat.twoWeeks: 'Toggle',
            CalendarFormat.week: 'Toggle',
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, dayEvents) {
              if (dayEvents.isEmpty) return const SizedBox.shrink();

              return Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(dayEvents.length.clamp(1, 3), (
                    index,
                  ) {
                    final event = dayEvents[index] as Map<String, dynamic>;

                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: getColor(event['subject'] ?? ''),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
