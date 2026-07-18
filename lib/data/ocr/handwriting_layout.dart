/// AI-generated wholely or partially with OpenAI Codex.
library;

import 'dart:math';

import 'package:flutter/material.dart';

/// Geometry and recognized text assigned to one handwritten line.
class HandwritingLine<T> {
  const HandwritingLine({
    required this.items,
    required this.bounds,
    required this.referenceHeight,
  });

  final List<T> items;
  final Rect bounds;
  final double referenceHeight;
}

/// Groups handwritten items into visual lines without changing their order.
List<HandwritingLine<T>> groupHandwritingLines<T>(
  List<T> items,
  Rect? Function(T item) getBounds,
) {
  final entries = <({T item, Rect bounds})>[
    for (final item in items)
      if (getBounds(item) case final bounds?) (item: item, bounds: bounds),
  ];
  if (entries.isEmpty) return const [];

  final heights =
      entries
          .map((entry) => entry.bounds.height)
          .where((height) => height > 0)
          .toList()
        ..sort();
  final typicalHeight = heights.isEmpty
      ? 28.0
      : heights[(heights.length * 0.75).floor().clamp(0, heights.length - 1)];
  final threshold = max(28.0, typicalHeight * 1.15);
  final centers = entries.map((entry) => entry.bounds.center.dy).toList()
    ..sort();
  final lineCenters = <double>[centers.first];
  for (final center in centers.skip(1)) {
    if (center - lineCenters.last > threshold) lineCenters.add(center);
  }

  final groups = List.generate(
    lineCenters.length,
    (_) => <({T item, Rect bounds})>[],
  );
  for (final entry in entries) {
    var nearest = 0;
    for (var index = 1; index < lineCenters.length; index++) {
      if ((entry.bounds.center.dy - lineCenters[index]).abs() <
          (entry.bounds.center.dy - lineCenters[nearest]).abs()) {
        nearest = index;
      }
    }
    groups[nearest].add(entry);
  }

  return [
    for (final group in groups)
      if (group.isNotEmpty) _createLine(group),
  ];
}

HandwritingLine<T> _createLine<T>(List<({T item, Rect bounds})> entries) {
  var bounds = entries.first.bounds;
  for (final entry in entries.skip(1)) {
    bounds = bounds.expandToInclude(entry.bounds);
  }
  final heights =
      entries
          .map((entry) => entry.bounds.height)
          .where((height) => height > 0)
          .toList()
        ..sort();
  final robustHeight = heights.isEmpty
      ? bounds.height
      : heights[(heights.length * 0.75).floor().clamp(0, heights.length - 1)];
  final referenceHeight = robustHeight
      .clamp(
        min(bounds.height, max(8.0, bounds.height * 0.55)),
        max(8.0, bounds.height),
      )
      .toDouble();
  return HandwritingLine(
    items: entries.map((entry) => entry.item).toList(),
    bounds: bounds,
    referenceHeight: referenceHeight,
  );
}

/// Splits one OCR result across visual lines while preserving OCR newlines.
List<String> distributeRecognizedText(
  String recognizedText,
  List<double> lineWidths,
) {
  if (lineWidths.isEmpty) return const [];
  final explicitLines = recognizedText
      .trim()
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (explicitLines.length == lineWidths.length) return explicitLines;

  final words = recognizedText
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return List.filled(lineWidths.length, '');
  if (lineWidths.length == 1) return [words.join(' ')];

  final result = List.filled(lineWidths.length, '');
  var wordIndex = 0;
  var remainingWidth = lineWidths.fold<double>(0, (sum, width) => sum + width);
  for (var lineIndex = 0; lineIndex < lineWidths.length; lineIndex++) {
    final remainingLines = lineWidths.length - lineIndex;
    final remainingWords = words.length - wordIndex;
    if (remainingWords <= 0) break;
    final count =
        (lineIndex == lineWidths.length - 1
                ? remainingWords
                : (remainingWords *
                          lineWidths[lineIndex] /
                          max(1, remainingWidth))
                      .round()
                      .clamp(1, max(1, remainingWords - remainingLines + 1)))
            .toInt();
    result[lineIndex] = words.sublist(wordIndex, wordIndex + count).join(' ');
    wordIndex += count;
    remainingWidth -= lineWidths[lineIndex];
  }
  return result;
}
