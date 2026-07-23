import 'package:flutter/foundation.dart';
import 'ai/ai_engine.dart';
import 'ai/browser_ai_engine.dart';
import 'ai/cloud_ai_engine.dart';
import 'ai/curated_fallback_engine.dart';

class AiCoordinator {
  static final AiCoordinator _instance = AiCoordinator._internal();
  factory AiCoordinator() => _instance;
  
  AiCoordinator._internal();

  final BrowserAIEngine _browserEngine = BrowserAIEngine();
  final CloudAIEngine _cloudEngine = CloudAIEngine();
  final CuratedFallbackEngine _fallbackEngine = CuratedFallbackEngine();

  AIEngine? _activeEngine;

  void setCloudApiKey(String key) {
    _cloudEngine.initialize(key);
    _activeEngine = null; // reset to force re-evaluation
  }

  Future<AIEngine> getActiveEngine() async {
    if (_activeEngine != null) return _activeEngine!;

    if (await _browserEngine.isAvailable) {
      _activeEngine = _browserEngine;
    } else if (await _cloudEngine.isAvailable) {
      _activeEngine = _cloudEngine;
    } else {
      _activeEngine = _fallbackEngine;
    }
    
    return _activeEngine!;
  }

  Future<String> generateFollowUpQuestion(String context, String currentTranscript) async {
    final engine = await getActiveEngine();
    return engine.generateFollowUpQuestion(context, currentTranscript);
  }

  Future<String> inferChapterTitle(String transcript) async {
    final engine = await getActiveEngine();
    return engine.inferChapterTitle(transcript);
  }
}
