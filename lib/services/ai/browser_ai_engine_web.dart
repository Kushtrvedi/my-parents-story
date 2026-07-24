import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'ai_engine.dart';

class BrowserAIEngine implements AIEngine {
  @override
  Future<bool> get isAvailable async {
    try {
      final ai = globalContext.getProperty('ai'.toJS);
      if (ai == null || ai.isUndefinedOrNull) return false;

      final languageModel = (ai as JSObject).getProperty('languageModel'.toJS);
      if (languageModel == null || languageModel.isUndefinedOrNull)
        return false;

      final capabilitiesPromise =
          (languageModel as JSObject).callMethod('capabilities'.toJS);
      final capabilities = await (capabilitiesPromise as JSPromise).toDart;

      final available =
          (capabilities as JSObject).getProperty('available'.toJS) as JSString?;
      return available?.toDart == 'readily';
    } catch (e) {
      return false;
    }
  }

  @override
  String get name => 'Browser AI (Gemini Nano)';

  @override
  Future<String> generateFollowUpQuestion(
      String context, String currentTranscript) async {
    try {
      final session = await _createSession('''
You are a warm, empathetic family historian helping a parent record their life story. 
They just shared this memory: "$currentTranscript".
Past context: "$context".
Ask one gentle, open-ended follow-up question to help them elaborate. Keep it brief and conversational.
''');
      if (session == null) return 'Could you tell me more about that?';

      final resultPromise = (session as JSObject)
          .callMethod('prompt'.toJS, 'Generate follow up question'.toJS);
      final result = await (resultPromise as JSPromise).toDart as JSString;

      (session as JSObject).callMethod('destroy'.toJS);

      return result.toDart.trim();
    } catch (e) {
      return 'That is wonderful. What else comes to mind?';
    }
  }

  @override
  Future<String> inferChapterTitle(String transcript) async {
    try {
      final session = await _createSession('''
Based on this story: "$transcript", what phase of life does this belong to?
Respond with ONLY ONE of the following options:
Childhood, Education, Career, Marriage, Parenthood, Lessons Learned, Life Journey.
''');
      if (session == null) return 'Life Journey';

      final resultPromise = (session as JSObject)
          .callMethod('prompt'.toJS, 'Infer chapter title'.toJS);
      final result = await (resultPromise as JSPromise).toDart as JSString;

      (session as JSObject).callMethod('destroy'.toJS);

      final raw = result.toDart.trim();
      const allowed = [
        'Childhood',
        'Education',
        'Career',
        'Marriage',
        'Parenthood',
        'Lessons Learned',
        'Life Journey'
      ];
      for (var a in allowed) {
        if (raw.toLowerCase().contains(a.toLowerCase())) return a;
      }
      return 'Life Journey';
    } catch (e) {
      return 'Life Journey';
    }
  }

  Future<JSAny?> _createSession(String systemPrompt) async {
    final ai = globalContext.getProperty('ai'.toJS);
    if (ai == null || ai.isUndefinedOrNull) return null;

    final languageModel = (ai as JSObject).getProperty('languageModel'.toJS);
    if (languageModel == null || languageModel.isUndefinedOrNull) return null;

    final options = JSObject();
    options.setProperty('systemPrompt'.toJS, systemPrompt.toJS);

    final sessionPromise =
        (languageModel as JSObject).callMethod('create'.toJS, options);
    final session = await (sessionPromise as JSPromise).toDart;
    return session;
  }
}
