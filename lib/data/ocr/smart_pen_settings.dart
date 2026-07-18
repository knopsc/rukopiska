/// AI-generated wholely or partially with OpenAI Codex.
library;

import 'package:flutter/material.dart';

/// Shared appearance settings for newly recognized canvas text.
class SmartPenSettings extends ChangeNotifier {
  SmartPenSettings._();

  static final instance = SmartPenSettings._();

  var fontFamily = 'Neucha';
  var automaticSize = true;
  var sizeScale = 1.0;
  var fixedSize = 36.0;
  var bold = false;
  var italic = false;

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }
}
