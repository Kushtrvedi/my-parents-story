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
  Future<String> generateFollowUpQuestion(List<Memory> history, String currentTranscript) async {
    if (_model == null) return 'Could you tell me more about that?';

    final recentContext = history.take(3).map((m) => m.editedTranscript ?? m.originalTranscript).join("\n");

    final prompt = '''
You are a warm, empathetic family historian helping a parent record their life story. 
They just shared this memory: "$currentTranscript".
Past conversation context: "$recentContext".
Ask one gentle, open-ended follow-up question to help them elaborate. Keep it conversational and brief. Do not act like a robot.
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
