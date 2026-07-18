/// AI-generated wholely or partially with OpenAI Codex.
library;

import 'package:flutter/material.dart';

/// Free-positioned recognized text rendered directly on a canvas page.
class CanvasText {
  CanvasText({
    required this.text,
    required this.position,
    required this.fontSize,
    required this.color,
    this.fontFamily = 'Neucha',
    this.bold = false,
    this.italic = false,
  });

  factory CanvasText.fromJson(Map<String, dynamic> json) => CanvasText(
    text: json['v'] as String,
    position: Offset(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    ),
    fontSize: (json['s'] as num).toDouble(),
    color: Color(json['c'] as int),
    fontFamily: json['f'] as String? ?? 'Neucha',
    bold: json['b'] as bool? ?? false,
    italic: json['i'] as bool? ?? false,
  );

  final String text;
  Offset position;
  final double fontSize;
  final Color color;
  final String fontFamily;
  final bool bold;
  final bool italic;

  TextStyle get textStyle => TextStyle(
    color: color,
    fontSize: fontSize,
    fontFamily: fontFamily,
    fontFamilyFallback: const ['Dekko'],
    height: 1,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  );

  Rect get bounds {
    final painter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return position & painter.size;
  }

  CanvasText copy({Offset offset = Offset.zero}) => CanvasText(
    text: text,
    position: position + offset,
    fontSize: fontSize,
    color: color,
    fontFamily: fontFamily,
    bold: bold,
    italic: italic,
  );

  Map<String, dynamic> toJson() => {
    'v': text,
    'x': position.dx,
    'y': position.dy,
    's': fontSize,
    'c': color.toARGB32(),
    if (fontFamily != 'Neucha') 'f': fontFamily,
    if (bold) 'b': true,
    if (italic) 'i': true,
  };
}
