import 'package:flutter/foundation.dart';
import 'conversation/conversation_engine.dart';
import 'conversation/browser_conversation_engine.dart';
import 'conversation/cloud_conversation_engine.dart';
import 'conversation/curated_conversation_engine.dart';
import 'conversation/life_context_engine.dart';
import 'storage_service.dart';
import '../models/memory.dart';

class ConversationCoordinator {
  static final ConversationCoordinator _instance =
      ConversationCoordinator._internal();
  factory ConversationCoordinator() => _instance;

  late final LifeContextEngine _contextEngine;

  ConversationCoordinator._internal();

  final BrowserConversationEngine _browserEngine = BrowserConversationEngine();
  final CloudConversationEngine _cloudEngine = CloudConversationEngine();
  final CuratedConversationEngine _fallbackEngine = CuratedConversationEngine();

  ConversationEngine? _activeEngine;

  void init(StorageService storageService) {
    _contextEngine = LifeContextEngine(storageService);
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

  Future<String> generateFollowUpQuestion(
      String profileId, String currentTranscript) async {
    final engine = await getActiveEngine();
    final contextMemories =
        _contextEngine.getRelevantContext(profileId, currentTranscript);

    // Check if we need to surface an unfinished story or a timeline gap
    String? unfinishedTopic;
    String? timelineGap;

    // Only inject gaps if we have a very short transcript that doesn't warrant deep follow up
    // Or just let the engine decide how to transition.
    if (currentTranscript.length < 50) {
      final unfinished = _contextEngine.getUnfinishedStory(profileId);
      if (unfinished != null) {
        unfinishedTopic = unfinished.summary ?? 'a previous story';

        // Mark it as finished so we don't ask again immediately
        unfinished.isUnfinished = false;
        final storage = StorageService();
        storage.saveMemory(
          profileId: profileId,
          chapterId: unfinished.chapterId,
          questionId: unfinished.questionId,
          isUnfinished: false,
        );
      } else {
        timelineGap = _contextEngine.getTimelineGap(profileId);
      }
    }

    return engine.generateFollowUpQuestion(
      contextMemories,
      currentTranscript,
      unfinishedTopic: unfinishedTopic,
      timelineGap: timelineGap,
    );
  }

  Future<Map<String, dynamic>> generateStorySeeds(String transcript) async {
    final engine = await getActiveEngine();
    return engine.generateStorySeeds(transcript);
  }
}
