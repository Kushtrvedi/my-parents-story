import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/memory.dart';
import 'conversation_engine.dart';

class CloudConversationEngine implements ConversationEngine {
  String? apiKey;
  GenerativeModel? _model;

  void initialize(String key) {
    apiKey = key;
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: key);
  }

  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  @override
  Future<bool> get isAvailable async => hasApiKey;

  @override
  String get modeName => 'Enhanced';

  @override
  Future<String> generateFollowUpQuestion(
    List<Memory> history, 
    String currentTranscript, {
    String? unfinishedTopic,
    String? timelineGap,
  }) async {
    if (_model == null) return 'Could you tell me more about that?';

    final recentContext = history.take(3).map((m) => m.displayAnswer).join("\n");
    
    String contextInstruction = 'Ask one gentle, open-ended follow-up question to help them elaborate on the current memory.';
    if (unfinishedTopic != null) {
      contextInstruction = 'The current memory seems complete. Gently ask them about this unfinished topic they mentioned previously: "$unfinishedTopic". Transition naturally.';
    } else if (timelineGap != null) {
      contextInstruction = 'The current memory seems complete. We are missing stories from the $timelineGap. Gently ask them if they have any memories from that time.';
    }

    final prompt = '''
You are a warm, empathetic family historian helping a parent record their life story. 
They just shared this memory: "$currentTranscript".
Past conversation context: "$recentContext".

$contextInstruction
Keep it brief and conversational. Do not ask multiple questions.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text?.trim() ?? 'Could you tell me more about that?';
    } catch (e) {
      return 'That is wonderful. What else comes to mind?';
    }
  }

  @override
  Future<Map<String, dynamic>> generateStorySeeds(String transcript) async {
    final fallback = {
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

    if (_model == null) return fallback;

    final prompt = '''
Analyze this story: "$transcript".
Extract the following metadata in valid JSON format:
- memoryType (string: "story", "advice", "lifeLesson", "tradition", "recipe", "historicalEvent", "funnyMemory", "regret", "dream", "achievement", "loss", "unknown")
- decade (string, e.g., "1970s", "1980s", or "unknown" if unclear)
- isUnfinished (boolean, true if the story feels abruptly ended or implies more to tell)
- emotionalTone (string, e.g., nostalgic, joyful, proud, sorrowful)
- storyImportance (string: "LOW", "MEDIUM", "HIGH", or "LEGACY")
- lifeStage (string, e.g., Childhood, Career, Marriage, Unknown)
- lifeThemes (array of strings, e.g. ["family", "resilience"])
- people (array of strings)
- places (array of strings)
- historicalEvents (array of strings)
- objects (array of strings)
- familyRelationships (array of strings)
- summary (string, a concise one-line summary)
Output ONLY raw JSON.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final raw = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '';
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return fallback;
    }
  }
}
