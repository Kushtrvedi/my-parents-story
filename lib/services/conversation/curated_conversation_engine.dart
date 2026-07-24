import '../../models/memory.dart';
import 'conversation_engine.dart';

class CuratedConversationEngine implements ConversationEngine {
  @override
  Future<bool> get isAvailable async => true; // Always available

  @override
  String get modeName => 'Standard';

  @override
  Future<String> generateFollowUpQuestion(
    List<Memory> history,
    String currentTranscript, {
    String? unfinishedTopic,
    String? timelineGap,
  }) async {
    if (unfinishedTopic != null)
      return 'You mentioned $unfinishedTopic earlier. Could you tell me more about that?';
    if (timelineGap != null)
      return 'I\'d love to hear some stories from the $timelineGap if you have any.';
    return 'That is beautiful. How did that make you feel?';
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
