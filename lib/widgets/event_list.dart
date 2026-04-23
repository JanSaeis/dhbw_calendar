import 'package:flutter/material.dart';
import '../widgets/event_details_sheet.dart';

class EventList extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final Color Function(String subject) getColor;

  const EventList({super.key, required this.events, required this.getColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: events.map((e) {
        final start = e['start'] as DateTime;
        final end = e['end'] as DateTime;
        final location = e['location'] as String;

        String two(int n) => n.toString().padLeft(2, '0');
        final timeRange =
            "${two(start.hour)}:${two(start.minute)}–${two(end.hour)}:${two(end.minute)}";

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border(
              left: BorderSide(color: getColor(e['subject']), width: 6),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              e['summary'],
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              "$timeRange • $location",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // <-- allows full-screen height
                backgroundColor: Colors.transparent, // optional, for cleaner edges
                builder: (_) => EventDetailsSheet(event: e),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
