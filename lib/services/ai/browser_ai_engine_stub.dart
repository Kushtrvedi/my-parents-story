import 'ai_engine.dart';

class BrowserAIEngine implements AIEngine {
  @override
  Future<bool> get isAvailable async => false;

  @override
  String get name => 'Browser AI (Gemini Nano)';

  @override
  Future<String> generateFollowUpQuestion(
      String context, String currentTranscript) async {
    return 'Could you tell me more about that?';
  }

  @override
  Future<String> inferChapterTitle(String transcript) async {
    return 'Life Journey';
  }
}
