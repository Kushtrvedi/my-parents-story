import '../../models/memory.dart';

abstract class ConversationEngine {
  /// Whether this engine is currently available for use.
  Future<bool> get isAvailable;

  /// The name of the mode for UI display (e.g. "Enhanced", "Standard").
  String get modeName;

  /// Generates a follow-up question based on the conversation history.
  Future<String> generateFollowUpQuestion(List<Memory> history, String currentTranscript);

  /// Extracts story seeds (emotions, themes, people, places, summary) from the transcript.
  Future<Map<String, dynamic>> generateStorySeeds(String transcript);
}
