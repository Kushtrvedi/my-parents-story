import '../../models/memory.dart';
import 'conversation_engine.dart';

class BrowserConversationEngine implements ConversationEngine {
  @override
  Future<bool> get isAvailable async => false;

  @override
  String get modeName => 'Enhanced';

  @override
  Future<String> generateFollowUpQuestion(List<Memory> history, String currentTranscript) async {
    return 'Could you tell me more about that?';
  }

  @override
  Future<Map<String, dynamic>> generateStorySeeds(String transcript) async {
    return {
      'emotionalTone': 'neutral',
      'storyImportance': 'MEDIUM',
      'lifeStage': 'Unknown',
      'lifeThemes': [],
      'people': [],
      'places': [],
      'historicalEvents': [],
      'objects': [],
      'familyRelationships': [],
      'summary': transcript.length > 50 ? '${transcript.substring(0, 50)}...' : transcript,
    };
  }
}
