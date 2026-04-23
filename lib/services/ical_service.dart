import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ICalService {
  String _cacheKeyData(String url) => 'ical_cache_data_$url';
  String _cacheKeyTime(String url) => 'ical_cache_time_$url';

  Future<String> fetchICal(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final dataKey = _cacheKeyData(url);
    final timeKey = _cacheKeyTime(url);

    final cachedData = prefs.getString(dataKey);
    final cachedTimeMillis = prefs.getInt(timeKey);

    if (cachedData != null && cachedTimeMillis != null) {
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(cachedTimeMillis);

      if (now.difference(cachedTime) < Duration(hours: 6)) {
        return cachedData;
      }
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await prefs.setString(dataKey, response.body);
      await prefs.setInt(timeKey, now.millisecondsSinceEpoch);
      return response.body;
    } else {
      if (cachedData != null) return cachedData;
      throw Exception('Failed to load iCal data');
    }
  }

  String extractSubject(String summary) {
    // DHBW format: "Lineare Algebra", "Digitaltechnik", etc.
    // So the whole summary IS the subject
    return summary.trim();
  }

  Future<List<Map<String, dynamic>>> parseICal(String icsData) async {
    final calendar = ICalendar.fromString(icsData);
    final components = calendar.data;

    final events = components.where((c) => c['type'] == 'VEVENT').toList();
    final List<Map<String, dynamic>> parsed = [];

    for (final event in events) {
      // Properties are lowercase
      if (!event.containsKey('dtstart') || !event.containsKey('dtend')) continue;

      final summary = event['summary']?.toString() ?? 'No title';
      final subject = extractSubject(summary);

      parsed.add({
        'summary': summary,
        'subject': subject,
        'start': _parseDate(event['dtstart']),
        'end': _parseDate(event['dtend']),
        'location': event['location']?.toString() ?? '',
      });
    }

    return parsed;
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();

    // The parser gives us an IcsDateTime object
    if (value is IcsDateTime) {
      final dt = value.dt; // e.g. "20251201T081500"

      // DATE ONLY (YYYYMMDD)
      if (RegExp(r'^\d{8}$').hasMatch(dt)) {
        return DateTime(
          int.parse(dt.substring(0, 4)),
          int.parse(dt.substring(4, 6)),
          int.parse(dt.substring(6, 8)),
        );
      }

      // DATETIME (YYYYMMDDTHHMMSS or YYYYMMDDTHHMM)
      if (RegExp(r'^\d{8}T\d{6}$').hasMatch(dt)) {
        return DateTime(
          int.parse(dt.substring(0, 4)),
          int.parse(dt.substring(4, 6)),
          int.parse(dt.substring(6, 8)),
          int.parse(dt.substring(9, 11)),
          int.parse(dt.substring(11, 13)),
          int.parse(dt.substring(13, 15)),
        );
      }

      if (RegExp(r'^\d{8}T\d{4}$').hasMatch(dt)) {
        return DateTime(
          int.parse(dt.substring(0, 4)),
          int.parse(dt.substring(4, 6)),
          int.parse(dt.substring(6, 8)),
          int.parse(dt.substring(9, 11)),
          int.parse(dt.substring(11, 13)),
        );
      }
    }

    // Fallback
    return DateTime.now();
  }



  Map<DateTime, List<Map<String, dynamic>>> buildEventMap(List<Map<String, dynamic>> events) {
    final map = <DateTime, List<Map<String, dynamic>>>{};

    for (var event in events) {
      final date = DateTime(
        event['start'].year,
        event['start'].month,
        event['start'].day,
      );

      map.putIfAbsent(date, () => []);
      map[date]!.add(event); // store whole event
    }

    return map;
  }
}
