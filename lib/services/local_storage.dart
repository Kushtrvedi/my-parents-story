import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const String profilesBox = 'profiles';
  static const String responsesBox = 'responses';
  static const String chaptersBox = 'chapters';
  static const String settingsBox = 'settings';

  static Future<void> init({String? testPath}) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }
    await Hive.openBox(profilesBox);
    await Hive.openBox(responsesBox);
    await Hive.openBox(chaptersBox);
    await Hive.openBox(settingsBox);
  }

  static Box get profiles => Hive.box(profilesBox);
  static Box get responses => Hive.box(responsesBox);
  static Box get chapters => Hive.box(chaptersBox);
  static Box get settings => Hive.box(settingsBox);

  static Future<void> clearAll() async {
    await profiles.clear();
    await responses.clear();
    await chapters.clear();
  }

  static Map<String, dynamic> exportAll() {
    return {
      'profiles': profiles.toMap(),
      'responses': responses.toMap(),
      'chapters': chapters.toMap(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> importAll(Map<String, dynamic> data) async {
    if (data['profiles'] != null) {
      await profiles.putAll(Map<String, dynamic>.from(data['profiles']));
    }
    if (data['responses'] != null) {
      await responses.putAll(Map<String, dynamic>.from(data['responses']));
    }
    if (data['chapters'] != null) {
      await chapters.putAll(Map<String, dynamic>.from(data['chapters']));
    }
  }
}
