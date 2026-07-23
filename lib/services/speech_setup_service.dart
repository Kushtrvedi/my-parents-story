import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'local_storage.dart';

class SpeechSetupResult {
  final bool microphoneGranted;
  final bool speechAvailable;
  final bool onDeviceAvailable;
  final bool offlineLanguageReady;
  final List<String> installedLanguages;
  final String? errorMessage;

  const SpeechSetupResult({
    required this.microphoneGranted,
    required this.speechAvailable,
    required this.onDeviceAvailable,
    required this.offlineLanguageReady,
    required this.installedLanguages,
    this.errorMessage,
  });

  bool get allReady => microphoneGranted && speechAvailable && offlineLanguageReady;
}

class SpeechSetupService {
  static const String _setupCompleteKey = 'speech_setup_complete';
  static const String _familyModeKey = 'family_assistant_mode';

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isInitialized = false;

  bool get isSetupComplete => LocalStorage.settings.get(_setupCompleteKey, defaultValue: false) == true;
  bool get isFamilyMode => LocalStorage.settings.get(_familyModeKey, defaultValue: false) == true;

  Future<void> markSetupComplete() async {
    await LocalStorage.settings.put(_setupCompleteKey, true);
  }

  Future<void> setFamilyMode(bool value) async {
    await LocalStorage.settings.put(_familyModeKey, value);
  }

  Future<bool> requestMicrophonePermission() async {
    if (kIsWeb) return true; // Web handles permissions via browser
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<SpeechSetupResult> checkDeviceReadiness({String? languageCode}) async {
    bool microphoneGranted = false;
    bool speechAvailable = false;
    bool onDeviceAvailable = false;
    bool offlineLanguageReady = false;
    List<String> installedLanguages = [];
    String? errorMessage;

    try {
      // Step 1: Check microphone permission
      if (kIsWeb) {
        microphoneGranted = true; // Web handles permissions via browser
      } else {
        final micStatus = await Permission.microphone.status;
        microphoneGranted = micStatus.isGranted;

        if (!microphoneGranted) {
          final requested = await Permission.microphone.request();
          microphoneGranted = requested.isGranted;
        }
      }

      // Step 2: Check speech recognition availability
      _isInitialized = await _speech.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
      speechAvailable = _isInitialized;

      // Step 3: Check on-device recognition (if available on platform)
      if (speechAvailable) {
        try {
          // isOnDeviceRecognitionAvailable may not be available in all versions
          // Use locales as a proxy for on-device capability
          final locales = await _speech.locales();
          onDeviceAvailable = locales.isNotEmpty;
        } catch (_) {
          onDeviceAvailable = false;
        }

        // Step 4: Get installed languages
        try {
          final locales = await _speech.locales();
          installedLanguages = locales.map((l) => l.localeId).toList();
        } catch (_) {
          installedLanguages = [];
        }

        // Step 5: Check if requested language is available
        if (languageCode != null && languageCode.isNotEmpty) {
          offlineLanguageReady = installedLanguages.any(
            (l) => l.toLowerCase().startsWith(languageCode.toLowerCase()),
          );
        } else {
          offlineLanguageReady = installedLanguages.isNotEmpty;
        }
      }
    } catch (e) {
      errorMessage = _getErrorMessage(e);
    }

    return SpeechSetupResult(
      microphoneGranted: microphoneGranted,
      speechAvailable: speechAvailable,
      onDeviceAvailable: onDeviceAvailable,
      offlineLanguageReady: offlineLanguageReady,
      installedLanguages: installedLanguages,
      errorMessage: errorMessage,
    );
  }

  Future<void> openSpeechSettings() async {
    if (kIsWeb) return; // Web doesn't need this
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await const MethodChannel('com.myparentsstory/setup').invokeMethod('openSpeechSettings');
      } catch (_) {
        // Fallback: guide user manually
      }
    }
  }

  Future<void> openLanguagePackSettings() async {
    if (kIsWeb) return; // Web doesn't need this
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await const MethodChannel('com.myparentsstory/setup').invokeMethod('openLanguagePackSettings');
      } catch (_) {
        // Fallback: guide user manually
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('not available')) {
      return 'Speech recognition is not available on this device.';
    }
    return 'Something went wrong while checking speech recognition.';
  }
}
