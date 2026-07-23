import 'ai_engine.dart';
import '../../l10n/translations.dart';

class CuratedFallbackEngine implements AIEngine {
  @override
  Future<bool> get isAvailable async => true; // Always available

  @override
  String get name => 'Curated Questions';

  @override
  Future<String> generateFollowUpQuestion(String context, String currentTranscript) async {
    // Basic fallback: just ask them to continue or tell another story.
    return 'That is fascinating. Would you like to tell me more, or move on to another memory?';
  }

  @override
  Future<String> inferChapterTitle(String transcript) async {
    return 'Life Journey';
  }
}
