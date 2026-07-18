/// Real-time OCR service for handwritten strokes on Saber canvas pages.
///
/// AI-generated using Claude Opus 4.7 (Anthropic) and OpenAI Codex.
library;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;
import 'package:saber/components/canvas/_stroke.dart';

/// Recognises handwritten strokes as text using Google ML Kit Digital Ink.
///
/// Runs recognition in parallel for Russian and English and returns whichever
/// candidate has the better confidence score. Android/iOS only — no-op on
/// desktop and web platforms where ML Kit isn't available.
class OcrService {
  OcrService._();

  /// Singleton instance shared across the editor.
  static final instance = OcrService._();

  static const _languages = ['ru', 'en'];

  final _modelManager = mlkit.DigitalInkRecognizerModelManager();

  final _recognizers = <String, mlkit.DigitalInkRecognizer>{};
  final _modelPreparations = <String, Future<void>>{};
  var _preferredLanguage = _languages.first;

  bool get _isSupported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Downloads any language models that aren't already present.
  ///
  /// Safe to call multiple times. Requires an internet connection on the
  /// first call for each language. Silent no-op on unsupported platforms.
  Future<void> ensureModelsReady() async {
    if (!_isSupported) return;
    for (final language in _languages) {
      await _ensureModelReady(language);
    }
  }

  Future<void> _ensureModelReady(String language) async {
    final preparation = _modelPreparations[language] ??= _prepareModel(
      language,
    );
    try {
      await preparation;
    } catch (_) {
      if (identical(_modelPreparations[language], preparation)) {
        _modelPreparations.remove(language);
      }
      rethrow;
    }
  }

  Future<void> _prepareModel(String language) async {
    final downloaded = await _modelManager.isModelDownloaded(language);
    if (downloaded) return;
    await _modelManager.downloadModel(language);
  }

  /// Recognises the given Saber strokes as text.
  ///
  /// Runs recognition in every supported language in parallel and returns
  /// the best-scoring candidate. Returns null if the strokes list is
  /// empty, the platform is unsupported, or nothing could be recognised.
  Future<String?> recognise(
    List<Stroke> strokes, {
    bool Function()? shouldContinue,
  }) async {
    if (!_isSupported) return null;
    if (strokes.isEmpty) return null;
    await ensureModelsReady();

    final ink = _strokesToInk(strokes);
    final languages = [
      _preferredLanguage,
      ..._languages.where((language) => language != _preferredLanguage),
    ];
    final results =
        <({String language, mlkit.RecognitionCandidate candidate})>[];

    for (final language in languages) {
      if (shouldContinue?.call() == false) break;
      final recognizer = _recognizers[language] ??= mlkit.DigitalInkRecognizer(
        languageCode: language,
      );
      final candidates = await recognizer.recognize(ink);
      if (candidates.isEmpty) continue;
      results.add((language: language, candidate: candidates.first));
    }

    if (results.isEmpty) return null;
    final best = _pickBestResult(results);
    _preferredLanguage = best.language;
    return best.candidate.text;
  }

  ({String language, mlkit.RecognitionCandidate candidate}) _pickBestResult(
    List<({String language, mlkit.RecognitionCandidate candidate})> results,
  ) {
    if (results.length == 1) return results.single;

    final russian = results.where((result) => result.language == 'ru').first;
    final english = results.where((result) => result.language == 'en').first;
    final russianLength = russian.candidate.text.runes.length;
    final englishLength = english.candidate.text.runes.length;

    if (englishLength >= russianLength + 2) return english;
    if (russianLength >= englishLength + 2) return russian;
    return russian;
  }

  /// Releases native resources held by the recognisers.
  Future<void> dispose() async {
    for (final recognizer in _recognizers.values) {
      await recognizer.close();
    }
    _recognizers.clear();
  }

  mlkit.Ink _strokesToInk(List<Stroke> saberStrokes) {
    final ink = mlkit.Ink();
    final baseTime = DateTime.now().millisecondsSinceEpoch;
    var elapsed = 0;

    ink.strokes = saberStrokes.map((saberStroke) {
      final mlStroke = mlkit.Stroke();
      mlStroke.points = saberStroke.pointsView.map((point) {
        elapsed += 10;
        return mlkit.StrokePoint(x: point.x, y: point.y, t: baseTime + elapsed);
      }).toList();
      return mlStroke;
    }).toList();

    return ink;
  }
}
