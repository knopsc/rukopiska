/// AI-generated wholely or partially with OpenAI Codex.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/ocr/handwriting_layout.dart';

void main() {
  test('groups nearby strokes into one line', () {
    final bounds = [
      const Rect.fromLTWH(0, 10, 20, 30),
      const Rect.fromLTWH(25, 12, 20, 28),
      const Rect.fromLTWH(50, 8, 3, 4),
    ];

    final lines = groupHandwritingLines(bounds, (bounds) => bounds);

    expect(lines, hasLength(1));
    expect(lines.single.items, bounds);
  });

  test('separates handwriting on two lines', () {
    final bounds = [
      const Rect.fromLTWH(0, 10, 20, 30),
      const Rect.fromLTWH(25, 12, 20, 28),
      const Rect.fromLTWH(0, 75, 20, 29),
      const Rect.fromLTWH(25, 77, 20, 31),
    ];

    final lines = groupHandwritingLines(bounds, (bounds) => bounds);

    expect(lines, hasLength(2));
    expect(lines.first.items, bounds.take(2));
    expect(lines.last.items, bounds.skip(2));
  });

  test('uses robust line height when one stroke is abnormally tall', () {
    final bounds = [
      const Rect.fromLTWH(0, 10, 20, 30),
      const Rect.fromLTWH(25, 10, 20, 31),
      const Rect.fromLTWH(50, 0, 20, 80),
      const Rect.fromLTWH(75, 11, 20, 29),
      const Rect.fromLTWH(100, 9, 20, 30),
    ];

    final line = groupHandwritingLines(bounds, (bounds) => bounds).single;

    expect(line.referenceHeight, lessThan(50));
  });

  test('preserves OCR newlines', () {
    final lines = distributeRecognizedText('первая строка\nsecond line', [
      100,
      80,
    ]);

    expect(lines, ['первая строка', 'second line']);
  });

  test('distributes words by visual line width without OCR newlines', () {
    final lines = distributeRecognizedText('one two three four', [300, 100]);

    expect(lines, ['one two three', 'four']);
  });
}
