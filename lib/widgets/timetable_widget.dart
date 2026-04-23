import 'package:flutter/material.dart';
import '../widgets/event_details_sheet.dart';

class TimetableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final Color Function(String subject) getColor;

  const TimetableWidget({
    super.key,
    required this.events,
    required this.getColor,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    const int startHour = 6;
    const int endHour = 20;
    const double hourHeight = 80;
    const double hourLabelWidth = 60;

    final int totalHours = endHour - startHour;
    final double timetableHeight = totalHours * hourHeight;

    // Sort events
    final sorted = [...events]
      ..sort((a, b) => a['start'].compareTo(b['start']));

    // Group overlapping events
    final groups = <List<Map<String, dynamic>>>[];
    var current = <Map<String, dynamic>>[];

    for (final e in sorted) {
      if (current.isEmpty || e['start'].isBefore(current.last['end'])) {
        current.add(e);
      } else {
        groups.add(current);
        current = [e];
      }
    }
    if (current.isNotEmpty) groups.add(current);

    // Assign columns
    for (final group in groups) {
      for (int i = 0; i < group.length; i++) {
        group[i]['column'] = i;
        group[i]['columnCount'] = group.length;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      if (now.hour >= startHour && now.hour < endHour) {
        final double offset =
            ((now.hour - startHour) * hourHeight) +
            (now.minute / 60) * hourHeight -
            200; // scroll a bit above the line

        scrollController.animateTo(
          offset.clamp(0, timetableHeight),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final double usableWidth = constraints.maxWidth - hourLabelWidth;

        return SingleChildScrollView(
          controller: scrollController,
          child: SizedBox(
            height: timetableHeight,
            child: Stack(
              children: [
                // Hour lines + labels
                for (int i = 0; i < totalHours; i++) ...[
                  // Hour label
                  Positioned(
                    top: i * hourHeight + 4,
                    left: 8,
                    width: hourLabelWidth - 16,
                    child: Text("${startHour + i}:00"),
                  ),

                  // Hour line
                  Positioned(
                    top: i * hourHeight,
                    left: hourLabelWidth,
                    right: 0,
                    height: hourHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                ],

                // Events
                for (final e in sorted)
                  _buildEventBox(
                    context,
                    e,
                    startHour,
                    hourHeight,
                    hourLabelWidth,
                    usableWidth,
                  ),

                // Current time line
                if (DateTime.now().hour >= startHour &&
                    DateTime.now().hour < endHour)
                  Positioned(
                    top:
                    ((DateTime.now().hour - startHour) * hourHeight) +
                        (DateTime.now().minute / 60) * hourHeight,
                    left: hourLabelWidth,
                    right: 0,
                    child: Container(height: 2, color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventBox(
    BuildContext context,
    Map<String, dynamic> e,
    int startHour,
    double hourHeight,
    double hourLabelWidth,
    double usableWidth,
  ) {
    final start = e['start'];
    final end = e['end'];

    final double top =
        (start.hour - startHour) * hourHeight +
        (start.minute / 60) * hourHeight;

    final double height = (end.difference(start).inMinutes / 60) * hourHeight;

    final int col = e['column'] ?? 0;
    final int colCount = e['columnCount'] ?? 1;

    final double width = usableWidth / colCount;
    final double left = hourLabelWidth + col * width;

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (_) => EventDetailsSheet(event: e),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getColor(e['subject']).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: getColor(e['subject']), width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  /*Icon(
                    Icons.book, // or subject-specific icon
                    size: 14,
                  ),*/
                  Text(
                    e['summary'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  if (e['location'] != "")
                    Text(
                      e['location'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
