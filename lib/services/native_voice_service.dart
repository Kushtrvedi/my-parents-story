import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class NativeVoiceService {
  late stt.SpeechToText _speech;
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  Function(String)? _externalStatusListener;

  Future<bool> initialize({Function(String)? onStatus}) async {
    _externalStatusListener = onStatus;
    _speech = stt.SpeechToText();
    _isInitialized = await _speech.initialize(
      onError: (_) => _isListening = false,
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
        if (_externalStatusListener != null) {
          _externalStatusListener!(status);
        }
      },
    );
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;

    _isListening = true;
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,
      listenFor: const Duration(minutes: 30),
      pauseFor: const Duration(
          minutes: 5), // Extremely long pause allowed for elderly users
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  void dispose() {
    if (_isInitialized) {
      _speech.cancel();
    }
  }
}
