import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_engine.dart';
import '../../l10n/translations.dart';

class CloudAIEngine implements AIEngine {
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
  String get name => 'Cloud AI (Gemini)';

  @override
  Future<String> generateFollowUpQuestion(String context, String currentTranscript) async {
    if (_model == null) return 'Could you tell me more about that?';

    final prompt = '''
You are a warm, empathetic family historian helping a parent record their life story. 
They just shared this memory: "$currentTranscript".
Past context: "$context".
Ask one gentle, open-ended follow-up question to help them elaborate. Keep it conversational and brief.
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
  Future<String> inferChapterTitle(String transcript) async {
    if (_model == null) return 'Life Journey';

    final prompt = '''
Based on this story: "$transcript", what phase of life does this belong to?
Respond with ONLY ONE of the following options:
Childhood, Education, Career, Marriage, Parenthood, Lessons Learned, Life Journey.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final raw = response.text?.trim() ?? '';
      const allowed = ['Childhood', 'Education', 'Career', 'Marriage', 'Parenthood', 'Lessons Learned', 'Life Journey'];
      for (var a in allowed) {
        if (raw.toLowerCase().contains(a.toLowerCase())) return a;
      }
      return 'Life Journey';
    } catch (e) {
      return 'Life Journey';
    }
  }
}
