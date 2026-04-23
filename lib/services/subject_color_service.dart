import 'package:flutter/material.dart';

class SubjectColorService {
  static final Map<String, Color> _colors = {};
  static int _index = 0;

  static final List<Color> palette = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  static Color getColor(String subject) {
    if (!_colors.containsKey(subject)) {
      _colors[subject] = palette[_index % palette.length];
      _index++;
    }
    return _colors[subject]!;
  }
}
