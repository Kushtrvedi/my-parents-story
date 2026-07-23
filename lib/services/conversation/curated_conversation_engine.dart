import '../../models/memory.dart';
import 'conversation_engine.dart';

class CuratedConversationEngine implements ConversationEngine {
  @override
  Future<bool> get isAvailable async => true; // Always available

  @override
  String get modeName => 'Standard';

  @override
  Future<String> generateFollowUpQuestion(List<Memory> history, String currentTranscript) async {
    return 'That is fascinating. Would you like to tell me more, or move on to another memory?';
  }

  @override
  Future<Map<String, dynamic>> generateStorySeeds(String transcript) async {
    return {
      'emotion': 'neutral',
      'importance': 5,
      'lifeStage': 'Unknown',
      'themes': [],
      'peopleMentioned': [],
      'placesMentioned': [],
    };
  }
}
