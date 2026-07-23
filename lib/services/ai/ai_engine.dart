abstract class AIEngine {
  /// Whether this engine is currently available for use.
  Future<bool> get isAvailable;

  /// The name of the engine for UI display.
  String get name;

  /// Generates a follow-up question based on the context and current transcript.
  Future<String> generateFollowUpQuestion(String context, String currentTranscript);

  /// Infers the chapter title based on the transcript.
  Future<String> inferChapterTitle(String transcript);
}
