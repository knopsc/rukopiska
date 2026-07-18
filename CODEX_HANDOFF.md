<!-- AI-generated wholly or partially with OpenAI Codex. -->

# Rukopiska development handoff

## Project

- Flutter fork of Saber for Xiaomi Pad 6.
- Repository: `https://github.com/knopsc/rukopiska.git`.
- Working branch: `main`.
- Do not commit the local untracked file `build_log.txt`.
- Read `AGENTS.md` before changing files and preserve required AI credits.

## Current implementation

- Google ML Kit Digital Ink Recognition `0.14.2` recognizes Russian and English handwriting.
- Smart Pen can replace handwriting with editable `CanvasText` objects.
- Recognized words support lasso, movement, duplication, deletion, undo/redo, color and font settings.
- OCR waits for an idle interval and does not start while the stylus is touching the screen.
- Multiline ink is sent to ML Kit in one recognition request; geometry is used afterward to place text on separate lines.
- Font size uses a robust per-line stroke-height estimate to avoid oversized text on later lines.

## Latest pushed state

- Latest commit: `bd5b5df4 fix: stabilize multiline handwriting OCR 📝✨`.
- `origin/main` was confirmed up to date on July 18, 2026.
- Relevant tests and debug APK build passed.
- APK output: `build/app/outputs/flutter-apk/app-debug.apk`.

## Current user feedback

- Multiline recognition is much better than before.
- Some font sizing and positioning problems remain.
- The stylus now freezes heavily, especially around handwriting/OCR activity.
- The next priority is fixing stylus latency without degrading multiline recognition.

## Recommended next investigation

1. Profile pointer and frame timing on the Xiaomi Pad 6 in profile mode, not only debug mode.
2. Check whether OCR work, text measurement, `setState`, page redraw, autosave, or running both language recognizers overlaps with the next stylus contact.
3. Add timing logs around `_recognisePendingStrokes`, both ML Kit recognizers, `_replaceStrokesWithText`, `page.redrawStrokes`, and autosave.
4. Prevent stale OCR completion from performing replacement while a new stroke is being drawn; defer the UI mutation until the pointer is up.
5. Consider processing only a completed handwriting batch and moving expensive layout preparation away from the critical pointer path.
6. Test with `flutter run --profile` before attributing latency to tablet hardware.

## Relevant files

- `lib/pages/editor/editor.dart`
- `lib/data/ocr/ocr_service.dart`
- `lib/data/ocr/handwriting_layout.dart`
- `lib/data/ocr/smart_pen_settings.dart`
- `lib/data/editor/canvas_text.dart`
- `lib/components/canvas/_canvas_painter.dart`
- `test/handwriting_layout_test.dart`

## Deferred feature

- A true pixel/partial eraser for recognized text is not implemented. It requires persistent text erase masks, stroke fragmentation, serialization, and undo/redo support.
