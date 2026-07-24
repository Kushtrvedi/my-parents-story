import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    double rate = 1.0;
    if (!kIsWeb) {
      if (io.Platform.isIOS || io.Platform.isMacOS) {
        rate = 0.5;
      }
    }
    await _tts.setSpeechRate(rate); // Natural conversational human pace
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0); // Warm natural human pitch

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });
  }

  Future<void> speak(String text, {String? localeCode}) async {
    if (text.isEmpty) return;
    await stop();

    if (localeCode != null && localeCode.isNotEmpty) {
      await setLocale(localeCode);
    }

    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  Future<void> setLocale(String localeCode) async {
    final formattedLocale = _getFormattedLocale(localeCode);
    
    // Try multiple locale string representations for cross-platform Web/Mobile compatibility
    try {
      await _tts.setLanguage(formattedLocale);
    } catch (_) {
      try {
        await _tts.setLanguage(localeCode);
      } catch (_) {}
    }
    
    // Select best matching human voice for the target locale
    try {
      final List<dynamic>? voices = await _tts.getVoices;
      if (voices != null && voices.isNotEmpty) {
        Map<String, String>? bestMatch;
        Map<String, String>? fallbackMatch;

        for (final voice in voices) {
          if (voice is Map) {
            final name = voice['name']?.toString() ?? '';
            final locale = voice['locale']?.toString() ?? '';
            final lowerName = name.toLowerCase();
            final lowerLocale = locale.toLowerCase().replaceAll('_', '-');
            final targetCode = localeCode.toLowerCase();

            if (lowerLocale.contains(targetCode) || lowerLocale.contains(formattedLocale.toLowerCase())) {
              fallbackMatch ??= {'name': name, 'locale': locale};
              if (lowerName.contains('natural') ||
                  lowerName.contains('neural') ||
                  lowerName.contains('google') ||
                  lowerName.contains('wavenet') ||
                  lowerName.contains('network') ||
                  lowerName.contains('enhanced') ||
                  lowerName.contains('hi-in') ||
                  lowerName.contains('hindi') ||
                  lowerName.contains('premium')) {
                bestMatch = {'name': name, 'locale': locale};
                break;
              }
            }
          }
        }

        final selectedVoice = bestMatch ?? fallbackMatch;
        if (selectedVoice != null) {
          await _tts.setVoice(selectedVoice);
        }
      }
    } catch (_) {
      // Best-effort voice selection
    }
  }

  String _getFormattedLocale(String code) {
    switch (code) {
      case 'hi':
        return 'hi-IN';
      case 'gu':
        return 'gu-IN';
      case 'es':
        return 'es-ES';
      case 'mr':
        return 'mr-IN';
      case 'ta':
        return 'ta-IN';
      case 'te':
        return 'te-IN';
      case 'ml':
        return 'ml-IN';
      case 'bn':
        return 'bn-IN';
      case 'kn':
        return 'kn-IN';
      case 'pa':
        return 'pa-IN';
      case 'or':
        return 'or-IN';
      case 'en':
      default:
        return 'en-US';
    }
  }

  void dispose() {
    _tts.stop();
  }
}
