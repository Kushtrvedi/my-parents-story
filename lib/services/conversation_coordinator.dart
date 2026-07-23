import 'package:flutter/foundation.dart';
import 'conversation/conversation_engine.dart';
import 'conversation/browser_conversation_engine.dart';
import 'conversation/cloud_conversation_engine.dart';
import 'conversation/curated_conversation_engine.dart';
import 'conversation/memory_retriever.dart';
import 'storage_service.dart';
import '../models/memory.dart';

class ConversationCoordinator {
  static final ConversationCoordinator _instance = ConversationCoordinator._internal();
  factory ConversationCoordinator() => _instance;
  
  late final MemoryRetriever _retriever;

  ConversationCoordinator._internal();

  final BrowserConversationEngine _browserEngine = BrowserConversationEngine();
  final CloudConversationEngine _cloudEngine = CloudConversationEngine();
  final CuratedConversationEngine _fallbackEngine = CuratedConversationEngine();

  ConversationEngine? _activeEngine;

  void init(StorageService storageService) {
    _retriever = MemoryRetriever(storageService);
  }

  void setCloudApiKey(String key) {
    _cloudEngine.initialize(key);
    _activeEngine = null; // reset to force re-evaluation
  }

  Future<ConversationEngine> getActiveEngine() async {
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

  Future<String> getModeName() async {
    final engine = await getActiveEngine();
    return engine.modeName;
  }

  Future<String> generateFollowUpQuestion(String profileId, String currentTranscript) async {
    final engine = await getActiveEngine();
    final contextMemories = _retriever.getRelevantContext(profileId, currentTranscript);
    return engine.generateFollowUpQuestion(contextMemories, currentTranscript);
  }

  Future<Map<String, dynamic>> generateStorySeeds(String transcript) async {
    final engine = await getActiveEngine();
    return engine.generateStorySeeds(transcript);
  }
}
