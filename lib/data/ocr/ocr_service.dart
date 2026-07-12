/// Real-time OCR service for handwritten strokes on Saber canvas pages.
  ///
  /// AI-generated using Claude Opus 4.7 (Anthropic).
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
  
    bool get _isSupported =>
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  
    /// Downloads any language models that aren't already present.
    ///
    /// Safe to call multiple times. Requires an internet connection on the
    /// first call for each language. Silent no-op on unsupported platforms.
    Future<void> ensureModelsReady() async {
      if (!_isSupported) return;
      for (final lang in _languages) {
        final downloaded = await _modelManager.isModelDownloaded(lang);
        if (downloaded) continue;
        await _modelManager.downloadModel(lang);
      }
    }
  
    /// Recognises the given Saber strokes as text.
    ///
    /// Runs recognition in every supported language in parallel and returns
    /// the best-scoring candidate. Returns null if the strokes list is
    /// empty, the platform is unsupported, or nothing could be recognised.
    Future<String?> recognise(List<Stroke> strokes) async {
      if (!_isSupported) return null;
      if (strokes.isEmpty) return null;
  
      final ink = _strokesToInk(strokes);
      final futures = <Future<List<mlkit.RecognitionCandidate>>>[];
      for (final lang in _languages) {
        final recognizer = _recognizers[lang] ??=
            mlkit.DigitalInkRecognizer(languageCode: lang);
        futures.add(recognizer.recognize(ink));
      }
  
      final results = await Future.wait(futures);
      return _pickBestCandidate(results);
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
          return mlkit.StrokePoint(
            x: point.x,
            y: point.y,
            t: baseTime + elapsed,
          );
        }).toList();
        return mlStroke;
      }).toList();
  
      return ink;
    }
  
    String? _pickBestCandidate(List<List<mlkit.RecognitionCandidate>> results) {
      mlkit.RecognitionCandidate? best;
      for (final candidates in results) {
        if (candidates.isEmpty) continue;
        final top = candidates.first; 
        if (best == null || top.score < best.score) {
          best = top;
        }
      }
      return best?.text;
    }
  }
