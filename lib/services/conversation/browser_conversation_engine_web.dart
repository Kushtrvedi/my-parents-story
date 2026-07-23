import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import '../../models/memory.dart';
import 'conversation_engine.dart';

class BrowserConversationEngine implements ConversationEngine {
  @override
  Future<bool> get isAvailable async {
    try {
      final ai = globalContext.getProperty('ai'.toJS);
      if (ai == null || ai.isUndefinedOrNull) return false;
      
      final languageModel = (ai as JSObject).getProperty('languageModel'.toJS);
      if (languageModel == null || languageModel.isUndefinedOrNull) return false;
      
      final capabilitiesPromise = (languageModel as JSObject).callMethod('capabilities'.toJS);
      final capabilities = await (capabilitiesPromise as JSPromise).toDart;
      
      final available = (capabilities as JSObject).getProperty('available'.toJS) as JSString?;
      return available?.toDart == 'readily';
    } catch (e) {
      return false;
    }
  }

  @override
  String get modeName => 'Enhanced';

  @override
  Future<String> generateFollowUpQuestion(
    List<Memory> history, 
    String currentTranscript, {
    String? unfinishedTopic,
    String? timelineGap,
  }) async {
    try {
      final recentContext = history.take(3).map((m) => m.displayAnswer).join("\n");
      
      String contextInstruction = 'Ask one gentle, open-ended follow-up question to help them elaborate on the current memory.';
      if (unfinishedTopic != null) {
        contextInstruction = 'The current memory seems complete. Gently ask them about this unfinished topic they mentioned previously: "$unfinishedTopic". Transition naturally.';
      } else if (timelineGap != null) {
        contextInstruction = 'The current memory seems complete. We are missing stories from the $timelineGap. Gently ask them if they have any memories from that time.';
      }

      final session = await _createSession('''
You are a warm, empathetic family historian helping a parent record their life story. 
They just shared this memory: "$currentTranscript".
Past conversation context: "$recentContext".

$contextInstruction
Keep it brief and conversational.
''');
      if (session == null) return 'Could you tell me more about that?';
      
      final resultPromise = (session as JSObject).callMethod('prompt'.toJS, 'Generate follow up question'.toJS);
      final result = await (resultPromise as JSPromise).toDart as JSString;
      
      (session as JSObject).callMethod('destroy'.toJS);
      
      return result.toDart.trim();
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

    try {
      final session = await _createSession('''
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
''');
      if (session == null) return fallback;
      
      final resultPromise = (session as JSObject).callMethod('prompt'.toJS, 'Generate JSON'.toJS);
      final result = await (resultPromise as JSPromise).toDart as JSString;
      
      (session as JSObject).callMethod('destroy'.toJS);
      
      final raw = result.toDart.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return fallback;
    }
  }
  
  Future<JSAny?> _createSession(String systemPrompt) async {
    final ai = globalContext.getProperty('ai'.toJS);
    if (ai == null || ai.isUndefinedOrNull) return null;
    
    final languageModel = (ai as JSObject).getProperty('languageModel'.toJS);
    if (languageModel == null || languageModel.isUndefinedOrNull) return null;
    
    final options = JSObject();
    options.setProperty('systemPrompt'.toJS, systemPrompt.toJS);
    
    final sessionPromise = (languageModel as JSObject).callMethod('create'.toJS, options);
    final session = await (sessionPromise as JSPromise).toDart;
    return session;
  }
}
