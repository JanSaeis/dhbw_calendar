import 'package:flutter/material.dart';

class EventDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final start = event['start'];
    final end = event['end'];
    final location = event['location'];

    return SafeArea(
      child: SizedBox.expand(
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  event['summary'],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 12),

                // Time
                Text(
                  "🕒 ${start.hour}:${start.minute.toString().padLeft(2, '0')} "
                      "– ${end.hour}:${end.minute.toString().padLeft(2, '0')}",
                ),

                // Location (optional)
                if (location != "")
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("📍 $location"),
                  ),

                const Spacer(),

                // Close button
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
