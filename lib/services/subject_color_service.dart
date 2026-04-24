import 'package:flutter/material.dart';

class SubjectColorService {
  static final Map<String, Color> _colors = {};
  static int _index = 0;

  static final List<Color> palette = [
    Color(0xFF6FA8DC), // soft blue
    Color(0xFFF6B26B), // soft orange
    Color(0xFF93C47D), // soft green
    Color(0xFFE06666), // soft red
    Color(0xFF8E7CC3), // soft purple
    Color(0xFF76A5AF), // soft teal
    Color(0xFFF9CB9C), // soft peach
    Color(0xFFB4A7D6), // soft violet
  ];

  static Color getColor(String subject) {
    if (!_colors.containsKey(subject)) {
      _colors[subject] = Color(palette[_index % palette.length].value);
      _index++;
    }
    return _colors[subject]!;
  }
}
